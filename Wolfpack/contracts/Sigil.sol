// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/token/common/ERC2981.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/utils/Base64.sol";

contract SpiritWolfSigil is ERC1155, ERC2981, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public constant TOKEN_ID = 0;
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant MINT_PRICE = 5 ether;
    uint96 public constant ROYALTY_BPS = 300;

    uint256 public minted;
    bool public mintOpen;

    address public immutable feeRecipient;
    address public immutable royaltyRecipient;

    string private constant METADATA = '{"name":"SpiritWolf Sigil - Eternal Spin","description":"A 3D metallic emblem of the SpiritWolf, rotating in a seamless loop.","image":"ipfs://QmR8DMwURzdmUpQCuDyvZqCnWCAydg8c2KXwtJjNJW4Krx/spiritwolf-sigil-thumb.png","animation_url":"ipfs://QmR8DMwURzdmUpQCuDyvZqCnWCAydg8c2KXwtJjNJW4Krx/spiritwolf-sigil-loop.mp4","attributes":[{"trait_type":"Format","value":"3D Loop"},{"trait_type":"Edition","value":"ERC-1155"}]}';

    event SigilMinted(address indexed owner, uint256 amount);

    constructor(address _artist, address _feeRecipient)
        ERC1155("")
        Ownable(msg.sender)
    {
        require(_artist != address(0));
        require(_feeRecipient != address(0));
        royaltyRecipient = _artist;
        feeRecipient = _feeRecipient;
        _setDefaultRoyalty(_artist, ROYALTY_BPS);
    }

    function mint(uint256 amount) external payable nonReentrant {
        require(mintOpen, "Mint not open");
        require(amount > 0 && minted + amount <= MAX_SUPPLY, "Exceeds supply");
        require(msg.value >= MINT_PRICE * amount, "Insufficient payment");
        minted += amount;
        _mint(msg.sender, TOKEN_ID, amount, "");
        emit SigilMinted(msg.sender, amount);
    }

    function ownerMint(address to, uint256 amount) external onlyOwner {
        require(minted + amount <= MAX_SUPPLY, "Exceeds supply");
        minted += amount;
        _mint(to, TOKEN_ID, amount, "");
        emit SigilMinted(to, amount);
    }

    function uri(uint256) public pure override returns (string memory) {
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(METADATA))));
    }

    function setMintOpen(bool open) external onlyOwner { mintOpen = open; }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        uint256 fee = balance / 100;
        (bool feeOk, ) = payable(feeRecipient).call{value: fee}("");
        require(feeOk, "Fee failed");
        (bool ownerOk, ) = payable(owner()).call{value: balance - fee}("");
        require(ownerOk, "Owner withdraw failed");
    }

    function totalMinted() external view returns (uint256) { return minted; }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
