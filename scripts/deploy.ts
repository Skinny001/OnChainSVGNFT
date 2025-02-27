import { ethers } from "hardhat";

/**
 * Deployment script for OnChainSVGNFT contract
 * This script deploys the contract to the selected network and 
 * mints an initial NFT with a sample SVG
 */
async function main() {
  // Get the contract factory
  const OnChainSVGNFT = await ethers.getContractFactory("OnChainSVGNFT");
  
  // Get the deployer's address
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract with the account:", deployer.address);
  
  // Deploy the contract
  const nft = await OnChainSVGNFT.deploy(deployer.address);
  await nft.waitForDeployment();
  
  const nftAddress = await nft.getAddress();
  console.log("OnChainSVGNFT deployed to:", nftAddress);
  
  // Sample SVG for the first NFT
  // This creates a simple colored circle NFT
  const sampleSVG = `
    <svg width="500" height="500" viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
      <rect width="500" height="500" fill="#282c34" />
      <circle cx="250" cy="250" r="150" fill="#61dafb" />
      <text x="250" y="250" font-family="Arial" font-size="24" fill="white" text-anchor="middle">On-Chain NFT #1</text>
    </svg>
  `;
  
  // Mint the first NFT
  console.log("Minting first NFT...");
  const mintTx = await nft.mint(deployer.address, sampleSVG, "Circle NFT", {
    value: ethers.parseEther("0.01")
  });
  
  await mintTx.wait();
  console.log("First NFT minted!");
  
  // Print the tokenURI for verification
  const tokenURI = await nft.tokenURI(1);
  console.log("Token URI for NFT #1:", tokenURI);
  
  console.log("Deployment and minting completed!");
}

// Execute the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });