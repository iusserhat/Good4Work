# Good4Work NFT

Good4Work NFT is a soulbound (non-transferable) NFT contract for issuing verifiable credentials and certificates on Ethereum.

## Features

- **Soulbound NFTs**: Once minted, tokens cannot be transferred (ERC-5192 compliant)
- **Access Control**: Role-based permissions for admin and minter operations
- **Metadata Access Management**: Token owners can grant viewing permission to specific addresses
- **URI Updates**: Token URIs can be updated by owner or admin
- **Emergency Controls**: Admin can pause/unpause the contract

## Project Structure

```
smartcontracts/
├── src/                       # Smart contract source code
│   ├── Good4WorkNFT.sol       # Main NFT contract
│   └── interfaces/            # Contract interfaces
│       └── IGood4WorkNFT.sol  # ERC-5192 interface
│
├── script/                    # Deployment and interaction scripts
│   ├── Deploy.s.sol           # Contract deployment script
│   ├── MintSample.s.sol       # Example minting script
│   └── UpdateURI.s.sol        # Token URI update script
│
├── test/                      # Test files
│   ├── Good4WorkNFT.t.sol     # Unit tests
│   └── Integration.t.sol      # Integration tests
│
├── ipfs-tools/                # IPFS utilities
│   ├── upload.js              # IPFS upload tools
│   ├── generateMetadata.js    # Metadata generation utilities
│   └── mint-cli.js            # CLI tool for minting NFTs
│
└── foundry.toml               # Foundry configuration
```

## Setup

1. Clone the repository
2. Install dependencies:

```shell
forge install
npm install --prefix ipfs-tools
```

3. Create a `.env` file in the project root with the following variables:

```
# Blockchain Configuration
PRIVATE_KEY=0x0000000000000000000000000000000000000000000000000000000000000000
RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your-api-key
ETHERSCAN_API_KEY=your_etherscan_api_key

# Contract Information
NFT_CONTRACT=0x0000000000000000000000000000000000000000
MINTER_ADDRESS=0x0000000000000000000000000000000000000000

# IPFS Configuration
PINATA_API_KEY=your_pinata_api_key
PINATA_SECRET_KEY=your_pinata_secret_key
WEB3_STORAGE_TOKEN=your_web3_storage_token
```

## Usage

### Build and Test

```shell
# Build contracts
forge build

# Run tests
forge test
```

### Deploy the Contract

```shell
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### Mint an NFT

Using the Foundry script:

```shell
forge script script/MintSample.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

Using the CLI tool:

```shell
node ipfs-tools/mint-cli.js mint --image path/to/image.jpg --name "Certificate Name" --description "Description"
```

### Update Token URI

```shell
forge script script/UpdateURI.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

## IPFS Tools

The project includes JavaScript utilities for working with IPFS:

- `upload.js`: Functions for uploading files to IPFS via Pinata or Web3.Storage
- `generateMetadata.js`: Utilities for creating standardized NFT metadata
- `mint-cli.js`: Interactive CLI tool for minting NFTs

## License

This project is licensed under the MIT License.
