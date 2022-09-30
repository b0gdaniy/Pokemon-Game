<h1 align="center">
<img src='https://www.pngall.com/wp-content/uploads/4/Pokeball-PNG-Images.png' width = '50' height = '50'/>
POKEMON GAME
<img src='https://www.pngall.com/wp-content/uploads/4/Pokeball-PNG-Images.png' width = '50' height = '50'/>
</h1>
<p align='center'>
    <img src='https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/International_Pok%C3%A9mon_logo.svg/2560px-International_Pok%C3%A9mon_logo.svg.png'/>
</p>

<h2 align="center">
<img src='https://avatars.githubusercontent.com/u/43071041?s=280&v=4' width = '30' height = '30'/>
GOERLI NETWORK
<img src='https://avatars.githubusercontent.com/u/43071041?s=280&v=4' width = '30' height = '30'/>
</h2>

```
PokemonLevelToken address:  0x5Dd4766194c6a2E5C4994DD52D75909a37c12E91
StoneToken address:  0x26f9A1b798F848F10A8e83bdD874f29055FF856b
PokemonNames address:  0xe2226bA8B8Da6a2edf1878d823f479B64B18DCa8

PokemonToken address:  0x205621FcC47f1b6Be187e8Ff99B653B4A803678B
```

<h2 align="center">
<img src='https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Solidity_logo.svg/1200px-Solidity_logo.svg.png' width = '20' height = '30'/>
SMART CONTRACTS METHODS
<img src='https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Solidity_logo.svg/1200px-Solidity_logo.svg.png' width = '20' height = '30'/>
</h2>

<h3 align="center">🆙 PokemonLevelToken</h3>

- `receive()` - receives funds and mints tokens for `msg.sender`.
- `mint(to,amount)` - mins tokens to `to` with amount `amount`.

(REQUIREMENTS: `msg.sender` must be the owner of this contract)
- `burn(amount)` - burns tokens from `msg.sender` with amount `amount`.
For another methods of this contract check {@openzeppelin/contracts/token/ERC20}

<h3 align="center">🪨 StoneToken</h3>

- `receive()` - receives funds and mints token for `msg.sender`.

(REQUIREMENTS: `msg.value` must be equal or grater then 0.5 ether)
- `safeMint(to,tokenId)` - mins tokens to `to` with token id `tokenId`.

(REQUIREMENTS: 
	- `msg.sender` must be the owner of this contract,
	- `msg.sender` cant have STN)
- `deleteStone(tokenId)` - deletes Stone from `tx.origin` with token id `tokenId`.

(REQUIREMENTS: 
	- `tx.origin` must have STN,
	- `tx.origin` must be an owner of token with `tokenId`)
- `createStone(tokenId)` - creates Stone to `msg.sender` with random type.

(REQUIREMENTS: 
	- `msg.sender` must have STN,
	- `msg.sender` mustn't have Stone)
- `createStoneWithIndexTo(to, index)` - creates Stone to `to` with `index` type.

(REQUIREMENTS: 
	- `to` must have STN,
	- `to` mustn't have Stone)
- `stoneType(stoneOwner)` - returns Stone type of `stoneOwner`.

(REQUIREMENTS: 
	- `to` must have STN)
- `stoneId(stoneOwner)` - returns Stone token id of `stoneOwner`.

(REQUIREMENTS: 
	- `to` must have STN)
- `stoneNameOf(stoneOwner)` - returns Stone name of `stoneOwner`.

(REQUIREMENTS: 
	- `to` must have STN)
- `stoneNames(stoneType)` - returns Stone names with `stoneType` index.

For another methods of this contract check {NFTTemplate.sol}

<h3 align="center">
<img src='https://www.pngall.com/wp-content/uploads/4/Pokeball-PNG-Images.png' width = '20' height = '20'/>
PokemonToken
</h3>

- `receive()` - receives funds and mints Pokemon Token for `msg.sender`.

(REQUIREMENTS: `msg.value` must be equal or grater then 0.01 ether)
- `createPokemon(tokenId)` - creates a pokemon for `msg.sender`, with random Pokemon types. Started from 1st stage.

(REQUIREMENTS: 
	- `msg.sender` must have PLVL token to create)
- `createPokemonWithIndex(tokenId, index)` - creates a pokemon for `msg.sender`, with `index` Pokemon types. Started from 1st stage.

(REQUIREMENTS: 
	- `msg.sender` must be an owner of this contract
    - `msg.sender` must have PLVL token to create)
- `evolution(tokenId)` - evolves pokemon for `msg.sender`, with `_index` Pokemon types. Changed `_stage` to one more.

(REQUIREMENTS: 
	- `msg.sender` must be an owner of this contract
    - `msg.sender` must have PLVL token to create)
- `pokemonLvl()` - returns lvl of `msg.sender`, generates from PLVL balance.

- `myPokemon(tokenId)` - returns Pokemon of `msg.sender`.

(REQUIREMENTS: 
	- `msg.sender` must be an owner of `tokenId`)
- `myPokemonIndex(tokenId)` - returns Pokemon index of `msg.sender`.

(REQUIREMENTS: 
	- `msg.sender` must be an owner of `tokenId`)
- `myPokemonName(tokenId)` - returns Pokemon name of `msg.sender`.

(REQUIREMENTS: 
	- `msg.sender` must be an owner of `tokenId`)
- `myPokemonStage(tokenId)` - returns Pokemon stage of `msg.sender`.

(REQUIREMENTS: 
	- `msg.sender` must be an owner of `tokenId`)
- `pokemonNames(index,stage)` - returns Pokemon names from {PokemonNames.sol} by `index` and `stage`.

For another methods of this contract check {NFTTemplate.sol}

<h3 align="center">☑️PokemonNames</h3>

(can implement adding and removing names)
- `firstStageNames(index)` - returns first stage name by `index`
- `secondStageNames(index)` - returns second stage name by `index`
- `thirdStageNames(index)` - returns third stage name by `index`

<h3 align="center">
<img src='https://upload.wikimedia.org/wikipedia/commons/2/24/NFT_Icon.png' width = '30' height = '30'/>
 NFTTemplate
</h3>

- `withdrawAll()` - withdraws all funds in contract.

(REQUIREMENTS: -`msg.sender` must be the owner of this contract)
- `withdraw(amount)` - withdraws `_amount` funds in contract.

(REQUIREMENTS: `msg.sender` must be the owner of this contract)
- `safeMint(to,tokenId)` - mins tokens to `to` with token id `tokenId`.

(REQUIREMENTS: 
	- `msg.sender` must be an owner of this contract,
	- `tokenId` must not exist,
	-If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.)
	
For another methods of this contract check {@openzeppelin/contracts/token/ERC721}


<h2 align="center">👷‍♂️HOW TO USE HARDHAT IN THIS PROJECT👷‍♂️</h2>

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
GAS_REPORT=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
