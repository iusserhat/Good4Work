// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Good4WorkNFT.sol";

contract IntegrationTest is Test {
    Good4WorkNFT public nft;
    address private _admin;
    address private _minter;
    address private _user1;
    address private _user2;

    // Mock IPFS URIs
    string private constant URI_1 = "ipfs://QmXyZ123456789";
    string private constant URI_2 = "ipfs://QmAbC987654321";

    function setUp() public {
        _admin = address(1);
        _minter = address(2);
        _user1 = address(3);
        _user2 = address(4);

        vm.startPrank(_admin);
        nft = new Good4WorkNFT();
        nft.grantRole(nft.MINTER_ROLE(), _minter);
        vm.stopPrank();
    }

    function testFullUserJourney() public {
        // Step 1: Mint an NFT
        vm.startPrank(_minter);
        nft.safeMint(_user1, URI_1);
        vm.stopPrank();

        // Verify NFT ownership
        assertEq(nft.ownerOf(0), _user1);
        assertEq(nft.tokenURI(0), URI_1);

        // Step 2: User grants access to private data
        vm.startPrank(_user1);
        nft.grantAccess(0, _user2);
        vm.stopPrank();

        // Verify access granted
        assertTrue(nft.hasAccess(0, _user2));

        // Step 3: User updates the metadata URI
        vm.startPrank(_user1);
        nft.setTokenURI(0, URI_2);
        vm.stopPrank();

        // Verify URI updated
        assertEq(nft.tokenURI(0), URI_2);

        // Step 4: Verify transfer is blocked (soulbound)
        vm.startPrank(_user1);
        vm.expectRevert("Soulbound: transfer not allowed");
        nft.transferFrom(_user1, _user2, 0);
        vm.stopPrank();

        // Verify still owned by original user
        assertEq(nft.ownerOf(0), _user1);
    }

    function testEmergencyScenario() public {
        // Mint an NFT
        vm.startPrank(_minter);
        nft.safeMint(_user1, URI_1);
        vm.stopPrank();

        // Admin pauses the contract in emergency
        vm.startPrank(_admin);
        nft.pause();
        vm.stopPrank();

        // Verify minting is blocked while paused
        vm.startPrank(_minter);
        vm.expectRevert("Pausable: paused");
        nft.safeMint(_user2, URI_2);
        vm.stopPrank();

        // Admin resolves issue and unpauses
        vm.startPrank(_admin);
        nft.unpause();
        vm.stopPrank();

        // Verify minting works again
        vm.startPrank(_minter);
        nft.safeMint(_user2, URI_2);
        vm.stopPrank();

        assertEq(nft.ownerOf(1), _user2);
    }

    function testAdminURIUpdate() public {
        // Mint an NFT
        vm.startPrank(_minter);
        nft.safeMint(_user1, URI_1);
        vm.stopPrank();

        // Admin updates the URI (e.g., for policy violation)
        vm.startPrank(_admin);
        nft.setTokenURI(0, URI_2);
        vm.stopPrank();

        // Verify URI updated by admin
        assertEq(nft.tokenURI(0), URI_2);

        // Verify metadata hash was properly set
        bytes32 expectedHash = keccak256(abi.encodePacked('{"name":"admin"}'));
        assertEq(nft.metadataHashes(0), expectedHash);
    }
}
