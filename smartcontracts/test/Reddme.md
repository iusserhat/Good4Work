# Blockchain Configuration
PRIVATE_KEY=0xYourPrivateKeyHere  # NFT'yi mint etmek için kullanılan cüzdanın özel anahtarı
RPC_URL=https://your-etherlink-rpc-url  # Etherlink ağına uygun RPC URL'si
ETHERSCAN_API_KEY=your_etherscan_api_key  # Etherlink için geçerli bir Etherscan API anahtarı varsa

# Contract Information
NFT_CONTRACT=0xYourContractAddressHere  # Deploy edilmiş Good4WorkNFT sözleşme adresi
MINTER_ADDRESS=0xYourMinterAddressHere  # NFT'leri mint etme yetkisine sahip adres

# IPFS Configuration
PINATA_API_KEY=your_pinata_api_key  # Pinata hizmeti için API anahtarı
PINATA_SECRET_KEY=your_pinata_secret_key  # Pinata hizmeti için gizli anahtar
WEB3_STORAGE_TOKEN=your_web3_storage_token  # Web3.Storage hizmeti için erişim token'ı

# Minting Example
RECIPIENT_ADDRESS=0xRecipientAddressHere  # NFT'yi alacak cüzdan adresi
METADATA_URI=ipfs://YourMetadataCIDHere  # IPFS CID'si ile metadata dosyasının URI'si
TOKEN_ID=0  # Güncellenmek istenen token ID'si
NEW_METADATA_URI=ipfs://YourNewMetadataCIDHere  # Güncellenmiş metadata URI'si