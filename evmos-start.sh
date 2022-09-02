LOGLEVEL="info"
TRACE="--trace"
CHAINID="evmos_9000-4"
evmosd start --pruning=nothing --fast_sync  --trace $TRACE --log_level $LOGLEVEL --chain-id=$CHAINID --evm.tracer=json --log_format=json --minimum-gas-prices=0.0001atevmos --json-rpc.api eth,txpool,personal,net,debug,web3