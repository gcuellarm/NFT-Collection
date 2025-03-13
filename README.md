# 🚀 NFT Collection Smart Contract

This repository contains a smart contract for an NFT collection using Solidity, based on OpenZeppelin's standards, deployed on Ethereum (or compatible chains). The contract allows users to mint NFTs in a whitelist-based system with various controls, including a maximum mint limit per user and the ability to set a Merkle root for whitelist verification.

Additionally, tests are included using Foundry to ensure the contract behaves as expected.



## 🌐 Smart Contract Overview

### 📚 BA-NFTCollection

The `BANFTCollection` contract is an ERC721-compliant NFT collection with the following features:

- **Whitelist Minting**: Only users on the whitelist can mint NFTs.
- **Maximum Mint Limit**: Each user can mint a maximum of one NFT.
- **Merkle Root Verification**: A Merkle root is used to verify if a user is whitelisted for minting.
- **Token URI Generation**: Token URIs are dynamically generated using a base URI.
- **Owner Controls**: The contract owner can toggle whitelist minting and set the Merkle root.

### 📜 Contract Code

```solidity
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract BANFTCollection is ERC721, Ownable {
    using Strings for uint256;

    uint256 public currentTokenId; // Counter for tokens minted
    uint256 public totalSupply;
    string public baseUri;
    bytes32 public merkleRoot;
    uint256 public maxMintedPerUser;
    bool public isWhitelistMintActive = false;
    mapping(address => uint256) public mintedPerUser;
    mapping(address => bool) public hasMinted;

    event MintNFT(address userAddress, uint256 tokenId_);

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_, uint256 maxMintedPerUser_, string memory baseUri_) ERC721(name_, symbol_) {
        totalSupply = totalSupply_;
        maxMintedPerUser = maxMintedPerUser_;
        baseUri = baseUri_;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function toggleWhitelistMint() external onlyOwner {
        isWhitelistMintActive = !isWhitelistMintActive;
    }

    function mint(bytes32[] calldata _merkleProof, uint256 amount_) external {
        require(isWhitelistMintActive, "Whitelist mint is not active");
        require(currentTokenId < totalSupply, "Sold out");
        require(mintedPerUser[msg.sender] + amount_ <= maxMintedPerUser, "Max amount per user minted");
        require(!hasMinted[msg.sender], "Already minted");
        require(amount_ == 1, "You can only mint one NFT at a time");

        // Verify the user is in the whitelist
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid proof");

        hasMinted[msg.sender] = true;
        _safeMint(msg.sender, currentTokenId);
        uint256 id = currentTokenId;
        currentTokenId++;

        emit MintNFT(msg.sender, id);
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
- **`setMerkleRoot(bytes32 _merkleRoot)`**: Sets the Merkle root for whitelisted users.
- **`toggleWhitelistMint()`**: Enables or disables the whitelist minting feature.
- **`mint(bytes32[] calldata _merkleProof, uint256 amount_)`**: Mints a new NFT for the sender if they are on the whitelist, haven't minted before, and comply with the minting limits.
- **`_baseURI()`**: Returns the base URI for token metadata.
- **`tokenURI(uint256 tokenId)`**: Returns the URI for a specific token, based on the token's ID.

## 🌐 Tests Overview
The following tests are written in Solidity using Foundry and cover various aspects of the smart contract, including minting functionality, whitelist validation, minting limits, and token URI generation.
```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {BANFTCollection} from "../src/BANFTCollection.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract BANFTCollectionTest is Test {
    BANFTCollection public nftContract;
    address public owner;
    address public user;
    bytes32 public merkleRoot;
    bytes32 public userLeaf;
    
    uint256 public totalSupply = 5;
    uint256 public maxMintedPerUser = 1;
    string public baseUri = "https://example.com/metadata/";

    function setUp() public {
        owner = address(this);
        user = address(0x123);
        
        // Deploy the contract
        nftContract = new BANFTCollection("BANFT", "BFT", totalSupply, maxMintedPerUser, baseUri);

        // Set the merkle root and whitelist the user
        userLeaf = keccak256(abi.encodePacked(user));
        merkleRoot = userLeaf;  // Just a simple case for the test
        nftContract.setMerkleRoot(merkleRoot);

        // Activate whitelist mint
        nftContract.toggleWhitelistMint();
    }

    function testMintSuccess() public {
        bytes32;
        proof[0] = userLeaf;

        vm.startPrank(user);
        nftContract.mint(proof, 1);
        vm.stopPrank();

        assertEq(nftContract.currentTokenId(), 1);
        assertEq(nftContract.ownerOf(0), user);
    }

    function testMintAlreadyMinted() public {
        bytes32;
        proof[0] = userLeaf;

        vm.startPrank(user);
        nftContract.mint(proof, 1);
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert("Already minted");
        nftContract.mint(proof, 1);
        vm.stopPrank();
    }

    function testMintNotWhitelisted() public {
        address nonWhitelistedUser = address(0x456);
        bytes32;
        proof[0] = keccak256(abi.encodePacked(nonWhitelistedUser));

        vm.startPrank(nonWhitelistedUser);
        vm.expectRevert("Invalid proof");
        nftContract.mint(proof, 1);
        vm.stopPrank();
    }

    function testMintExceedsMaxPerUser() public {
        bytes32;
        proof[0] = userLeaf;
        vm.startPrank(user);
        nftContract.mint(proof, 1);
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert("Max amount per user minted");
        nftContract.mint(proof, 1);
        vm.stopPrank();
    }

    function testMintSoldOut() public {
        for (uint256 i = 0; i < totalSupply; i++) {
            bytes32;
            proof[0] = userLeaf;
            vm.startPrank(user);
            nftContract.mint(proof, 1);
            vm.stopPrank();
        }

        bytes32;
        proof[0] = userLeaf;
        vm.startPrank(user);
        vm.expectRevert("Sold out");
        nftContract.mint(proof, 1);
        vm.stopPrank();
    }

    function testToggleWhitelistMint() public {
        assertTrue(nftContract.isWhitelistMintActive());
        nftContract.toggleWhitelistMint();
        assertFalse(nftContract.isWhitelistMintActive());

        nftContract.toggleWhitelistMint();
        assertTrue(nftContract.isWhitelistMintActive());
    }

    function testTokenURI() public {
        bytes32;
        proof[0] = userLeaf;

        vm.startPrank(user);
        nftContract.mint(proof, 1);
        vm.stopPrank();

        string memory expectedUri = string(abi.encodePacked(baseUri, "0.json"));
        assertEq(nftContract.tokenURI(0), expectedUri);
    }
}
```

### ✏️ Test descriptions
1. **`testMintSuccess()`**: This test simulates a successful mint by a whitelisted user. It verifies that the NFT is minted, the token ID is incremented, and the owner of the minted token is correct.
2. **`testMintAlreadyMinted()`**: This test ensures that a user who has already minted an NFT cannot mint again. It verifies that the contract properly reverts with the "Already minted" error.
3. **`testMintNotWhitelisted()`**: This test checks that a user who is not on the whitelist cannot mint an NFT. It verifies that the contract reverts with the "Invalid proof" error.
4. **`testMintExceedsMaxPerUser()`**: This test simulates a user attempting to mint more than their allowed limit (in this case, one NFT). It verifies that the contract reverts with the "Max amount per user minted" error.
5. **`testMintSoldOut()`**: This test ensures that once the total supply of NFTs is reached, users can no longer mint any more. It verifies that the contract reverts with the "Sold out" error.
6. **`testToggleWhitelistMint()`**: This test checks that the contract owner can toggle the whitelist minting feature. It verifies that the minting status can be changed and checks both states.
7. **`testTokenURI()`**: This test checks that the token URI for a minted NFT is correctly returned. It verifies that the contract concatenates the base URI with the token ID and returns the correct URI.




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

## 🚧 Running the Tests
1. **Install Foundry**: Follow the instructions above or check the official documentation in the [Foundry Book](https://book.getfoundry.sh/) to install Foundry if you haven't already.
2. **Deploy and Test**: Run the following command to execute the tests:
```bash
forge test <TestName>
```
3. **Check Results**: After running the tests, check the output in the terminal to see if everything passes.
## Contributing

Feel free to open issues or submit pull requests if you want to contribute improvements or bug fixes.




## License

This project is licensed under the LGPL-3.0-only License.
