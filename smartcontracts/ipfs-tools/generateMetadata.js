// Metadata generator for Good4Work NFT
const crypto = require('crypto');

/**
 * Generate standard ERC-721 metadata for Good4Work NFT
 * @param {Object} options - Metadata options
 * @param {string} options.name - NFT name
 * @param {string} options.description - NFT description
 * @param {string} options.image - IPFS URI to the image (ipfs://...)
 * @param {string} options.externalUrl - Optional external URL
 * @param {Object[]} options.attributes - NFT attributes/traits
 * @param {Object} options.additionalFields - Any additional fields to include
 * @returns {Object} The metadata object
 */
function generateMetadata({
  name,
  description,
  image,
  externalUrl,
  attributes = [],
  additionalFields = {}
}) {
  if (!name || !description || !image) {
    throw new Error('Name, description, and image are required fields');
  }
  
  // Ensure image is properly formatted as IPFS URI
  if (!image.startsWith('ipfs://') && !image.startsWith('https://')) {
    throw new Error('Image must be an IPFS URI (ipfs://...) or HTTPS URL');
  }
  
  // Base metadata following ERC-721 metadata standard
  const metadata = {
    name,
    description,
    image,
    attributes: normalizeAttributes(attributes),
    ...additionalFields
  };
  
  // Add optional external URL if provided
  if (externalUrl) {
    metadata.external_url = externalUrl;
  }
  
  return metadata;
}

/**
 * Ensures attributes are in the standard format
 * @param {Array} attributes - Array of trait objects
 * @returns {Array} Normalized attributes array
 */
function normalizeAttributes(attributes) {
  return attributes.map(attr => {
    // Handle different attribute formats
    if (attr.trait_type && attr.value !== undefined) {
      return attr; // Already in correct format
    }
    
    // Convert simple key-value to trait format
    if (typeof attr === 'object') {
      const key = Object.keys(attr)[0];
      return {
        trait_type: key,
        value: attr[key]
      };
    }
    
    return attr;
  });
}

/**
 * Computes hash of metadata for on-chain verification
 * @param {Object} metadata - The metadata object
 * @returns {string} The hash in hex format
 */
function computeMetadataHash(metadata) {
  const metadataString = JSON.stringify(metadata);
  return '0x' + crypto.createHash('sha256').update(metadataString).digest('hex');
}

/**
 * Creates a metadata object with private and public sections
 * @param {Object} publicData - Metadata visible to everyone
 * @param {Object} privateData - Metadata visible only to authorized viewers
 * @returns {Object} Combined metadata object
 */
function createProtectedMetadata(publicData, privateData) {
  return {
    ...generateMetadata(publicData),
    protected_data: privateData,
    // Add flag to indicate this metadata contains protected fields
    has_protected_data: true
  };
}

module.exports = {
  generateMetadata,
  computeMetadataHash,
  createProtectedMetadata
}; 