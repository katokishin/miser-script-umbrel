# miser-script-umbrel
譌･譛ｬ隱樒沿縺ｯ荳矩Κ縺ｫ縺ゅｊ縺ｾ縺吶・

## English

This is a shell script that queries `bitcoin-cli` and `lncli` to estimate how
much your wallet has saved in transaction fees by using LN!

### How to use

Umbrel users (versions 4 and 5) should put `saved_fees.sh` in their Umbrel root
directory, make it executable, and run it as follows:

```
# Check for sqlite3 locally
$Umbrel/    sqlite3 --version
# If ^ does not ouput anything:
$Umbrel/    apt install sqlite3

# Clone this repo and copy the necessary files
$Umbrel/    git clone https://github.com/katokishin/miser-script-umbrel
$Umbrel/    cp miser-script-umbrel/saved_fees.sh saved_fees.sh

# Optional: copy the block_timestamps.csv to save your CPU a few minutes.
# Otherwise the script will generate it automatically.
$Umbrel/    cp miser-script-umbrel/block_timestamps.csv block_timestamps.csv

# Make the script executable, and run it
$Umbrel/    chmod +x saved_fees.sh
$Umbrel/    ./saved_fees.sh
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

## 譌･譛ｬ隱・
`bitcoin-cli`縺ｨ`lncli`繧貞茜逕ｨ縺励※縲√Λ繧､繝医ル繝ｳ繧ｰ繧ｦ繧ｩ繝ｬ繝・ヨ縺ｮ螻･豁ｴ縺九ｉ邏ｯ險医〒繧ｪ繝ｳ繝√ぉ繝ｼ繝ｳ
蜿門ｼ輔→豈斐∋縺ｦ縺ｩ繧後￥繧峨＞縺ｮ謇区焚譁吶ｒ遽邏・〒縺阪◆縺玖｡ｨ遉ｺ縺吶ｋ繧ｹ繧ｯ繝ｪ繝励ヨ縺ｧ縺吶・

### 菴ｿ縺・婿

Umbrel繝ｦ繝ｼ繧ｶ繝ｼ(繝舌・繧ｸ繝ｧ繝ｳ・斐♀繧医・・輔↓蟇ｾ蠢・縺ｯ縲～saved_fees.sh`繧・
Umbrel縺ｮ繝ｫ繝ｼ繝医ョ繧｣繝ｬ繧ｯ繝医Μ縺ｫ蜈･繧後※螳溯｡後＠縺ｦ縺上□縺輔＞縲・

```
# sqlite3縺後う繝ｳ繧ｹ繝医・繝ｫ縺輔ｌ縺ｦ縺・ｋ縺狗｢ｺ隱阪☆繧・
$Umbrel/    sqlite3 --version
# 菴輔ｂ蜃ｺ蜉帙＆繧後↑縺・ｴ蜷医・繧､繝ｳ繧ｹ繝医・繝ｫ縺輔ｌ縺ｦ縺・↑縺・・縺ｧ縲√う繝ｳ繧ｹ繝医・繝ｫ縺吶ｋ
$Umbrel/    apt install sqlite3

# 縺薙・繝ｪ繝昴ず繝医Μ繧偵け繝ｭ繝ｼ繝ｳ縺励※縲∝ｿ・ｦ√↑繝輔ぃ繧､繝ｫ繧偵ム繧ｦ繝ｳ繝ｭ繝ｼ繝峨☆繧・
$Umbrel/    git clone https://github.com/katokishin/miser-script-umbrel
$Umbrel/    cp miser-script-umbrel/saved_fees.sh saved_fees.sh

# 譎ら洒縺ｮ縺溘ａ縺ｫblock_timestamps.csv繧ゅさ繝斐・縺吶ｋ縺薙→縺後〒縺阪∪縺吶・
# 繧ｳ繝斐・縺励↑縺代ｌ縺ｰ繧ｹ繧ｯ繝ｪ繝励ヨ螳溯｡梧凾縺ｫ閾ｪ蜍慕函謌舌＠縺ｾ縺吶・
$Umbrel/    cp miser-script-umbrel/block_timestamps.csv block_timestamps.csv

# 繧ｹ繧ｯ繝ｪ繝励ヨ繧貞ｮ溯｡悟庄閭ｽ縺ｫ縺励※縲∝ｮ溯｡後＠縺ｾ縺・
$Umbrel/    chmod +x saved_fees.sh
$Umbrel/    ./saved_fees.sh
```

Umbrel繝ｦ繝ｼ繧ｶ繝ｼ莉･螟悶ｂ縲～bitcoin-cli`縺ｨ`lncli`縺ｮ繝代せ繧定◇縺九ｌ繧九・縺ｧ縲∝・蜉帙☆繧九％縺ｨ縺ｧ
蛻ｩ逕ｨ縺ｧ縺阪∪縺吶Ａbitcoin-cli`縲～lncli`繧ｳ繝槭Φ繝峨′縺昴・縺ｾ縺ｾ菴ｿ縺医ｋ迺ｰ蠅・〒縺ｯ縲∝・蜉帙☆繧・
蠢・ｦ√ｂ縺ゅｊ縺ｾ縺帙ｓ縲・

### 莉慕ｵ・∩

繧ｪ繝ｳ繝√ぉ繝ｼ繝ｳ謇区焚譁吶・謗ｨ螳壹・縲√が繝ｳ繝√ぉ繝ｼ繝ｳ蜿門ｼ輔・繝・・繧ｿ繧ｵ繧､繧ｺ繧・41繝舌う繝医→莉ｮ螳壹＠縺ｦ縺・∪縺吶・
縺薙ｌ縺ｯ1in2out縺ｮP2WPKH (native segwit)繝医Λ繝ｳ繧ｶ繧ｯ繧ｷ繝ｧ繝ｳ繧呈Φ螳壹＠縺ｦ縺ｮ縺薙→縺ｧ縺吶・

謇区焚譁咏紫縺ｫ髢｢縺励※縺ｯ縲´N縺ｧ騾・≡繧定｡後▲縺滓凾轤ｹ縺九ｉ谺｡縺ｮ繝悶Ο繝・け縺ｮ縲∽ｸ九°繧・5%縺ｮ謇区焚譁咏紫繧・
謗｡逕ｨ縺励∪縺励◆縲ゅ≠縺上∪縺ｧ繧ｱ繝・miser)繧√↑險ｭ螳壹〒縺吶・

繝薙ャ繝医さ繧､繝ｳ縺ｮ繝悶Ο繝・け縺ｫ蜷ｫ縺ｾ繧後ｋ繧ｿ繧､繝繧ｹ繧ｿ繝ｳ繝励・蜑榊ｾ後′蜈･繧梧崛繧上ｋ縺薙→繧ゅ≠繧翫∪縺吶′縲・
`bitcoin-cli getblockstats`縺ｮ螳溯｡梧凾髢薙′髟ｷ縺・・縺ｧ縲∽ｽ吝・縺ｫ繝悶Ο繝・け繧貞叙蠕励＠縺ｦ邊ｾ蠎ｦ繧剃ｸ翫￡繧・
縺薙→繧医ｊ縲√ち繧､繝繧ｹ繧ｿ繝ｳ繝励′譎らｳｻ蛻励〒縺ゅｋ縺ｨ莉ｮ螳壹＠縺溘Ο繧ｸ繝・け繧呈治逕ｨ縺励∪縺励◆縲・

縺薙ｌ繧峨・繝・・繧ｿ縺九ｉ縲～(繧ｪ繝ｳ繝√ぉ繝ｼ繝ｳ騾・≡縺ｪ繧画鴛縺｣縺溘〒縺ゅｍ縺・焔謨ｰ譁・ - (LN縺ｧ螳滄圀縺ｫ謇輔▲縺滓焔謨ｰ譁・`
繧呈ｱゅａ縺ｾ縺励◆縲・
