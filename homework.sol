// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenVestingPool {
    address public admin;
    IERC20 public token;
    uint256 public vestingStartTime;
    uint256 public vestingDuration;
    uint256 public cliffDuration;
    uint256 public totalAllocatedTokens;
    mapping(address => uint256) public vestedTokens;

    event TokensVested(address beneficiary, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can call this function");
        _;
    }

    modifier onlyAfterCliff() {
        require(block.timestamp >= vestingStartTime + cliffDuration, "Cliff period has not ended");
        _;
    }

    constructor(
        address _admin,
        address _token,
        uint256 _vestingStartTime,
        uint256 _vestingDuration,
        uint256 _cliffDuration
    ) {
        require(_admin != address(0), "Invalid admin address");
        require(_token != address(0), "Invalid token address");
        require(_vestingDuration > 0, "Vesting duration must be greater than 0");
        require(_cliffDuration <= _vestingDuration, "Cliff duration must be less than or equal to vesting duration");

        admin = _admin;
        token = IERC20(_token);
        vestingStartTime = _vestingStartTime;
        vestingDuration = _vestingDuration;
        cliffDuration = _cliffDuration;
    }
function allocateTokens(address _beneficiary, uint256 _amount) external onlyAdmin {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_amount > 0, "Allocation amount must be greater than 0");
        require(totalAllocatedTokens + _amount <= token.balanceOf(address(this)), "Not enough tokens in the pool");

        totalAllocatedTokens += _amount;
        vestedTokens[_beneficiary] += _amount;

        emit TokensVested(_beneficiary, _amount);
    }
    function claimVestedTokens() external onlyAfterCliff {
        uint256 availableTokens = getVestedTokens(msg.sender);
        require(availableTokens > 0, "No vested tokens available");

        vestedTokens[msg.sender] = 0;
        require(token.transfer(msg.sender, availableTokens), "Token transfer failed");
        emit TokensVested(msg.sender, availableTokens);
    }
function getVestedTokens(address _beneficiary) public view returns (uint256) {
        if (block.timestamp < vestingStartTime) {
            return 0;
        } else if (block.timestamp >= vestingStartTime + vestingDuration) {
            return vestedTokens[_beneficiary];
        } else {
            uint256 timeSinceStart = block.timestamp - vestingStartTime;
            uint256 vestedPercentage = (timeSinceStart * 100) / vestingDuration;
            return (vestedTokens[_beneficiary] * vestedPercentage) / 100;
        }
    }

    function remainingBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getVestingDetails() external view returns (uint256, uint256, uint256, uint256) {
        return (vestingStartTime, vestingDuration, cliffDuration, totalAllocatedTokens);
    }
}
