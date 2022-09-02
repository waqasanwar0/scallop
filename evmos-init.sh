KEYRING="file" 
KEYALGO="eth_secp256k1"
KEY="newuserkey"
CHAINID="evmos_9000-4"


command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

rm -rf ~/.evmosd/*



evmosd init yourmoniker --chain-id=$CHAINID

# Change parameter token denominations to atevmos
cat $HOME/.evmosd/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="atevmos"' > $HOME/.evmosd/config/tmp_genesis.json && mv $HOME/.evmosd/config/tmp_genesis.json $HOME/.evmosd/config/genesis.json
cat $HOME/.evmosd/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="atevmos"' > $HOME/.evmosd/config/tmp_genesis.json && mv $HOME/.evmosd/config/tmp_genesis.json $HOME/.evmosd/config/genesis.json
cat $HOME/.evmosd/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="atevmos"' > $HOME/.evmosd/config/tmp_genesis.json && mv $HOME/.evmosd/config/tmp_genesis.json $HOME/.evmosd/config/genesis.json
cat $HOME/.evmosd/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="atevmos"' > $HOME/.evmosd/config/tmp_genesis.json && mv $HOME/.evmosd/config/tmp_genesis.json $HOME/.evmosd/config/genesis.json
cat $HOME/.evmosd/config/genesis.json | jq '.app_state["inflation"]["params"]["mint_denom"]="atevmos"' > $HOME/.evmosd/config/tmp_genesis.json && mv $HOME/.evmosd/config/tmp_genesis.json $HOME/.evmosd/config/genesis.json


# increase block time (?)
cat $HOME/.evmosd/config/genesis.json | jq '.consensus_params["block"]["time_iota_ms"]="5000"' > $HOME/.evmosd/config/tmp_genesis.json && mv $HOME/.evmosd/config/tmp_genesis.json $HOME/.evmosd/config/genesis.json

# Set gas limit in genesis
cat $HOME/.evmosd/config/genesis.json | jq '.consensus_params["block"]["max_gas"]="10000000"' > $HOME/.evmosd/config/tmp_genesis.json && mv $HOME/.evmosd/config/tmp_genesis.json $HOME/.evmosd/config/genesis.json


SEEDS=`curl -sL https://raw.githubusercontent.com/tharsis/testnets/main/evmos_9000-4/seeds.txt | awk '{print $1}' | paste -s -d, -`
sed -i.bak -e "s/^seeds =.*/seeds = \"$SEEDS\"/" ~/.evmosd/config/config.toml

PEERS=`curl -sL https://raw.githubusercontent.com/tharsis/testnets/main/evmos_9000-4/peers.txt | sort -R | head -n 10 | awk '{print $1}' | paste -s -d, -`

sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.evmosd/config/config.toml

evmosd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO

evmosd add-genesis-account $KEY 100000000000000000000000000atevmos --keyring-backend $KEYRING

evmosd gentx $KEY 1000000000000000000000atevmos --commission-rate=0.1 --commission-max-rate=1 --commission-max-change-rate=0.1  --pubkey $(evmosd tendermint show-validator)  --keyring-backend $KEYRING  --chain-id=$CHAINID

evmosd collect-gentxs

evmosd validate-genesis
