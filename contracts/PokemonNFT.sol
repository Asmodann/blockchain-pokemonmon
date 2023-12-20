// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {IERC4906} from '@openzeppelin/contracts/interfaces/IERC4906.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';
// import "@openzeppelin/contracts/access/Ownable.sol";

// TODO: Test call getPokemonData for NFT user

import "./Pokemon.sol";
import {Authorized} from "./Authorized.sol";
import {Counters} from "./Counter.sol";

contract PokemonNFT is IERC4906, Authorized, Pokemon, ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private tokenIds;

    string private imgBaseUri;

    uint256 private nbPokemons;

    mapping(uint256 => pokemon) Pokemons;

    mapping(address => mapping(uint256 => pokemon)) PokemonsUsers;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _imgBaseUri
    ) ERC721(_name, _symbol) Authorized(msg.sender) {
        imgBaseUri = _imgBaseUri;
        _buildPokemons();
    }

    function setImgBaseUri(string memory _imgBaseUri) public onlyAuthorized {
        imgBaseUri = _imgBaseUri;
    }

    function mint(address _account, uint256 _pokemonId) external onlyAuthorized pokemonExist(Pokemons[_pokemonId]._id) {
        require(Pokemons[_pokemonId]._isClaimable, "This pokemon cannot be minted.");

        string memory metadata = _generateBaseMetadata(_pokemonId);
        _mintSingleNFT(_account, metadata, _pokemonId);
    }

    function addPokemon(
        uint256 _pokemonId,
        string memory _name,
        bool _isClaimable,
        uint256 _evolveID,
        string memory _type1,
        string memory _type2
    ) public {
        _initPokemon(_pokemonId, _name, _isClaimable, _evolveID, _type1, _type2);
    }

    function supportsInterface(bytes4 _interfaceId) public view override(IERC165, ERC721, ERC721Enumerable, ERC721URIStorage) returns(bool) {
        return _interfaceId == bytes4(0x49064906) || super.supportsInterface(_interfaceId);
    }

    function tokenURI(uint256 _tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(_tokenId);
    }

    function addType2(uint256 _tokenId, string memory _type2) public {
        require(msg.sender == ownerOf(_tokenId), "This pokemon isn't yours.");

        PokemonsUsers[msg.sender][_tokenId]._attributes[2]._value = _type2;
        _setTokenURI(_tokenId, _generateMintedMetadata(msg.sender, _tokenId));
    }

    function evolve(uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId), "This pokemon isn't yours.");
        pokemon memory _oldPkmn = PokemonsUsers[msg.sender][_tokenId];
        require(_oldPkmn._evolveId > 0, "This pokemon cannot evolve.");
        
        PokemonsUsers[msg.sender][_tokenId] = Pokemons[_oldPkmn._evolveId];

        for (uint8 i = 0; i < _oldPkmn._attributes.length; i++) {
            if (PokemonsUsers[msg.sender][_tokenId]._attributes[i]._isUpdatable) {
                PokemonsUsers[msg.sender][_tokenId]._attributes[i] = _oldPkmn._attributes[i];
            }
        }

        // _burn(_tokenId);

        // _safeMint(msg.sender, _tokenId);
        _setTokenURI(_tokenId, _generateMintedMetadata(msg.sender, _tokenId));
        emit MetadataUpdate(_tokenId);
    }

    function _mintSingleNFT(address _account, string memory _tokenUri, uint256 _pokemonId) internal {
        tokenIds.increment();
        uint256 newTokenId = tokenIds.current();
        _safeMint(_account, newTokenId);
        _setTokenURI(newTokenId, _tokenUri);
        PokemonsUsers[_account][newTokenId] = Pokemons[_pokemonId];
    }

    function _generateBaseMetadata(uint256 _pokemonId) internal view returns(string memory) {
        return _generateMetadata(Pokemons[_pokemonId]);
    }

    function _generateMintedMetadata(address _account, uint256 _tokenId) internal view returns(string memory) {
        require(_account == ownerOf(_tokenId), "This pokemon isn't yours.");

        return _generateMetadata(PokemonsUsers[_account][_tokenId]);
    }

    function _generateMetadata(pokemon memory pkmn) internal view pokemonExist(pkmn._id) returns(string memory) {
        string memory attributesText = "";
        uint256 _attrLength = pkmn._attributes.length;
        for (uint256 i = 0; i < _attrLength; i++) {
            pokemonAttribute memory attribute = pkmn._attributes[i];

            attributesText = string(
                abi.encodePacked(
                    attributesText,
                    '{"trait_type":"', attribute._name,'",',
                    '"value":"', attribute._value,'"}',
                    i == (_attrLength - 1) ? "" : ","
                )
            );
        }

        attributesText = string(abi.encodePacked("[", attributesText, "]"));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{',
                            '"name":"', pkmn._name,'",',
                            '"description":"A simple ', pkmn._name,'.",',
                            '"image":"', imgBaseUri, Strings.toString(pkmn._id),'.jpg",',
                            '"attributes":', attributesText,
                        '}'
                    )
                )
            )
        );

        return string(
            abi.encodePacked("data:application/json;base64,", json)
        );
    }

    function _buildPokemons() internal virtual {
        _initPokemon(BulbasaurID, "Bulbasaur", true, IvysaurID, "Grass", "Poison");
        _initPokemon(IvysaurID, "Ivysaur", false, VenusaurID, "Grass", "Poison");
        _initPokemon(VenusaurID, "Venusaur", false, 0, "Grass", "Poison");

        _initPokemon(CharmanderID, "Charmander", true, CharmeleonID, "Fire", "Empty");
        _initPokemon(CharmeleonID, "Charmeleon", false, CharizardID, "Fire", "Empty");
        _initPokemon(CharizardID, "Charizard", false, 0, "Fire", "Flying");

        _initPokemon(SquirtleID, "Squirtle", true, WartortleID, "Water", "Empty");
        _initPokemon(WartortleID, "Wartortle", false, BlastoiseID, "Water", "Empty");
        _initPokemon(BlastoiseID, "Blastoise", false, 0, "Water", "Empty");
    }

    function _initPokemon(
        uint256 _pokemonId,
        string memory _name,
        bool _isClaimable,
        uint256 _evolveID,
        string memory _type1,
        string memory _type2
    ) internal pokemonNotExist(Pokemons[_pokemonId]._id) {
        pokemon storage pkmn = Pokemons[_pokemonId];

        pkmn._id = _pokemonId;
        pkmn._name = _name;
        pkmn._isClaimable = _isClaimable;
        pkmn._evolveId = _evolveID;

        // _addAttribute(pkmn, "Number", Strings.toString(pkmn._id), false);
        _addAttribute(pkmn, "Type_1", _type1, false);
        _addAttribute(pkmn, "Type_2", _type2, false);
        _addAttribute(pkmn, "Spell_1", "", true);
        _addAttribute(pkmn, "Spell_2", "", true);
        _addAttribute(pkmn, "Spell_3", "", true);
        _addAttribute(pkmn, "Spell_4", "", true);

        Pokemons[_pokemonId] = pkmn;
        nbPokemons++;
    }

    function _addAttribute(pokemon storage _pkmn, string memory _name, string memory _value, bool _isUpdatable) internal {
        _pkmn._attributes.push(pokemonAttribute(_name, _value, _isUpdatable));
    }

    function _increaseBalance(address _account, uint128 _amount) internal virtual override(ERC721, ERC721Enumerable) {
        super._increaseBalance(_account, _amount);
    }

    function _update(address _to, uint256 _tokenId, address _auth) internal virtual override(ERC721, ERC721Enumerable) returns(address) {
        return super._update(_to, _tokenId, _auth);
    }
}