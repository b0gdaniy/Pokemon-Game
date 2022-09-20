# POKEMON GAME 

Goerli network:
```
PokemonLevelToken address:  0x5Dd4766194c6a2E5C4994DD52D75909a37c12E91
StoneToken address:  0x26f9A1b798F848F10A8e83bdD874f29055FF856b
PokemonNames address:  0xe2226bA8B8Da6a2edf1878d823f479B64B18DCa8

PokemonToken address:  0x205621FcC47f1b6Be187e8Ff99B653B4A803678B
```

## Smart Contracts Methods

### PokemonLevelToken:
- `receive()` - receives funds and mints tokens for `msg.sender`
- `mint(to,amount)` - mins tokens to `to` with amount `amount` 
(
	REQUIREMENTS: `msg.sender` must be the owner of this contract
)
- `burn(amount)` - burns tokens from `msg.sender` with amount `amount`
For another methods of this contract check {@openzeppelin/contracts/token/ERC20}

### StoneToken:
- `receive()` - receives funds and mints token for `msg.sender`
(
	REQUIREMENTS: `msg.value` must be equal or grater then 0.5 ether
)
- `safeMint(to,tokenId)` - mins tokens to `to` with token id `tokenId`
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
- `stoneType(stoneOwner)` - returns Stone type of `stoneOwner`
(
	REQUIREMENTS: 
	- `to` must have STN
)
- `stoneId(stoneOwner)` - returns Stone token id of `stoneOwner`
(
	REQUIREMENTS: 
	- `to` must have STN
)
- `stoneNameOf(stoneOwner)` - returns Stone name of `stoneOwner`
(
	REQUIREMENTS: 
	- `to` must have STN
)
- `stoneNames(stoneType)` - returns Stone names with `stoneType` index
(
	REQUIREMENTS: 
	- `to` must have STN
)
For another methods of this contract check {NFTTemplate.sol}

### PokemonToken:
- `receive()` - receives funds and mints Pokemon Token for `msg.sender`
(
	REQUIREMENTS: `msg.value` must be equal or grater then 0.01 ether
)
- `createPokemon(tokenId)` - creates a pokemon for `msg.sender`, with random Pokemon types. Started from 1st stage.
(
	REQUIREMENTS: 
	- `msg.sender` must have PLVL token to create
)
- `createPokemonWithIndex(tokenId, index)` - creates a pokemon for `msg.sender`, with `index` Pokemon types. Started from 1st stage.
(
	REQUIREMENTS: 
	- `msg.sender` must be an owner of this contract
    - `msg.sender` must have PLVL token to create
)
- `evolution(tokenId)` - evolves pokemon for `msg.sender`, with `_index` Pokemon types. Changed `_stage` to one more
(
	REQUIREMENTS: 
	- `msg.sender` must be an owner of this contract
    - `msg.sender` must have PLVL token to create
)
- `pokemonLvl()` - returns lvl of `msg.sender`, generates from PLVL balance
- `myPokemon(tokenId)` - returns Pokemon of `msg.sender`
(
	REQUIREMENTS: 
	- `msg.sender` must be an owner of `tokenId`
)
- `myPokemonIndex(tokenId)` - returns Pokemon index of `msg.sender`
(
	REQUIREMENTS: 
	- `msg.sender` must be an owner of `tokenId`
)
- `myPokemonName(tokenId)` - returns Pokemon name of `msg.sender`
(
	REQUIREMENTS: 
	- `msg.sender` must be an owner of `tokenId`
)
- `myPokemonStage(tokenId)` - returns Pokemon stage of `msg.sender`
(
	REQUIREMENTS: 
	- `msg.sender` must be an owner of `tokenId`
)
- `pokemonNames(index,stage)` - returns Pokemon names from {PokemonNames.sol} by `index` and `stage` 
(
	REQUIREMENTS: 
	- `msg.sender` must be an owner of `tokenId`
)
For another methods of this contract check {NFTTemplate.sol}

### PokemonNames (can implement adding and removing names):
- `firstStageNames(index)` - returns first stage name by `index`
- `secondStageNames(index)` - returns second stage name by `index`
- `thirdStageNames(index)` - returns third stage name by `index`

### NFTTemplate:
- `safeMint(to,tokenId)` - mins tokens to `to` with token id `tokenId`
(
	REQUIREMENTS: 
	- `msg.sender` must be an owner of this contract,
)
For another methods of this contract check {@openzeppelin/contracts/token/ERC721}


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
