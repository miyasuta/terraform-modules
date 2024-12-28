package test

import (
	"fmt" // 追加
	"time" // 追加
	"strings" //追加
	"github.com/gruntwork-io/terratest/modules/test-structure" //追加
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"testing"
)

const dbDirStage = "../live/stage/data-stores/mysql"
const appDirStage = "../live/stage/services/hello-world-app"

func TestHelloWorldAppStageWithStages(t *testing.T) {
	t.Parallel()

	//この本でのサンプルコードを短く保つため、関数を短い変数名の変数に保存
	stage := test_structure.RunTestStage

	// My SQLデータベースをデプロイ
	defer stage(t, "teardown_db", func() { teardownDb(t, dbDirStage)})
	stage(t, "depoy_db", func() {deployDb(t, dbDirStage)})

	// hello-world-appをデプロイ
	defer stage(t, "teardown_app", func() { teardownApp(t, appDirStage)})
	stage(t, "deploy_app", func() { deployApp(t, dbDirStage, appDirStage)})

	// hello-world-appが動作しているか確認
	stage(t, "validate_app", func() { validateApp(t, appDirStage)})
}

func deployDb(t *testing.T, dbDir string) {
	dbOpts := createDbOpts(t, dbDir)

	// 後から実行される他のテストステージがデータを読み出せるよう、
	// データをディスクに保存
	test_structure.SaveTerraformOptions(t, dbDir, dbOpts)

	terraform.InitAndApply(t, dbOpts)
}

func teardownDb(t *testing.T, dbDir string) {
	dbOpts := test_structure.LoadTerraformOptions(t, dbDir)
	defer terraform.Destroy(t, dbOpts)
}

func deployApp(t *testing.T, dbDir string, helloAppDir string) {
	dbOpts := test_structure.LoadTerraformOptions(t, dbDir)
	helloOpts := createHelloOpts(dbOpts, helloAppDir)

	// 後から実行される他のテストステージがデータを読み出せるよう、
	// データをディスクに保存
	test_structure.SaveTerraformOptions(t, helloAppDir, helloOpts)

	terraform.InitAndApply(t, helloOpts)
}

func teardownApp(t *testing.T, helloAppDir string) {
	helloOpts := test_structure.LoadTerraformOptions(t, helloAppDir)
	validateHelloApp(t, helloOpts)
}

func validateApp(t *testing.T, helloAppDir string) {
	helloOpts := test_structure.LoadTerraformOptions(t, helloAppDir)
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

		//既知のエラーに対し、リトライ感覚5秒のリトライを3回まで実行
		MaxRetries: 3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			"RequestError: send request failed": "Throttling issue?",
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
