
## 概要
Serverless (AWS Lambda)で stable_diffusion.openvino を動かすためのリポジトリです．
### 事前準備
AWS CLI のインストール
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Docker のインストール
- https://docs.docker.com/engine/install/


### デプロイ
```bash:
$ sh ./install.sh
```

## 参考
とりあえずローカルで動かす
- https://softantenna.com/blog/stable-diffusion-intel-cpu

WSL のメモリ不足が発生したら
- https://zenn.dev/suzuki5080/articles/1438d52377b9df

AWS ベースイメージを使った Lambda の作成
- https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/python-image.html

デプロイ用のシェルスクリプト
- https://github.com/densenkouji/stable_diffusion.openvino.lambda

stable_diffusion.openvino 本体 (requirements 要確認)
- https://github.com/bes-dev/stable_diffusion.openvino

Lambda 周りのエラー
- https://motemen.hatenablog.com/entry/2022/12/transformers-lambda
- https://qiita.com/namkim/items/3edb9abe3871963bf0f7

HuggingFace のキャッシュ
- https://huggingface.co/docs/huggingface_hub/en/guides/manage-cache
> The <CACHE_DIR> is usually your user’s home directory. However, it is customizable with the cache_dir argument on all methods, or by specifying either HF_HOME or HF_HUB_CACHE environment variable.
