// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BANFTCollection} from "../src/MyBA-NFTCollection.sol";


contract DeployNFTCollection is Script{

    function run() external returns(BANFTCollection){
        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory name_ = "Blockchain Accelerator NFT";
        string memory symbol_ = "BANFT";
        uint256 totalSupply_ = 2;
        string memory baseUri_ = "ipfs://bafybeig6gygjx4vq5ihsl5ugxrwkpbzbyyree2l3mv2nrioaletzq7xyoe/";
        BANFTCollection nftCollection = new BANFTCollection(name_, symbol_, totalSupply_, baseUri_);
        
        vm.stopBroadcast();
        return nftCollection;
    }
}