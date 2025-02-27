// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract OnChainSVGNFT is ERC721, Ownable {
    using Strings for uint256;
    
   
    mapping(uint256 => string) private _tokenSVGs;
    
  
    mapping(uint256 => string) private _tokenNames;
    
   
    uint256 public constant MAX_SUPPLY = 100;
 
    uint256 public mintPrice = 0.01 ether;
    
  
    uint256 private _totalSupply;
  
    constructor(address initialOwner) 
        ERC721("OnChain SVG NFT", "OCSVG") 
        Ownable(initialOwner) {
    }
    

    function mint(address to, string memory svgData, string memory name) public payable {
    
        require(_totalSupply < MAX_SUPPLY, "Max supply reached");
        
       
        require(msg.value >= mintPrice, "Insufficient ETH sent");
        
        _totalSupply++;
        uint256 tokenId = _totalSupply;
        
        // Store the SVG data and name
        _tokenSVGs[tokenId] = svgData;
        _tokenNames[tokenId] = name;
        
        // Mint the NFT
        _mint(to, tokenId);
    }
    
    
    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }
    
   
    function tokenExists(uint256 tokenId) public view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
    
  
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenExists(tokenId), "Token does not exist");
    
        string memory svg = _tokenSVGs[tokenId];
        string memory name = _tokenNames[tokenId];
        
        string memory encodedSVG = Base64.encode(bytes(svg));
        string memory imageURI = string(abi.encodePacked("data:image/svg+xml;base64,", encodedSVG));
        
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', name, ' #', tokenId.toString(), 
                        '", "description": "On-chain SVG NFT with embedded artwork.", ',
                        '"image": "', imageURI, 
                        '", "attributes": [{"trait_type": "ID", "value": "', tokenId.toString(), '"}]}'
                    )
                )
            )
        );
        
       
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
    
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdrawal failed");
    }
}
