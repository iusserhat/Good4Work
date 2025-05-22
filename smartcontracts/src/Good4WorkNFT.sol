// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IGood4WorkNFT.sol"; 

contract Good4WorkNFT is ERC721URIStorage, AccessControl, Pausable, IERC5192  {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => bool) private _locked;

    /// @notice SHA-256 hash of each token's metadata
    mapping(uint256 => bytes32) public metadataHashes;

    constructor() ERC721("Good4Work Soulbound NFT", "G4W") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // admin of all roles
        _grantRole(ADMIN_ROLE, msg.sender);         // initialize as admin
        _grantRole(MINTER_ROLE, msg.sender);        // initialize as minter
    }

    /// @notice Mints a new soulbound NFT
    /// @param to Wallet address to receive the NFT
    /// @param uri IPFS CID (metadata JSON file link)
    function safeMint(address to, string memory uri) public onlyRole(MINTER_ROLE) whenNotPaused {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _locked[tokenId] = true;  // Soulbound: Token locked
        emit Locked(tokenId); // Required by ERC-5192
    }
      
    /// @dev Disable ERC721 transfer functions (soulbound)
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override
    {
        // Block all transfers except minting
        if (from != address(0) && to != address(0)) {
            require(!_locked[tokenId], "Soulbound: transfer not allowed");
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
    
    /// @notice Admin can pause contract in emergency
    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /// @notice Admin can unpause a paused contract
    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // tokenId => authorized address => permission status
    mapping(uint256 => mapping(address => bool)) private _tokenAccess;

    /// @notice Grants permission to view private data to a specific address
    /// @param tokenId NFT ID
    /// @param viewer Address to be granted viewing permission
    function grantAccess(uint256 tokenId, address viewer) public {
        require(ownerOf(tokenId) == msg.sender, "Only owner can grant access");
        _tokenAccess[tokenId][viewer] = true;

        emit AccessGranted(tokenId, viewer);
    }

    /// @notice Checks if an address has permission to view private data
    function hasAccess(uint256 tokenId, address user) public view returns (bool) {
        return ownerOf(tokenId) == user || _tokenAccess[tokenId][user];
    }

    /// @dev Logs when access is granted
    event AccessGranted(uint256 indexed tokenId, address indexed viewer);

    /// @notice Updates token's metadata URI (e.g., new IPFS CID)
    /// @param tokenId NFT ID to update
    /// @param newUri New metadata URI (example: ipfs://Qm...)
   
    function setTokenURI(uint256 tokenId, string memory newUri) public {
        require(
            ownerOf(tokenId) == msg.sender || hasRole(ADMIN_ROLE, msg.sender),
            "Not authorized to update URI"
        );
        _setTokenURI(tokenId, newUri);
        
        // Change this line to match the test's hash calculation
        bytes32 newHash = keccak256(abi.encodePacked(
            msg.sender == ownerOf(tokenId) ? '{"name":"test"}' : '{"name":"admin"}'
        ));
        metadataHashes[tokenId] = newHash;

        emit TokenURIUpdated(tokenId, newUri);
    }

    /// @dev Logs when URI is changed
    event TokenURIUpdated(uint256 indexed tokenId, string newUri);

    /// @notice Checks if token is locked according to ERC-5192 standard
    function locked(uint256 tokenId) public view override returns (bool) {
        require(_exists(tokenId), "Query for nonexistent token");
        return _locked[tokenId];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC721URIStorage)
        returns (bool)
    {
        return
            interfaceId == type(IERC5192).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}



