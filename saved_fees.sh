#!/usr/bin/bash

#calculate fee savings made by using Lightning

echo "This script uses sqlite3. If you don't have it, install with 'apt install sqlite3'"

#get command paths for Umbrel <0.5 and 0.5^
lncli_path="./scripts/app compose lightning exec lnd lncli"
bitcoin_cli_path="./scripts/app compose bitcoin exec bitcoind bitcoin-cli"
if [ -e ./bin/lncli ]; then
  lncli_path="./bin/lncli"
fi

if [ -e ./bin/bitcoin-cli ]; then
  bitcoin_cli_path="./bin/bitcoin-cli"
fi

#global vars
FEES_PAID=0
FEES_AVOIDED=0
PAYMENTS_MADE=0

#add block specified by blockheight to the csv file
#bitcoin timestamps aren't very accurate, so we won't burden our computer by
#getting 11 blocks to find the best match
add_to_csv()
{
  #check if block already exists in CSV
  exists=$(sqlite3 :memory: -cmd '.mode csv' -cmd '.import block_timestamps.csv timestamps' -cmd '.mode list' \
  "SELECT COUNT(*) FROM timestamps WHERE blockheight = $1")
  #if not, add it
  if [ $exists -ne 1 ]; then
    block_timestamp=$($bitcoin_cli_path getblockstats $1 | jq ".time")
    echo "$1,$block_timestamp" >> block_timestamps.csv
  fi
}

#prepopulate CSV with blockheight-unixtime relations for every 2016th block
prepopulate_csv()
{
  cursor=499968
  cur_block=$($bitcoin_cli_path getblockcount | sed 's/[[:cntrl:]]//g')
  printf 'Current block: %s\n' "$cur_block"
  #block 499968 is the last difficulty adjustment before LN mainnet launch
  #adding current block as latest reference point
  printf '%s\n' "Populating CSV with difficulty epochs:"
  while [ $cursor -lt $((cur_block)) ]; do
    printf '%i ' $cursor
    #add block to CSV
    add_to_csv $cursor
    #add 2016 to cursor
    cursor=$((cursor+2016))
  done
  printf '%s\n' "done"
  add_to_csv $cur_block
}

if [ ! -e block_timestamps.csv ]; then
  touch block_timestamps.csv
  echo "blockheight,time" >> block_timestamps.csv
else
  echo "block_timestamps.csv found!"
fi

prepopulate_csv

#recursive logic
#for given unix time, check CSV for max-block-before (B4) and min-block-after (AFTER)
#if we know the next block for certain, update onchain fees avoided
#else, recursively call this function after adding the middle block of the range to CSV
recursive_find()
{
  b4=$(sqlite3 :memory: -cmd '.mode csv' -cmd '.import block_timestamps.csv timestamps' -cmd '.mode list' \
         "SELECT blockheight FROM timestamps WHERE time <= $1 ORDER BY time DESC LIMIT 1")
  after=$(sqlite3 :memory: -cmd '.mode csv' -cmd '.import block_timestamps.csv timestamps' -cmd '.mode list' \
         "SELECT blockheight FROM timestamps WHERE time > $1 ORDER BY time ASC LIMIT 1")
  #if AFTER does not exist, print "too recent, fee not finalized"
  if [ -z $after ]; then
    printf "\n%s\n" "Tx too recent, wait for next block to calculate savings"
    return 0
  fi
    
  #$after will never be equal to $b4 due to SQL logic

  #if $after is next to $b4, $after is the block we want
  if [ $after -eq $((b4+1)) ]; then
    #update onchain fees avoided
    get_avoided_fee $1 $after     
  else
    printf "%s" "."
    #else, get middle of range to continue
    sum=$((b4+after))
    middle=$((sum/2))
    add_to_csv $middle
    recursive_find $1
  fi
}

#takes blockheight as argument, updates FEES_AVOIDED
get_avoided_fee()
{
  #calculate onchain fee
  onchain_fee_sats=$(($($bitcoin_cli_path getblockstats $2 | jq -r ".feerate_percentiles[1]")*141))
  onchain_fee_msats=$((onchain_fee_sats*1000))
  FEES_AVOIDED=$((FEES_AVOIDED+onchain_fee_msats))
  printf "%i sat onchain fee avoided!\n" $onchain_fee_sats
}

#main logic
#call listpayments to get a list of LN payments
#for each LN payment, run recursive logic do determine the following block
main()
{
  for row in $($lncli_path listpayments | jq -r ".payments | map({ status: .status, time: .creation_time_ns, fee: .fee_msat})" | jq -c ".[]")
  do
    PAYMENTS_MADE=$((PAYMENTS_MADE+1))
    fee_msats=$(echo $row | jq -r ".fee")
    FEES_PAID=$((FEES_PAID+fee_msats))
    #take first 10 digits of timestamp to match bitcoin timestamp accuracy
    recursive_find $(echo $row | jq -r ".time" | head -c 10)
  done

  #convert display values to sats
  fees_paid_sats=$(awk "BEGIN {print $FEES_PAID/1000}")
  fees_avoided_sats=$(awk "BEGIN {print $FEES_AVOIDED/1000}")
  fees_saved_sats=$(awk "BEGIN {print ($FEES_AVOIDED-$FEES_PAID)/1000}")

  #show fee stats
  printf 'Fees paid: %f sats in %i LN payments\n' $fees_paid_sats $PAYMENTS_MADE
  printf 'Onchain fees avoided: %f sats\n' $fees_avoided_sats
  printf '%s\n' "-----------------------------"
  printf 'Fees saved: %f sats\n' $fees_saved_sats
}

main