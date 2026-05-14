// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface ISpiritWolfToken {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function isVerifiedHuman(address) external view returns (bool);
}

/// @title SPIRIT Faucet — Daily drip for verified humans
/// @notice Claim 100 SPIRIT per day if you've proven your humanity
contract SPIRITFaucet {
    ISpiritWolfToken public immutable token;
    address public immutable owner;
    uint256 public dripAmount = 1 ether;
    uint256 public maxDrip = 100 ether;
    uint256 public constant COOLDOWN = 1 days;
    
    mapping(address => uint256) public lastClaim;
    
    event Claimed(address indexed user, uint256 amount);
    event Refilled(address indexed by, uint256 amount);
    
    constructor(address _token) {
        token = ISpiritWolfToken(_token);
        owner = msg.sender;
    }
    
    function claim() external {
        require(token.isVerifiedHuman(msg.sender), "SPIRIT Faucet: Must be verified human");
        require(block.timestamp - lastClaim[msg.sender] >= COOLDOWN, "SPIRIT Faucet: Come back tomorrow");
        require(token.balanceOf(address(this)) >= dripAmount, "SPIRIT Faucet: Empty. Check back soon.");
        
        lastClaim[msg.sender] = block.timestamp;
        token.transfer(msg.sender, dripAmount);
        emit Claimed(msg.sender, dripAmount);
    }
    
    function claimFor(address recipient) external {
        require(token.isVerifiedHuman(msg.sender), "SPIRIT Faucet: Must be verified human");
        require(block.timestamp - lastClaim[msg.sender] >= COOLDOWN, "SPIRIT Faucet: Come back tomorrow");
        require(token.balanceOf(address(this)) >= dripAmount, "SPIRIT Faucet: Empty");
        lastClaim[msg.sender] = block.timestamp;
        token.transfer(recipient, dripAmount);
        emit Claimed(msg.sender, dripAmount);
    }
    
    function refill(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        emit Refilled(msg.sender, amount);
    }
    
    function remaining() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
    
    function setDripAmount(uint256 _amount) external {
        require(msg.sender == owner, "Only owner");
        require(_amount <= maxDrip, "Exceeds max drip");
        dripAmount = _amount;
    }
    
    function setMaxDrip(uint256 _max) external {
        require(msg.sender == owner, "Only owner");
        maxDrip = _max;
    }
}
