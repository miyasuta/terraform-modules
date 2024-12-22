package test

import (
	"fmt" // 追加
	"time" // 追加
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	// "github.com/stretchr/testify/require"	
	"testing"	
)

func TestAlbExample(t *testing.T) {
	t.Parallel()

	opts := &terraform.Options{
		// この相対パスは、自分のalbモジュールのexampleディレクトリを指すよう変更すること
		TerraformDir: "../examples/alb",

		Vars: map[string]interface{}{
			"alb_name": fmt.Sprintf("test-%s", random.UniqueId()),
		},
	}

	//テストの後にすべてを後片付け
	defer terraform.Destroy(t, opts)
	
	//サンプルをデプロイ
	terraform.InitAndApply(t, opts)

	//ALBのURLを取得
	albDnsName := terraform.OutputRequired(t, opts, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

	//ALBのデフォルトアクションが動作し、404を返すことをテスト
	expectedStatus := 404
	expectedBody := "404: page not found"
	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetry(
		t,
		url,
		nil,
		expectedStatus,
		expectedBody,
		maxRetries,
		timeBetweenRetries,
	)
}