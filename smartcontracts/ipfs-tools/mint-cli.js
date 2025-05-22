#!/usr/bin/env node
// CLI tool for minting Good4Work NFTs

const fs = require('fs');
const path = require('path');
const { program } = require('commander');
const inquirer = require('inquirer');
const chalk = require('chalk');
const { ethers } = require('ethers');
const { uploadContent } = require('./upload');
const { generateMetadata, computeMetadataHash } = require('./generateMetadata');

// Load environment variables
require('dotenv').config({ path: path.join(__dirname, '../.env') });

// Load ABI
let contractABI;
try {
  const abiPath = path.join(__dirname, '../out/Good4WorkNFT.sol/Good4WorkNFT.json');
  const contractData = JSON.parse(fs.readFileSync(abiPath, 'utf8'));
  contractABI = contractData.abi;
} catch (error) {
  console.error(chalk.red('Error loading contract ABI:'), error.message);
  console.error(chalk.yellow('Tip: Make sure to run "forge build" first to generate the ABI.'));
  process.exit(1);
}

program
  .name('good4work-mint')
  .description('CLI tool for minting Good4Work NFTs')
  .version('1.0.0');

program
  .command('mint')
  .description('Mint a new Good4Work NFT')
  .option('-i, --image <path>', 'Path to the image file')
  .option('-n, --name <name>', 'Name of the NFT')
  .option('-d, --description <desc>', 'Description of the NFT')
  .option('-r, --recipient <address>', 'Ethereum address of the recipient')
  .option('-c, --contract <address>', 'Good4Work NFT contract address')
  .option('--rpc <url>', 'Ethereum RPC URL')
  .option('--private-key <key>', 'Private key for signing transactions')
  .action(async (options) => {
    try {
      // Gather missing information
      const answers = await promptMissingOptions(options);
      const mergedOptions = { ...options, ...answers };
      
      console.log(chalk.blue('Preparing to mint NFT...'));
      
      // Upload image to IPFS
      console.log(chalk.blue('Uploading image to IPFS...'));
      const imageUpload = await uploadContent(
        fs.readFileSync(mergedOptions.image),
        path.basename(mergedOptions.image),
        'pinata'
      );
      
      if (!imageUpload.success) {
        throw new Error(`Failed to upload image: ${imageUpload.error}`);
      }
      
      console.log(chalk.green(`Image uploaded to IPFS: ${imageUpload.url}`));
      
      // Generate metadata
      const metadata = generateMetadata({
        name: mergedOptions.name,
        description: mergedOptions.description,
        image: imageUpload.url,
        attributes: [
          { trait_type: 'Type', value: 'Good4Work Certificate' },
          { trait_type: 'Created', value: new Date().toISOString().split('T')[0] }
        ]
      });
      
      // Upload metadata to IPFS
      console.log(chalk.blue('Uploading metadata to IPFS...'));
      const metadataUpload = await uploadContent(
        metadata,
        `${mergedOptions.name.replace(/\s+/g, '_')}_metadata.json`,
        'pinata'
      );
      
      if (!metadataUpload.success) {
        throw new Error(`Failed to upload metadata: ${metadataUpload.error}`);
      }
      
      console.log(chalk.green(`Metadata uploaded to IPFS: ${metadataUpload.url}`));
      
      // Calculate hash for on-chain verification
      const metadataHash = computeMetadataHash(metadata);
      console.log(chalk.blue(`Metadata hash: ${metadataHash}`));
      
      // Connect to Ethereum
      const provider = new ethers.providers.JsonRpcProvider(mergedOptions.rpc);
      const wallet = new ethers.Wallet(mergedOptions.privateKey, provider);
      const contract = new ethers.Contract(mergedOptions.contract, contractABI, wallet);
      
      // Mint NFT
      console.log(chalk.blue(`Minting NFT to ${mergedOptions.recipient}...`));
      const tx = await contract.safeMint(mergedOptions.recipient, metadataUpload.url);
      console.log(chalk.yellow(`Transaction submitted: ${tx.hash}`));
      console.log(chalk.blue('Waiting for confirmation...'));
      
      // Wait for transaction to be mined
      const receipt = await tx.wait();
      console.log(chalk.green(`NFT successfully minted! Transaction: ${receipt.transactionHash}`));
      
      // Extract token ID from event logs
      const mintEvent = receipt.events.find(e => e.event === 'Transfer');
      if (mintEvent) {
        const tokenId = mintEvent.args.tokenId.toString();
        console.log(chalk.green(`Token ID: ${tokenId}`));
      }
      
    } catch (error) {
      console.error(chalk.red('Error:'), error.message);
      process.exit(1);
    }
  });

// Helper function to prompt for missing options
async function promptMissingOptions(options) {
  const questions = [];
  
  if (!options.image) {
    questions.push({
      type: 'input',
      name: 'image',
      message: 'Path to the image file:',
      validate: input => fs.existsSync(input) ? true : 'File does not exist'
    });
  }
  
  if (!options.name) {
    questions.push({
      type: 'input',
      name: 'name',
      message: 'Name of the NFT:',
      validate: input => input.trim() ? true : 'Name is required'
    });
  }
  
  if (!options.description) {
    questions.push({
      type: 'input',
      name: 'description',
      message: 'Description of the NFT:',
      validate: input => input.trim() ? true : 'Description is required'
    });
  }
  
  if (!options.recipient) {
    questions.push({
      type: 'input',
      name: 'recipient',
      message: 'Ethereum address of the recipient:',
      validate: input => ethers.utils.isAddress(input) ? true : 'Invalid Ethereum address'
    });
  }
  
  if (!options.contract) {
    questions.push({
      type: 'input',
      name: 'contract',
      message: 'Good4Work NFT contract address:',
      validate: input => ethers.utils.isAddress(input) ? true : 'Invalid contract address',
      default: process.env.NFT_CONTRACT
    });
  }
  
  if (!options.rpc) {
    questions.push({
      type: 'input',
      name: 'rpc',
      message: 'Ethereum RPC URL:',
      default: process.env.RPC_URL || 'https://rpc.sepolia.org'
    });
  }
  
  if (!options.privateKey) {
    questions.push({
      type: 'password',
      name: 'privateKey',
      message: 'Private key for signing transactions:',
      mask: '*',
      default: process.env.PRIVATE_KEY
    });
  }
  
  return inquirer.prompt(questions);
}

// Parse command line arguments
program.parse(process.argv);

// Show help if no command is provided
if (!process.argv.slice(2).length) {
  program.help();
} 