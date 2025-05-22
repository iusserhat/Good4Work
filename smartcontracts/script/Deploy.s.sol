// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Good4WorkNFT.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the NFT contract
        Good4WorkNFT nft = new Good4WorkNFT();

        // Optional: Add a new minter role to another address
        // address minterAddress = vm.envAddress("MINTER_ADDRESS");
        // nft.grantRole(nft.MINTER_ROLE(), minterAddress);

        console.log("Good4WorkNFT deployed at:", address(nft));

        vm.stopBroadcast();
    }
}
