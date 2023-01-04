Censo Ethereum Contracts
========================

Usage
-----
### Install requirements with yarn:

```bash
yarn
```

### Build:

```bash
yarn build
```

### Deployments

```bash
yarn hardhat deploy
```

Documentation
-------------

The contracts here are part of Censo's implementation of Gnosis' [Safe](http://docs.gnosis.io/safe).

Censo uses a two-level structure with "vaults" that control the configuration of one or more individual
"wallets", each of which have their own policy for controlling transfers and dapp transactions. In this
model, both vaults and wallets are implemented as Safes; the owners of the vault Safe control both its
configuration as well as the configuration of that vault's wallets.

This is implemented by configuring the wallets with a guard which prohibits any transactions that might
alter the state of the wallet Safe (thus preventing the owners of the wallet from configuring it) and by
enabling the vault Safe as a module on the wallet Safe, which allows the owners of the vault to configure
the wallets. 

Censo has also implemented additional features on wallets: whitelisting, the ability to have a wallet
which can do basic transfers (including ERC-20, ERC-721 and ERC-1155 transfers) but not general dapp
transactions, and the ability to associate a name hash with the wallet.

- contracts/CensoSetup.sol - setup delegate contract used for initializing wallets
- contracts/CensoFallbackHandler.sol - fallback handler implementing whitelisting and name hash functions
- contracts/CensoGuard.sol - default guard for a wallet with whitelisting off and dapp transactions allowed
- contracts/CensoWhitelistingGuard.sol - guard with whitelisting on and dapp transactions allowed
- contracts/CensoTransfersOnlyGuard.sol - guard with whitelisting off and dapp transactions not allowed
- contracts/CensoTransfersOnlyWhitelistingGuard.sol - guard with whitelisting on but no dapp transactions

Audits / Formal Verification
----------------------------

TBA

Security and Liability
----------------------
All contracts are WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

License
-------
All smart contracts are released under GPL-3.0
