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

    
}
