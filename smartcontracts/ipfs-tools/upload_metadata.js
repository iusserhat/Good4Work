require('dotenv').config();
const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

const WEB3_STORAGE_TOKEN = process.env.WEB3_STORAGE_TOKEN;

async function uploadToIPFS(filePath) {
  const file = fs.readFileSync(filePath);
  const formData = new FormData();
  formData.append('file', file, path.basename(filePath));

  const res = await axios.post('https://api.web3.storage/upload', formData, {
    headers: {
      Authorization: `Bearer ${WEB3_STORAGE_TOKEN}`,
      ...formData.getHeaders()
    }
  });

  const cid = res.data.cid;
  console.log('✅ Metadata IPFS CID:', cid);
  console.log(`🔗 ipfs://${cid}/${path.basename(filePath)}`);
}

const filePath = process.argv[2];
if (!filePath) {
  console.error('❌ Lütfen bir metadata dosya yolu girin (örnek: ./user1.json)');
  process.exit(1);
}

uploadToIPFS(filePath).catch(console.error);
