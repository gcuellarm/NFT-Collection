// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract BANFTCollection is ERC721, Ownable{
    using Strings for uint256;


   // uint256 public tokenId; //Token ID we want to mint
    uint256 public totalSupply;
    string public baseUri;
    bool public mintingPaused; //Default == false
    mapping(uint256 => bool) isMinted;

    event MintNFT(address userAddress, uint256 tokenId_);

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_,  string memory baseUri_) ERC721(name_, symbol_) Ownable(msg.sender){
        totalSupply = totalSupply_;
        baseUri = baseUri_;
    }

    //Burn function
    function burn(uint256 tokenId_) external{
        require(isMinted[tokenId_], "The NFT has not been minted yet");

        _burn(tokenId_);

        //Decrease totalSupply
        totalSupply--;
    }

    //Pause and unpause functions
    function pauseMinting() external onlyOwner(){
        mintingPaused = true;
    }
    function unpauseMinting() external onlyOwner(){
        mintingPaused = false;
    }

    //Mint function
    function mint(uint256 tokenId_) external{
       // tokenId = tokenId_;
        require(totalSupply > 0, "Sold out");
        require(!isMinted[tokenId_], "This NFT has already been minted previously");
        require(!mintingPaused, "Minting is paused right now");

        //Mark the tokenId as minted
        isMinted[tokenId_] = true;

        //Decrease the total supply
        totalSupply--;

        //Mint action 
        _safeMint(msg.sender, tokenId_);

        emit MintNFT(msg.sender, tokenId_);
    }


    function _baseURI() internal override view virtual returns (string memory) {
        return baseUri;
    }

    function tokenURI(uint256 tokenId) public override view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString(), ".json") : "";
    }
}
