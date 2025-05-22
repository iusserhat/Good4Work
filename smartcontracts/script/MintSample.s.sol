// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Good4WorkNFT.sol";

contract MintSampleScript is Script {
    function run() external {
        uint256 minterPrivateKey = vm.envUint("PRIVATE_KEY");
        address nftContract = vm.envAddress("NFT_CONTRACT");
        address recipient = vm.envAddress("RECIPIENT_ADDRESS");
        string memory tokenURI = vm.envString("METADATA_URI");

        vm.startBroadcast(minterPrivateKey);

        Good4WorkNFT nft = Good4WorkNFT(nftContract);
        nft.safeMint(recipient, tokenURI);

        console.log("NFT minted to:", recipient);
        console.log("with URI:", tokenURI);

        vm.stopBroadcast();
    }
}
