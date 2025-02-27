import { ethers } from "hardhat";
import * as fs from 'fs';

async function main() {

  const contractAddress = "0x372b4eB67006F68A9f296b23715055b8A878ABA9";
  
  
  const OnChainSVGNFT = await ethers.getContractFactory("OnChainSVGNFT");
  const nft = await OnChainSVGNFT.attach(contractAddress);
  
  
  const [signer] = await ethers.getSigners();
  console.log("Minting with account:", signer.address);
  
  const customSVG = `
    <svg width="500" height="500" viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
      <rect width="500" height="500" fill="#1a1a2e" />
      <rect x="50" y="50" width="400" height="400" fill="#16213e" />
      <rect x="100" y="100" width="300" height="300" fill="#0f3460" />
      <rect x="150" y="150" width="200" height="200" fill="#e94560" />
      <text x="250" y="250" font-family="Arial" font-size="24" fill="white" text-anchor="middle">Pattern NFT</text>
    </svg>
  `;
  
 
  console.log("Minting new NFT...");
  const mintTx = await nft.mint(signer.address, customSVG, "Pattern NFT", {
    value: ethers.parseEther("0.01")
  });
  
  await mintTx.wait();
  console.log("New NFT minted!");
  
  const totalSupply = await nft.totalSupply();
  const tokenId = totalSupply;
  console.log(`NFT minted with token ID: ${tokenId}`);
  

  const tokenURI = await nft.tokenURI(tokenId);
  console.log(`Token URI for NFT #${tokenId}:`, tokenURI);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });