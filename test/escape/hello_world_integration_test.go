package test

import (
	"fmt" // 追加
	"time" // 追加
	"strings" //追加
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"testing"
)

const dbDirStage = "../live/stage/data-stores/mysql"
const appDirStage = "../live/stage/services/hello-world-app"

func TestHelloWorldAppStage(t *testing.T) {
	t.Parallel()

	// My SQLデータベースをデプロイ
	dbOpts := createDbOpts(t, dbDirStage)
	defer terraform.Destroy(t, dbOpts)
	terraform.InitAndApply(t, dbOpts)

	// hello-world-appをデプロイ
	helloOpts := createHelloOpts(dbOpts, appDirStage)
	defer terraform.Destroy(t, helloOpts)
	terraform.InitAndApply(t, helloOpts)

	// hello-world-appが動作しているか確認
	validateHelloApp(t, helloOpts)
}

func createDbOpts(t *testing.T, TerraformDir string) *terraform.Options {
	uniqueId := random.UniqueId()

	bucketForTesting := "miyasuta-terraform-up-and-running-state"
	bucketRegionForTestiong := "us-east-2"
	dbStateKey := "stage/data-stores/mysql/terraform.tfstate"

	return &terraform.Options{
		TerraformDir: TerraformDir,

		Vars: map[string]interface{}{
			"db_name": fmt.Sprintf("test%s", uniqueId),
			"db_username": "admin",
			"db_password": "password",
		},

		BackendConfig : map[string]interface{}{
			"bucket": bucketForTesting,
			"region": bucketRegionForTestiong,
			"key": dbStateKey,
			"encrypt": true,
		},
	}
}

func createHelloOpts(
	dbOpts *terraform.Options,
	terraformDir string) *terraform.Options {
	
	return &terraform.Options{
		TerraformDir: terraformDir,

		Vars: map[string]interface{}{
			"db_remote_state_bucket": dbOpts.BackendConfig["bucket"],
			"db_remote_state_key": dbOpts.BackendConfig["key"],
			"environment": dbOpts.Vars["db_name"],
		},
	}
}

func validateHelloApp(t *testing.T, helloOpts *terraform.Options) {
	albDnsName := terraform.OutputRequired(t, helloOpts, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		url,
		nil,
		maxRetries,
		timeBetweenRetries,
		func(status int, body string) bool {
			return status == 200 &&
				strings.Contains(body, "Hello, World")
		},
	)
}
