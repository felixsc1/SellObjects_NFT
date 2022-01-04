import pytest
from web3 import Web3


@pytest.fixture
def current_price():
    return Web3.toWei(80, "ether")
