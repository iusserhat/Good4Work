// IPFS upload utility for Good4Work NFT
const fs = require('fs');
const path = require('path');
const pinataSDK = require('@pinata/sdk');
const { Web3Storage, File } = require('web3.storage');

// Configuration function
function getConfig() {
  // Check for environment variables
  const pinataApiKey = process.env.PINATA_API_KEY;
  const pinataApiSecret = process.env.PINATA_SECRET_KEY;
  const web3StorageToken = process.env.WEB3_STORAGE_TOKEN;
  
  if (!pinataApiKey && !web3StorageToken) {
    throw new Error('No IPFS service credentials found. Please set PINATA_API_KEY and PINATA_SECRET_KEY or WEB3_STORAGE_TOKEN');
  }
  
  return {
    pinataApiKey,
    pinataApiSecret,
    web3StorageToken
  };
}

// Upload to Pinata
async function uploadToPinata(filePath, name) {
  const { pinataApiKey, pinataApiSecret } = getConfig();
  const pinata = new pinataSDK(pinataApiKey, pinataApiSecret);
  
  try {
    const result = await pinata.pinFromFS(filePath, {
      pinataMetadata: {
        name: name || path.basename(filePath)
      }
    });
    
    return {
      success: true,
      ipfsHash: result.IpfsHash,
      url: `ipfs://${result.IpfsHash}`
    };
  } catch (error) {
    console.error('Pinata upload failed:', error);
    return {
      success: false,
      error: error.message
    };
  }
}

// Upload to Web3.Storage
async function uploadToWeb3Storage(filePath, name) {
  const { web3StorageToken } = getConfig();
  const storage = new Web3Storage({ token: web3StorageToken });
  
  try {
    const fileData = fs.readFileSync(filePath);
    const fileName = name || path.basename(filePath);
    const file = new File([fileData], fileName);
    
    const cid = await storage.put([file]);
    
    return {
      success: true,
      ipfsHash: cid,
      url: `ipfs://${cid}`
    };
  } catch (error) {
    console.error('Web3.Storage upload failed:', error);
    return {
      success: false,
      error: error.message
    };
  }
}

// Upload string/JSON content as a file
async function uploadContent(content, fileName, useService = 'pinata') {
  const tempPath = path.join(__dirname, 'temp_' + fileName);
  
  try {
    // Write content to temp file
    if (typeof content === 'object') {
      fs.writeFileSync(tempPath, JSON.stringify(content, null, 2));
    } else {
      fs.writeFileSync(tempPath, content);
    }
    
    // Upload based on service preference
    let result;
    if (useService === 'web3.storage') {
      result = await uploadToWeb3Storage(tempPath, fileName);
    } else {
      result = await uploadToPinata(tempPath, fileName);
    }
    
    // Clean up temp file
    fs.unlinkSync(tempPath);
    
    return result;
  } catch (error) {
    // Clean up if possible
    if (fs.existsSync(tempPath)) {
      fs.unlinkSync(tempPath);
    }
    
    return {
      success: false,
      error: error.message
    };
  }
}

module.exports = {
  uploadToPinata,
  uploadToWeb3Storage,
  uploadContent
}; 