# no shebang because i'm annoying

# contents of genesis.json at time of writing, as a backup
: '
{
  "nonce": "0x0000000000000042",
  "timestamp": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "extraData": "0x00",
  "gasLimit": "0x8000000",
  "difficulty": "0x400",
  "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x3333333333333333333333333333333333333333",
  "alloc": {},
  "config": {
    "chainId": 987,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0
  }
}
'

if ! [ -f ./geth ]; then echo "./geth not present"; exit 1; fi
if ! [ -f ./genesis.json ]; then echo "./genesis.json not present"; exit 1; fi
if [ -d ./data ]; then echo "data dir exists, clearing"; rm -rf ./data; mkdir data; fi
if ! which expect > /dev/null 2>&1; then echo "expect command missing"; exit 1; fi
echo "running init"
./geth --rpc --rpcport "8085" --datadir ./data init ./genesis.json > ./data/init_log 2>&1
wait
if [ $? != 0 ]; then echo "init failed"; exit 1; fi
echo "starting server in background"
./geth --rpc --rpcport "8085" --datadir ./data --nodiscover --networkid 41900 --maxpeers 0 --rpcaddr "0.0.0.0" --rpccorsdomain "*" --rpcapi "eth,net,personal,debug" --allow-insecure-unlock > ./data/run_log 2>&1 &
echo "waiting until ipc exists"
while ! grep "IPC" .data/run_log; do
  sleep 0.1
done
# echo "assuming it worked because i don't know how to check. continuing in 5"
# for i in {4..1}; do
#   sleep 1
#   echo "$i"
# done
echo "launching js console with expect"
expect ./js_console.tcl
wait
kill %1
