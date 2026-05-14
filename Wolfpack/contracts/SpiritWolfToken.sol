// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts-upgradeable@5.2.0/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.2.0/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.2.0/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.2.0/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.2.0/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.2.0/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.2.0/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts@5.2.0/utils/Strings.sol";
import "@openzeppelin/contracts@5.2.0/utils/Base64.sol";

/// @title SpiritWolf Token ($SPIRIT) — UUPS Upgradeable
/// @notice Full-featured ERC-20 with anti-sweeper protocol, human verification, and staking
contract SpiritWolfToken is Initializable, ERC20Upgradeable, ERC20PermitUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable, UUPSUpgradeable {

    uint256 public constant TOTAL_SUPPLY = 100_000_000 ether;
    uint256 public constant COOLDOWN = 30 seconds;
    uint256 public constant MAX_UNVERIFIED_TX = 1000 ether;
    uint256 public constant HUMAN_STAKE = 0.01 ether;
    uint256 public constant LOCK_PERIOD = 7 days;

    mapping(address => uint256) public lastTransferTime;
    mapping(address => bool) public isVerifiedHuman;
    mapping(address => uint256) public humanStakeAmount;
    mapping(address => uint256) public humanStakeLocked;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakeTimestamp;
    mapping(address => uint256) public rewards;

    uint256 public totalStaked;
    uint256 public rewardRate;
    address public feeRecipient;
    address public backupAdmin;
    uint256 public backupRequestedAt;
    uint256 public constant BACKUP_TIMELOCK = 7 days;

    event HumanVerified(address indexed user, uint256 stakeAmount);
    event HumanRevoked(address indexed user);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);
    event SweeperBlocked(address indexed sweeper, uint256 amount);
    event BackupAdminSet(address indexed backup);
    event OwnershipTransferRequested(address indexed backup, uint256 timestamp);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    function initialize(address _feeRecipient) public initializer {
        __ERC20_init("SpiritWolf Token", "SPIRIT");
        __ERC20Permit_init("SpiritWolf Token");
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        require(_feeRecipient != address(0));
        feeRecipient = _feeRecipient;
        rewardRate = 10;
        _mint(msg.sender, TOTAL_SUPPLY);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /// @notice Transfers with built-in anti-sweeper protection
    function transfer(address to, uint256 value) public override whenNotPaused returns (bool) {
        _enforceAntiSweeper(msg.sender, to, value);
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public override whenNotPaused returns (bool) {
        _enforceAntiSweeper(from, to, value);
        return super.transferFrom(from, to, value);
    }

    function _enforceAntiSweeper(address from, address to, uint256 value) private {
        if (from == owner() || to == address(0) || to == address(this)) return;
        require(block.timestamp - lastTransferTime[from] >= COOLDOWN, "SPIRIT: Cooldown active");
        if (value > MAX_UNVERIFIED_TX && !isVerifiedHuman[from]) {
            emit SweeperBlocked(from, value);
            revert("SPIRIT: Human verification required for transfers over 1000 SPIRIT");
        }
        lastTransferTime[from] = block.timestamp;
    }

    function proveHumanity() external payable nonReentrant {
        require(msg.value >= HUMAN_STAKE, "SPIRIT: Minimum 0.01 POL");
        require(!isVerifiedHuman[msg.sender], "SPIRIT: Already verified");
        isVerifiedHuman[msg.sender] = true;
        humanStakeAmount[msg.sender] = msg.value;
        humanStakeLocked[msg.sender] = block.timestamp + LOCK_PERIOD;
        emit HumanVerified(msg.sender, msg.value);
    }

    function releaseHumanStake() external nonReentrant {
        require(isVerifiedHuman[msg.sender], "SPIRIT: Not verified");
        require(block.timestamp >= humanStakeLocked[msg.sender], "SPIRIT: Still locked");
        uint256 amount = humanStakeAmount[msg.sender];
        humanStakeAmount[msg.sender] = 0;
        isVerifiedHuman[msg.sender] = false;
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "SPIRIT: Transfer failed");
        emit HumanRevoked(msg.sender);
    }

    function stake(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0 && balanceOf(msg.sender) >= amount, "SPIRIT: Insufficient");
        _updateRewards(msg.sender);
        _transfer(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        if (stakeTimestamp[msg.sender] == 0) stakeTimestamp[msg.sender] = block.timestamp;
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0 && stakedBalance[msg.sender] >= amount, "SPIRIT: Insufficient staked");
        _updateRewards(msg.sender);
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;
        if (stakedBalance[msg.sender] == 0) stakeTimestamp[msg.sender] = 0;
        _transfer(address(this), msg.sender, amount + reward);
        emit Unstaked(msg.sender, amount, reward);
    }

    function claimRewards() external nonReentrant {
        _updateRewards(msg.sender);
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "SPIRIT: No rewards to claim");
        rewards[msg.sender] = 0;
        _transfer(address(this), msg.sender, reward);
    }

    function _updateRewards(address staker) private {
        if (stakedBalance[staker] == 0) return;
        uint256 timeStaked = block.timestamp - stakeTimestamp[staker];
        uint256 annualRate = rewardRate * 10;
        uint256 reward = (stakedBalance[staker] * annualRate * timeStaked) / (365 days * 1000);
        rewards[staker] += reward;
        stakeTimestamp[staker] = block.timestamp;
    }

    function pendingRewards(address staker) external view returns (uint256) {
        if (stakedBalance[staker] == 0) return rewards[staker];
        uint256 timeStaked = block.timestamp - stakeTimestamp[staker];
        uint256 annualRate = rewardRate * 10;
        uint256 newReward = (stakedBalance[staker] * annualRate * timeStaked) / (365 days * 1000);
        return rewards[staker] + newReward;
    }

    function setRewardRate(uint256 _rate) external onlyOwner { rewardRate = _rate; }
    function setFeeRecipient(address _recipient) external onlyOwner { feeRecipient = _recipient; }
    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
    
    function setBackupAdmin(address _backup) external onlyOwner { backupAdmin = _backup; emit BackupAdminSet(_backup); }
    function requestOwnership() external { require(msg.sender == backupAdmin, "Not backup"); backupRequestedAt = block.timestamp; emit OwnershipTransferRequested(msg.sender, block.timestamp); }
    function claimOwnership() external { require(msg.sender == backupAdmin, "Not backup"); require(backupRequestedAt > 0 && block.timestamp >= backupRequestedAt + BACKUP_TIMELOCK, "Too soon"); _transferOwnership(backupAdmin); backupRequestedAt = 0; }

    function tokenURI() external pure returns (string memory) {
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(string.concat(
                '{"name":"SpiritWolf Token","symbol":"SPIRIT",',
                '"description":"Native token of the Spirit Wolf ecosystem with anti-sweeper protection and staking rewards.",',
                '"image":"ipfs://QmbcGbUDxRMQFM47zqy469PJfGcEFbg6BBomSfLZJawy5J",',
                '"banner":"ipfs://QmVZzHG4UKZ8QtbGvMsQMH8YiYfpgHUWE3FbhmhFXYHpNb",',
                '"smallest_unit":"Pup",',
                '"external_url":"https://spiritwolf3397.github.io/spirit-wolf"}'
            )))
        ));
    }
}
