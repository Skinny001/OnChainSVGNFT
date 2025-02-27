import { ethers } from "hardhat";


async function main() {
 
  const OnChainSVGNFT = await ethers.getContractFactory("OnChainSVGNFT");
  
 
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract with the account:", deployer.address);
  
  const nft = await OnChainSVGNFT.deploy(deployer.address);
  await nft.waitForDeployment();
  
  const nftAddress = await nft.getAddress();
  console.log("OnChainSVGNFT deployed to:", nftAddress);
  
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
  
  const tokenURI = await nft.tokenURI(1);
  console.log("Token URI for NFT #1:", tokenURI);
  
  console.log("Deployment and minting completed!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });