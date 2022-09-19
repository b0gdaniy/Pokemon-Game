# POKEMON GAME 

Goerli network:
```
PokemonLevelToken address:  0x5Dd4766194c6a2E5C4994DD52D75909a37c12E91
StoneToken address:  0x26f9A1b798F848F10A8e83bdD874f29055FF856b
PokemonNames address:  0xe2226bA8B8Da6a2edf1878d823f479B64B18DCa8

PokemonToken address:  0x205621FcC47f1b6Be187e8Ff99B653B4A803678B
```

## Smart Contracts Methods

- PokemonLevelToken:
- `receive()` - receives funds and mints tokens for `msg.sender`
- `mint(to,amount)` - mins tokens to `to` with amount `amount` 
(
	REQUIREMENTS: `msg.sender` must be the owner of this contract
)
- `burn(amount)` - burns tokens from `msg.sender` with amount `amount`
For another methods of this contract check {@openzeppelin/contracts/token/ERC20}

- StoneToken:
- `receive()` - receives funds and mints token for `msg.sender`
(
	REQUIREMENTS: `msg.value` must be equal or grater then 0.5 ether
)
- `safeMint(to,tokenId)` - mins tokens to `to` with amount `tokenId`
(
	REQUIREMENTS: 
	- `msg.sender` must be the owner of this contract,
	- `msg.sender` cant have STN
)
- `deleteStone(tokenId)` - deletes Stone from `tx.origin` with token id `tokenId`
(
	REQUIREMENTS: 
	- `tx.origin` must have STN,
	- `tx.origin` must be an owner of token with `tokenId`
)
- `createStone(tokenId)` - creates Stone to `msg.sender` with random type
(
	REQUIREMENTS: 
	- `msg.sender` must have STN,
	- `msg.sender` mustn't have Stone
)
- `createStoneWithIndexTo(to, index)` - creates Stone to `to` with `index` type
(
	REQUIREMENTS: 
	- `to` must have STN,
	- `to` mustn't have Stone
)
For another methods of this contract check 
{@openzeppelin/contracts/token/ERC721}


## Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
GAS_REPORT=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
