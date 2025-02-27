// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title OnChainSVGNFT
 * @dev NFT contract that stores SVG images entirely on-chain
 * The SVGs are encoded and stored as part of the token's metadata
 * This makes the NFT truly decentralized as its visual representation
 * doesn't depend on external hosting services
 */
contract OnChainSVGNFT is ERC721, Ownable {
    using Strings for uint256;
    
    // Mapping from token ID to SVG data
    mapping(uint256 => string) private _tokenSVGs;
    
    // Mapping from token ID to name
    mapping(uint256 => string) private _tokenNames;
    
    // Maximum supply of NFTs
    uint256 public constant MAX_SUPPLY = 100;
    
    // Base mint price (0.01 ETH)
    uint256 public mintPrice = 0.01 ether;
    
    // Token counter for tracking minted NFTs
    uint256 private _totalSupply;
    
    /**
     * @dev Constructor initializes the contract with a name and symbol
     * @param initialOwner The initial owner of the contract
     */
    constructor(address initialOwner) 
        ERC721("OnChain SVG NFT", "OCSVG") 
        Ownable(initialOwner) {
    }
    
    /**
     * @dev Mints a new NFT with the provided SVG data
     * @param to The address that will own the minted NFT
     * @param svgData The raw SVG data to be stored on-chain
     * @param name The name for this specific token
     */
    function mint(address to, string memory svgData, string memory name) public payable {
        // Check maximum supply
        require(_totalSupply < MAX_SUPPLY, "Max supply reached");
        
        // Check that the correct price was sent
        require(msg.value >= mintPrice, "Insufficient ETH sent");
        
        // Increment token ID
        _totalSupply++;
        uint256 tokenId = _totalSupply;
        
        // Store the SVG data and name
        _tokenSVGs[tokenId] = svgData;
        _tokenNames[tokenId] = name;
        
        // Mint the NFT
        _mint(to, tokenId);
    }
    
    /**
     * @dev Update the mint price
     * @param newPrice The new mint price
     */
    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }
    
    /**
     * @dev Checks if a token exists
     * @param tokenId The ID of the token to check
     * @return bool True if the token exists
     */
    function tokenExists(uint256 tokenId) public view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
    
    /**
     * @dev Generates the complete metadata for a token including the embedded SVG
     * @param tokenId The ID of the token
     * @return The complete JSON metadata for the token
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenExists(tokenId), "Token does not exist");
        
        // Get the SVG data and name for this token
        string memory svg = _tokenSVGs[tokenId];
        string memory name = _tokenNames[tokenId];
        
        // Base64 encode the SVG data for embedding in the JSON metadata
        string memory encodedSVG = Base64.encode(bytes(svg));
        string memory imageURI = string(abi.encodePacked("data:image/svg+xml;base64,", encodedSVG));
        
        // Create the JSON metadata
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
        
        // Return the complete URI
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
    
    /**
     * @dev Returns the total number of minted tokens
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev Allows the owner to withdraw collected ETH
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdrawal failed");
    }
}
