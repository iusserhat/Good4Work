// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title IMetadataRegistry
 * @dev Interface for a metadata registry that stores and verifies NFT metadata hashes
 */
interface IMetadataRegistry {
    /**
     * @dev Registers a metadata hash for a token
     * @param tokenId The ID of the token
     * @param metadataHash The hash of the token's metadata
     */
    function registerMetadataHash(
        uint256 tokenId,
        bytes32 metadataHash
    ) external;

    /**
     * @dev Verifies if a given metadata hash matches the registered hash for a token
     * @param tokenId The ID of the token
     * @param metadataHash The hash to verify
     * @return True if the hash matches the registered hash, false otherwise
     */
    function verifyMetadataHash(
        uint256 tokenId,
        bytes32 metadataHash
    ) external view returns (bool);

    /**
     * @dev Gets the registered metadata hash for a token
     * @param tokenId The ID of the token
     * @return The registered metadata hash
     */
    function getMetadataHash(uint256 tokenId) external view returns (bytes32);

    /**
     * @dev Event emitted when a metadata hash is registered
     */
    event MetadataHashRegistered(uint256 indexed tokenId, bytes32 metadataHash);

    /**
     * @dev Event emitted when a metadata hash is updated
     */
    event MetadataHashUpdated(
        uint256 indexed tokenId,
        bytes32 oldMetadataHash,
        bytes32 newMetadataHash
    );
}
