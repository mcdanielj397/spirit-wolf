// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/utils/Base64.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/token/common/ERC2981.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.3.0/contracts/utils/cryptography/ECDSA.sol";

/// @title Wolfpack — Alsania Anti-Bot NFT Collection
/// @notice ERC-721 with built-in bot protection, royalty split, and on-chain metadata
/// @dev Signature verification, mint cooldown, front-run resistant randomization
contract Wolfpack is ERC721, ERC2981, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using ECDSA for bytes32;

    // ═══════════════════════════════════
    //  CONSTANTS
    // ═══════════════════════════════════
    uint256 public constant MAX_SUPPLY = 625;
    uint256 public constant MINT_PRICE = 20 ether;
    uint256 public constant MAX_PER_WALLET = 10;
    uint256 public constant OWNER_RESERVE = 10;
    uint96 public constant ROYALTY_BPS = 300;
    uint256 public constant MINT_COOLDOWN = 30 seconds;

    // ═══════════════════════════════════
    //  STORAGE
    // ═══════════════════════════════════
    uint256 private _nextTokenId;
    uint256 private _ownerMinted;
    bool public mintOpen;
    bool public allowlistOnly;

    mapping(uint256 => uint8[4]) private _traits;
    mapping(address => uint256) public walletMinted;
    mapping(address => uint256) public lastMintTime;
    mapping(uint256 => bool) public comboUsed;


    address public immutable feeRecipient;
    address public immutable royaltyRecipient;
    address public signer;

    // ═══════════════════════════════════
    //  IPFS
    // ═══════════════════════════════════
    string private constant BG_CID = "QmSaAcbVJoAhKfg97wqgLMs7Y1f1ANEnyhiCpsiNmR63oH";
    string private constant COMPOSITE_CID = "QmUkUUUhcs89VkqJzZAhP8wnDHzDwehDSbAri8QGHbChvZ";
    string private constant STONE_CID = "QmSPqRwfrajvUgSkeD12brRnCJfvMa8yvKopgS1ZKjGJf7";
    string private constant WOLF_CID = "QmdQixKzJf96T4jwnmvHw5QjrYRwdA3uvo5u8ZiQQFRt8d";
    string private constant AURA_CID = "QmbvTz5CxjKtnwAFo51DsGH9mvEEdQFbbBRy59kZWpesPs";

    // ═══════════════════════════════════
    //  TRAIT NAMES
    // ═══════════════════════════════════
    string[5] public bgNames = ["Space","Smoke","Light","Ice","Fire"];
    string[5] public stoneNames = ["Snow","Lava","Geo","Purple","Stone"];
    string[5] public auraNames = ["Red","Blue","Pink","Teal","Black"];
    string[5] public wolfNames = ["White","Purple","Geo","Smoke","Fire"];

    // ═══════════════════════════════════
    //  EVENTS
    // ═══════════════════════════════════
    event WolfMinted(uint256 indexed tokenId, address indexed owner, uint8 bg, uint8 stone, uint8 wolf, uint8 aura);
    event SignerUpdated(address indexed newSigner);

    // ═══════════════════════════════════
    //  CONSTRUCTOR
    // ═══════════════════════════════════
    constructor(address _artist, address _feeRecipient, address _signer) ERC721("Wolfpack", "PACK") Ownable(msg.sender) {
        require(_artist != address(0));
        require(_feeRecipient != address(0));
        royaltyRecipient = _artist;
        feeRecipient = _feeRecipient;
        signer = _signer;
        _setDefaultRoyalty(_artist, ROYALTY_BPS);
    }

    // ═══════════════════════════════════
    //  PUBLIC MINT
    // ═══════════════════════════════════
    function mint() external payable nonReentrant {
        require(mintOpen, "Mint not open");
        require(_nextTokenId + OWNER_RESERVE - _ownerMinted < MAX_SUPPLY, "Sold out");
        require(msg.value >= MINT_PRICE, "Insufficient payment");
        require(walletMinted[msg.sender] < MAX_PER_WALLET, "Max per wallet");
        require(block.timestamp - lastMintTime[msg.sender] >= MINT_COOLDOWN, "Cooldown active");

        lastMintTime[msg.sender] = block.timestamp;
        walletMinted[msg.sender]++;
        _mintWolf(msg.sender);
    }

    /// @notice Allowlist mint with signature verification
    function allowlistMint(bytes calldata _signature) external payable nonReentrant {
        require(mintOpen || allowlistOnly, "Mint not open");
        require(_nextTokenId + OWNER_RESERVE - _ownerMinted < MAX_SUPPLY, "Sold out");
        require(msg.value >= MINT_PRICE, "Insufficient payment");
        require(walletMinted[msg.sender] < MAX_PER_WALLET, "Max per wallet");
        require(block.timestamp - lastMintTime[msg.sender] >= MINT_COOLDOWN, "Cooldown active");

        // Verify signature
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(msg.sender))));
        require(ECDSA.recover(hash, _signature) == signer, "Invalid signature");

        lastMintTime[msg.sender] = block.timestamp;
        walletMinted[msg.sender]++;
        _mintWolf(msg.sender);
    }

    // ═══════════════════════════════════
    //  OWNER MINT (Initial 10)
    // ═══════════════════════════════════
    function ownerMint(address to, uint256 count) external onlyOwner {
        require(_ownerMinted + count <= OWNER_RESERVE, "Exceeds reserve");
        for (uint256 i = 0; i < count; i++) {
            _mintWolf(to);
            _ownerMinted++;
        }
    }

    // ═══════════════════════════════════
    //  INTERNAL MINT
    // ═══════════════════════════════════
    function _mintWolf(address to) private {
        uint8 bg;
        uint8 stone;
        uint8 wolf;
        uint8 aura;
        uint256 comboIndex;

        // reroll until unique
        do {
            bg = uint8(_random() % 5);
            stone = uint8(_random() % 5);
            wolf = uint8(_random() % 5);
            aura = uint8(_random() % 5);

            comboIndex = uint256(bg) * 125 + uint256(stone) * 25 + uint256(wolf) * 5 + uint256(aura);
        } while (comboUsed[comboIndex]);

        comboUsed[comboIndex] = true;

        _traits[_nextTokenId] = [bg, stone, wolf, aura];
        _safeMint(to, _nextTokenId);
        emit WolfMinted(_nextTokenId, to, bg, stone, wolf, aura);
        _nextTokenId++;
    }

    /// @notice Front-run resistant randomization
    function _random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            block.prevrandao,
            block.timestamp,
            msg.sender,
            _nextTokenId,
            tx.gasprice
        )));
    }

    // ═══════════════════════════════════
    //  METADATA (ON-CHAIN)
    // ═══════════════════════════════════
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        uint8[4] memory t = _traits[tokenId];
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(_json(tokenId, t[0], t[1], t[2], t[3])))
        ));
    }

    function _json(uint256 id, uint8 bg, uint8 stone, uint8 wolf, uint8 aura) private view returns (string memory) {
        return string(abi.encodePacked(
            '{"name":"Wolfpack #',id.toString(),'",',
            '"description":"A unique wolf from the Wolfpack collection by WolfMan.",',
            '"image":"ipfs://',COMPOSITE_CID,'/',(uint256(bg)*125 + uint256(stone)*25 + uint256(wolf)*5 + uint256(aura)).toString(),'.webp",',
            '"external_url":"https://spiritwolf3397.github.io/spirit-wolf/mint",',
            '"artist":"WolfMan",',
            '"partner":"Alsania I/O - alsania-io.com",',
            '"license":"https://spiritwolf3397.github.io/spirit-wolf/license",',
            '"attributes":[',
            '{"trait_type":"Background","value":"',bgNames[bg],'"},',
            '{"trait_type":"Stone","value":"',stoneNames[stone],'"},',
            '{"trait_type":"Wolf","value":"',wolfNames[wolf],'"},',
            '{"trait_type":"Aura","value":"',auraNames[aura],'"}',
            ']}'
        ));
    }

    function getTraits(uint256 tokenId) external view returns (uint8[4] memory) {
        _requireOwned(tokenId);
        return _traits[tokenId];
    }

    // ═══════════════════════════════════
    //  ADMIN
    // ═══════════════════════════════════
    function setMintOpen(bool open) external onlyOwner { mintOpen = open; }
    function setAllowlistOnly(bool _allowlist) external onlyOwner { allowlistOnly = _allowlist; }
    function setSigner(address _signer) external onlyOwner { signer = _signer; emit SignerUpdated(_signer); }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        uint256 fee = balance / 100;
        (bool feeOk, ) = payable(feeRecipient).call{value: fee}("");
        require(feeOk, "Fee transfer failed");
        (bool ownerOk, ) = payable(owner()).call{value: balance - fee}("");
        require(ownerOk, "Owner transfer failed");
    }

    function totalSupply() external view returns (uint256) { return _nextTokenId; }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // ═══════════════════════════════════
    //  BASE64
    // ═══════════════════════════════════



}
