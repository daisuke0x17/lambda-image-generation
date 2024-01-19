
## 概要
Serverless (AWS Lambda)で stable_diffusion.openvino を動かすためのリポジトリです．
### 準備
AWS CLI のインストール
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Docker のインストール
- https://docs.docker.com/engine/install/

### AWS CLI の設定
AWS Access Key ID, AWS Secret Access Key, Default region name を設定
```bash
$ aws configure
AWS Access Key ID [None]: YOUR ACCESSKEY
AWS Secret Access Key [None]: YOUR SECRETKEY
Default region name [None]: YOUR REGION (ex.us-east-1)
Default output format [None]:
```

### デプロイ
```bash:
$ sh ./install.sh
```
※PC性能，ネットワーク環境によりますが，20分~40分程度は見ておいてください（イメージのビルドとプッシュが重いです）

## 注意事項
- ビルドに時間がかかるのは仕様です
- Lambda のタイムアウトは 15 分，メモリは 10 GB に設定しています
- ECR にプッシュできるイメージの最大サイズは 10 GB です
- Lambda 実行中に書き込み権限があるのは /tmp だけです
  - また実行中に外部との疎通は基本できないので，モデルは事前にダウンロードしてイメージに入れてます

## 参考
とりあえずローカルで動かしてみる（ローカル汚したくない人は venv 使いましょう）
- https://softantenna.com/blog/stable-diffusion-intel-cpu

WSL のメモリ不足が発生したら
- https://zenn.dev/suzuki5080/articles/1438d52377b9df

AWS ベースイメージを使った Lambda の作成
- https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/python-image.html

デプロイ用のシェルスクリプト拝借（イメージのビルドはこける）
- https://github.com/densenkouji/stable_diffusion.openvino.lambda

stable_diffusion.openvino 本体 (requirements 要確認)
- https://github.com/bes-dev/stable_diffusion.openvino

Lambda 特有のエラー
- https://motemen.hatenablog.com/entry/2022/12/transformers-lambda
- https://qiita.com/namkim/items/3edb9abe3871963bf0f7

HuggingFace のキャッシュ
- https://huggingface.co/docs/huggingface_hub/en/guides/manage-cache
> The <CACHE_DIR> is usually your user’s home directory. However, it is customizable with the cache_dir argument on all methods, or by specifying either HF_HOME or HF_HUB_CACHE environment variable.