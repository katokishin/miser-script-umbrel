# miser-script-umbrel
日本語版は下部にあります。

## English

This is a shell script that queries `bitcoin-cli` and `lncli` to estimate how
much your wallet has saved in transaction fees by using LN!

### How to use

Umbrel users (versions 4 and 5) should put `fees_saved.sh` in their Umbrel root
directory, make it executable, and run it as follows:

```
# Check for sqlite3 locally
$Umbrel/    sqlite3 --version
# If ^ does not ouput anything:
$Umbrel/    apt install sqlite3

# Clone this repo and copy the necessary files
$Umbrel/    git clone https://github.com/katokishin/miser-script-umbrel
$Umbrel/    cp miser-script-umbrel/fees_saved.sh fees_saved.sh

# Optional: copy the block_timestamps.csv to save your CPU a few minutes.
# Otherwise the script will generate it automatically.
$Umbrel/    cp miser-script-umbrel/block_timestamps.csv block_timestamps.csv

# Make the script executable, and run it
$Umbrel/    chmod +x fees_saved.sh
$Umbrel/    ./fees_saved.sh
```

Non-Umbrel users can also use the script by typing in the path to `lncli` and
`bitcoin-cli` when the script asks for these paths. The script also checks if
`lncli` and `bitcoin-cli` can be found in $PATH.

### How it works

Onchain fee estimation is done by assuming all onchain payments would have been
1in2out P2WPKH (native segwit) txs, which are 141 bytes in size.

For the feerate, we get the 25th-percentile feerate for the block following the
LN transaction. We're using LN because we're misers, right!?

Although Bitcoin block timestamps are not necessarily accurate, since 
`bitcoin-cli getblockstats` is a very slow command, getting +/- 5 blocks for
accuracy get expensive quickly. Instead we simply assume that block timestamps
are chronological.

Finally, we calculate `(total on-chain hypothetical fees) - (total LN fees)`.

## 日本語
`bitcoin-cli`と`lncli`を利用して、ライトニングウォレットの履歴から累計でオンチェーン
取引と比べてどれくらいの手数料を節約できたか表示するスクリプトです。

### 使い方

Umbrelユーザー(バージョン４および５に対応)は、`fees_saved.sh`を
Umbrelのルートディレクトリに入れて実行してください。

```
# sqlite3がインストールされているか確認する
$Umbrel/    sqlite3 --version
# 何も出力されない場合はインストールされていないので、インストールする
$Umbrel/    apt install sqlite3

# このリポジトリをクローンして、必要なファイルをダウンロードする
$Umbrel/    git clone https://github.com/katokishin/miser-script-umbrel
$Umbrel/    cp miser-script-umbrel/fees_saved.sh fees_saved.sh

# 時短のためにblock_timestamps.csvもコピーすることができます。
# コピーしなければスクリプト実行時に自動生成します。
$Umbrel/    cp miser-script-umbrel/block_timestamps.csv block_timestamps.csv

# スクリプトを実行可能にして、実行します
$Umbrel/    chmod +x fees_saved.sh
$Umbrel/    ./fees_saved.sh
```

Umbrelユーザー以外も、`bitcoin-cli`と`lncli`のパスを聞かれるので、入力することで
利用できます。`bitcoin-cli`、`lncli`コマンドがそのまま使える環境では、入力する
必要もありません。

### 仕組み

オンチェーン手数料の推定は、オンチェーン取引のデータサイズを141バイトと仮定しています。
これは1in2outのP2WPKH (native segwit)トランザクションを想定してのことです。

手数料率に関しては、LNで送金を行った時点から次のブロックの、下から25%の手数料率を
採用しました。あくまでケチ(miser)めな設定です。

ビットコインのブロックに含まれるタイムスタンプは前後が入れ替わることもありますが、 
`bitcoin-cli getblockstats`の実行時間が長いので、余分にブロックを取得して精度を上げる
ことより、タイムスタンプが時系列であると仮定したロジックを採用しました。

これらのデータから、`(オンチェーン送金なら払ったであろう手数料) - (LNで実際に払った手数料)`
を求めました。
