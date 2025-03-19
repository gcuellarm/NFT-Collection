# 🚀 NFT Collection Smart Contract

This repository contains a smart contract for an NFT collection using Solidity, based on OpenZeppelin's standards, deployed on Ethereum (or compatible chains). The contract allows users to mint, burn and pause/unpause NFTs.

Additionally, tests are included using Foundry to ensure the contract behaves as expected.



## 🌐 Smart Contract Overview

### 📚 BA-NFTCollection

The `BANFTCollection` contract is an ERC721-compliant NFT collection with the following features:

- **Burn function**: possibility to burn tokens.
- **Pause & unpause functions**: Only the owner can execute them. Pause or unpase the activity.
- **Token URI Generation**: Token URIs are dynamically generated using a base URI.
- **Owner Controls**: The contract owner can execute som specefic actions that the others can't.

### 📜 Contract Code

```solidity
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract BANFTCollection is ERC721, Ownable{
    using Strings for uint256;

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
```
### ⚙️ Contract Functions
- **`burn(tokenId_)`**: Burns a NFT token (previously minted).
- **`pauseMinting`**: Sets the bool *mintingPaused* to true.
- **`unpauseMinting`**: Sets the bool *mintingPaused* to false.
- **`mint(uint256 tokenId_)`**: Mints a new NFT for the sender, sending the tokenId as a parameter.
- **`_baseURI()`**: Returns the base URI for token metadata.
- **`tokenURI(uint256 tokenId)`**: Returns the URI for a specific token, based on the token's ID.


## 🛠️ Setup and Installation
### Prerequisites
- **Foundry**: Ensure that you have Foundry installed. You can install it using the following command:
```curl -L https://foundry.paradigm.xyz | bash```
- **Visual Studio Code**: Ensure that you have Visual Studio Code (VS Code) installed.

### Setups to run the app
1. **Clone the Repository**:
```
git clone <your-repository-url>
cd <your-project-directory> 
```
2. **Install OpenZeppelin Contracts**: In your project directory, run the following command to install OpenZeppelin contracts:
```
forge install OpenZeppelin/openzeppelin-contracts
```

3. **Compile the Contracts**: Use Foundry's forge to compile the contracts:
```
forge build
```
4. **Deploy the Contracts**:You can deploy the contracts using the following command (make sure to configure your deployment settings):
```
forge deploy
```

## Contributing

Feel free to open issues or submit pull requests if you want to contribute improvements or bug fixes.




## License

This project is licensed under the LGPL-3.0-only License.
