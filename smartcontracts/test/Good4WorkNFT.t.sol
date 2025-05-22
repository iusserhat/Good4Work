// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {Good4WorkNFT} from "../src/Good4WorkNFT.sol";

contract Good4WorkNFTTest is Test {
    Good4WorkNFT public nft;
    address private _admin;
    address private _minter;
    address private _user1;
    address private _user2;

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

    function testOnlyMinterCanMint() public {
        vm.startPrank(_minter);
        nft.safeMint(_user1, "ipfs://uri1");
        assertEq(nft.ownerOf(0), _user1);
        vm.stopPrank();
    }

    function testMintFailsForNonMinter() public {
        vm.startPrank(_user1);
        vm.expectRevert();
        nft.safeMint(_user1, "ipfs://uri1");
        vm.stopPrank();
    }

    function testSoulboundTransferBlocked() public {
        vm.startPrank(_minter);
        nft.safeMint(_user1, "ipfs://uri1");
        vm.stopPrank();

        vm.startPrank(_user1);
        vm.expectRevert("Soulbound: transfer not allowed");
        nft.transferFrom(_user1, _user2, 0);
        vm.stopPrank();
    }

    function testPauseUnpause() public {
        vm.startPrank(_admin);
        nft.pause();
        nft.unpause();
        vm.stopPrank();
    }

    function testMintFailsWhenPaused() public {
        vm.startPrank(_admin);
        nft.pause();
        vm.stopPrank();

        vm.startPrank(_minter);
        vm.expectRevert("Pausable: paused");
        nft.safeMint(_user1, "ipfs://uri2");
        vm.stopPrank();
    }

    function testGrantAccessToMetadata() public {
        vm.startPrank(_minter);
        nft.safeMint(_user1, "ipfs://uri3");
        vm.stopPrank();

        vm.startPrank(_user1);
        nft.grantAccess(0, _user2);
        vm.stopPrank();

        bool access = nft.hasAccess(0, _user2);
        assertTrue(access);
    }

    function testOnlyOwnerCanGrantAccess() public {
        vm.startPrank(_minter);
        nft.safeMint(_user1, "ipfs://uri3");
        vm.stopPrank();

        vm.startPrank(_user2);
        vm.expectRevert("Only owner can grant access");
        nft.grantAccess(0, _user2);
        vm.stopPrank();
    }

    function testSetTokenURIByOwnerWithHash() public {
        vm.startPrank(_minter);
        nft.safeMint(_user1, "ipfs://uri4");
        vm.stopPrank();

        bytes32 metadataHash = keccak256(abi.encodePacked('{"name":"test"}'));

        vm.startPrank(_user1);
        nft.setTokenURI(0, "ipfs://updatedUri");
        assertEq(nft.metadataHashes(0), metadataHash);
        vm.stopPrank();
    }

    function testSetTokenURIByAdminWithHash() public {
        vm.startPrank(_minter);
        nft.safeMint(_user1, "ipfs://uri5");
        vm.stopPrank();

        bytes32 metadataHash = keccak256(abi.encodePacked('{"name":"admin"}'));

        vm.startPrank(_admin);
        nft.setTokenURI(0, "ipfs://adminUpdate");
        assertEq(nft.metadataHashes(0), metadataHash);
        vm.stopPrank();
    }

    function testSetTokenURIFailsForUnauthorizedWithHash() public {
        vm.startPrank(_minter);
        nft.safeMint(_user1, "ipfs://uri6");
        vm.stopPrank();

        vm.startPrank(_user2);
        vm.expectRevert("Not authorized to update URI");
        nft.setTokenURI(0, "ipfs://fail");
        vm.stopPrank();
    }

    function testLockedReturnsTrue() public {
        vm.startPrank(_minter);
        nft.safeMint(_user1, "ipfs://uri7");
        vm.stopPrank();

        bool isLocked = nft.locked(0);
        assertTrue(isLocked);
    }

    function testLockedFailsForInvalidTokenId() public {
        vm.expectRevert("Query for nonexistent token");
        nft.locked(999);
    }
}
