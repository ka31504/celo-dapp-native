// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed from, address indexed to);
    constructor() { owner = msg.sender; emit OwnershipTransferred(address(0), msg.sender); }
    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "0 addr"); emit OwnershipTransferred(owner, newOwner); owner = newOwner;
    }
}

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status = _NOT_ENTERED;
    modifier nonReentrant() { require(_status != _ENTERED, "reentrancy"); _status = _ENTERED; _; _status = _NOT_ENTERED; }
}

contract PlayToEarnNative is Ownable, ReentrancyGuard {
    uint256 public rewardPerWin; // wei (CELO)
    uint256 public minScore;

    event Funded(address indexed from, uint256 amount);
    event Played(address indexed player, uint256 score, bool won, uint256 reward);
    event ParamsUpdated(uint256 rewardPerWin, uint256 minScore);
    event Withdrawn(address indexed to, uint256 amount);

    constructor(uint256 _rewardPerWin, uint256 _minScore) {
        rewardPerWin = _rewardPerWin; minScore = _minScore;
    }

    receive() external payable { emit Funded(msg.sender, msg.value); }
    function fund() external payable { emit Funded(msg.sender, msg.value); }

    function setParams(uint256 _rewardPerWin, uint256 _minScore) external onlyOwner {
        rewardPerWin = _rewardPerWin; minScore = _minScore; emit ParamsUpdated(_rewardPerWin, _minScore);
    }

    function play(uint256 score) external nonReentrant {
        bool won = score >= minScore && rewardPerWin > 0 && address(this).balance >= rewardPerWin;
        uint256 payout = won ? rewardPerWin : 0;
        if (won) {
            (bool ok, ) = payable(msg.sender).call{value: payout}("");
            require(ok, "payout failed");
        }
        emit Played(msg.sender, score, won, payout);
    }

    function withdraw(uint256 amount) external onlyOwner nonReentrant {
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "withdraw failed"); emit Withdrawn(msg.sender, amount);
    }
}
