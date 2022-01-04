from brownie import network, config, accounts

FORKED_LOCAL_ENVIRONMENTS = ['mainnet-fork', 'mainnet-fork-dev']
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ['development', 'local-ganache']

OPENSEA_URL = "https://testnets.opensea.io/assets/{}/{}"  # rinkeby


def get_account(index=None, id=None):
    # accounts[index]
    # accounts.add('id') --> accounts.load('id')
    if index:
        return accounts[index]
    if id:
        return accounts.load[id]
    if (network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
            or network.show_active() in FORKED_LOCAL_ENVIRONMENTS):
        return accounts[0]
    else:
        return accounts.add(config['wallets']['from_key'])
