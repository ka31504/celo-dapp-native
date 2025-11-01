// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ReentrancyGuard3 {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status = _NOT_ENTERED;
    modifier nonReentrant() { require(_status != _ENTERED, "reentrancy"); _status = _ENTERED; _; _status = _NOT_ENTERED; }
}

contract CreatorStreamNative is ReentrancyGuard3 {
    struct Stream {
        address sponsor;
        address payable creator;
        uint128 start;
        uint128 end;
        uint256 total;
        uint256 withdrawn;
    }

    uint256 public nextId;
    mapping(uint256 => Stream) public streams;

    event StreamCreated(uint256 indexed id, address sponsor, address creator, uint128 start, uint128 end, uint256 total);
    event Withdraw(uint256 indexed id, address creator, uint256 amount);

    function createStream(address payable creator, uint128 start, uint128 end) external payable returns (uint256 id) {
        require(creator != address(0), "creator=0");
        require(end > start, "bad time");
        require(msg.value > 0, "no funds");

        id = ++nextId;
        streams[id] = Stream({
            sponsor: msg.sender,
            creator: creator,
            start: start,
            end: end,
            total: msg.value,
            withdrawn: 0
        });
        emit StreamCreated(id, msg.sender, creator, start, end, msg.value);
    }

    function withdrawable(uint256 id) public view returns (uint256) {
        Stream memory s = streams[id];
        if (block.timestamp <= s.start) return 0;
        uint256 elapsed = block.timestamp < s.end ? (block.timestamp - s.start) : (s.end - s.start);
        uint256 duration = s.end - s.start;
        uint256 earned = (s.total * elapsed) / duration;
        return earned > s.withdrawn ? (earned - s.withdrawn) : 0;
    }

    function withdraw(uint256 id, uint256 amount) external nonReentrant {
        Stream storage s = streams[id];
        require(msg.sender == s.creator, "not creator");
        uint256 avail = withdrawable(id);
        require(amount > 0 && amount <= avail, "bad amount");
        s.withdrawn += amount;
        (bool ok, ) = s.creator.call{value: amount}("");
        require(ok, "transfer failed");
        emit Withdraw(id, s.creator, amount);
    }
}
