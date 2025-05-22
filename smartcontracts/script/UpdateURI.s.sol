// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Good4WorkNFT.sol";

contract UpdateURIScript is Script {
    function run() external {
        uint256 ownerPrivateKey = vm.envUint("PRIVATE_KEY");
        address nftContract = vm.envAddress("NFT_CONTRACT");
        uint256 tokenId = vm.envUint("TOKEN_ID");
        string memory newTokenURI = vm.envString("NEW_METADATA_URI");

        vm.startBroadcast(ownerPrivateKey);

        Good4WorkNFT nft = Good4WorkNFT(nftContract);
        nft.setTokenURI(tokenId, newTokenURI);

        console.log("Updated URI for token ID:", tokenId);
        console.log("New URI:", newTokenURI);

        vm.stopBroadcast();
    }
}
