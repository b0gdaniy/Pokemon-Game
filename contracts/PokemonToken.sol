// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./NFTTemplate.sol";
import "./PokemonLevelToken.sol";
import "./StoneToken.sol";

contract PokemonToken is NFTTemplate {
    PokemonLevelToken public lvlToken;
    StoneToken public stoneToken;

    enum PokemonsNum {
        Poliwag,
        Onix,
        Squirtle
    }

    struct Pokemon {
        string name;
        PokemonsNum index;
        uint256 level;
        uint256 stage;
    }

    uint256 public constant TOKEN_PRICE = 0.01 ether;

    uint256 internal _currentTokenId;
    mapping(address => mapping(uint256 => Pokemon)) internal _pokemonOf;

    modifier lvlUpdate(uint256 _tokenId) {
        uint256 _pokemonLvl = pokemonLvl();
        _pokemonOf[msg.sender][_tokenId].level = _pokemonLvl;

        _;
    }

    modifier reqOwner(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "You don't have PKMN token");
        _;
    }

    constructor(PokemonLevelToken _lvlToken, StoneToken _stoneToken)
        NFTTemplate("Pokemon", "PKMN")
    {
        lvlToken = _lvlToken;
        stoneToken = _stoneToken;
    }

    receive() external payable {
        require(
            msg.value >= TOKEN_PRICE,
            "Sending amount must be more than 0.01 ETH"
        );

        _mintToken(msg.sender);
    }

    function createPokemon(uint256 _tokenId) external reqOwner(_tokenId) {
        _createPokemon(_tokenId, random(), 1);
    }

    function createPokemon(
        uint256 _tokenId,
        uint256 _index,
        uint256 _stage
    ) external onlyOwner {
        _createPokemon(_tokenId, _index, _stage);
    }

    function evolution(uint256 _tokenId)
        external
        lvlUpdate(_tokenId)
        reqOwner(_tokenId)
    {
        Pokemon memory pokemon = _pokemonOf[msg.sender][_tokenId];

        uint256 _stage = pokemon.stage;
        require(_stage < 3, "Your pokemon can no longer evolve");

        PokemonsNum _index = pokemon.index;
        uint256 currentLevel = pokemon.level;
        uint256 _evoPrice = evoPrice(_index, _stage);

        _deletePokemon(msg.sender, _tokenId);

        if (_index == PokemonsNum.Squirtle) {
            require(currentLevel >= _evoPrice, "You need more level to evolve");
            lvlToken.burn(lvlToken.balanceOf(msg.sender));
        } else if (_index == PokemonsNum.Poliwag) {
            if (_stage == 1) {}
            require(
                stoneToken.balanceOf(msg.sender) > 0,
                "You don't have stone for evolve"
            );
        }

        _mintToken(msg.sender);

        _createPokemon(_currentTokenId - 1, uint256(_index), _stage + 1);
    }

    function currentTokenId() public view returns (uint256) {
        return _currentTokenId;
    }

    function pokemonLvl() public view returns (uint256) {
        return lvlToken.balanceOf(msg.sender) / _lvlTokensMultiplier();
    }

    function pokemonNames(uint256 index, uint256 stage)
        public
        pure
        returns (string memory)
    {
        string[3] memory firstStageNames = ["Polywag", "Onix", "Squirtle"];
        string[3] memory secondStageNames = [
            "Polywhirl",
            "Steelix",
            "Wartortle"
        ];
        string[3] memory thirdStageNames = [
            "Poliwrath",
            "Politoed",
            "Blastoise"
        ];

        if (stage == 2) {
            return secondStageNames[index];
        } else if (stage == 3) {
            return thirdStageNames[index];
        }

        return firstStageNames[index];
    }

    function evoPrice(PokemonsNum index, uint256 stage)
        public
        pure
        returns (uint256)
    {
        if (index == PokemonsNum.Squirtle) {
            if (stage == 2) {
                return 36;
            }
            return 16;
        } else if (index == PokemonsNum.Poliwag) {
            if (stage == 1) {
                return 25;
            }
        }
        revert("Your pokemon needs a stone to evolve");
    }

    function _createPokemon(
        uint256 _tokenId,
        uint256 _index,
        uint256 _stage
    ) internal {
        uint256 _pokemonLvl = pokemonLvl();

        require(_pokemonLvl > 0, "You don't have PLVL tokens");
        require(ownerOf(_tokenId) == msg.sender, "You don't have PKMN token");

        Pokemon memory pokemon = Pokemon({
            name: pokemonNames(_index, _stage),
            index: PokemonsNum(_index),
            level: _pokemonLvl,
            stage: _stage
        });

        _pokemonOf[msg.sender][_tokenId] = pokemon;
    }

    // function _straightFlowEvo(
    //     uint256 stage,
    //     uint256 index,
    //     uint256 level,
    //     uint256 evoPrice
    // ) internal pure returns (string memory) {
    //     // evo price variability can be implemented
    //     require(level >= evoPrice, "You don't have enough level to evo");

    //     if (stage == 1) {
    //         return pokemonNames(index, stage);
    //     } else if (stage == 2) {}
    // }

    function _deletePokemon(address pokemonOwner, uint256 _tokenId) internal {
        require(
            _isApprovedOrOwner(pokemonOwner, _tokenId),
            "Not an owner of token or approved for it"
        );
        _burn(_tokenId);

        delete _pokemonOf[pokemonOwner][_tokenId];
    }

    function _mintToken(address to) private {
        safeMint(to, _currentTokenId);
        _currentTokenId++;
    }

    function _lvlTokensMultiplier() private view returns (uint256) {
        return 10**lvlToken.decimals();
    }
}

// function _compareStrings(string memory x, string memory y)
//     private
//     pure
//     returns (bool)
// {
//     return keccak256(abi.encodePacked(x)) == keccak256(abi.encodePacked(y));
// }

// function _evolutionProggress(
//     PokemonsNum _index,
//     uint256 stage,
//     uint256 level
// ) private pure returns (uint256) {
//     // If `level` grater then 0 - means that the pokemon has straight flow evo
//     if (level > 0) {
//         // If `stage` is equal to 1: returns 1 - means that the pokemon was not evolved
//         if (stage == 1) {
//             return 1;
//         }
//         // If `stage` is gater then 1: returns 2 - means that the pokemon was evolved
//         return 2;
//     } else {
//         // If `level` is equal to 0: retuns 0 - means that the pokemon has stone evo
//         return 0;
//     }

//     // // If `stage` grater then 1 returns 1 - means that the pokemon was evolved
//     // if (stage > 1) {
//     //     // If `level` grater then 0: returns 1 - means that the pokemon was evolved and has straight flow evo
//     //     if (level > 0) {
//     //         return 1;
//     //     } else if (level == 0) {
//     //         // If `level` is equal to 0: returns 2 - means that the pokemon was evolved and has stone evo
//     //         return 2;
//     //     }
//     // } else {
//     //     // Else: returns 0 - means that the pokemon wasnt evolved
//     //     return 0;
//     // }
// }
