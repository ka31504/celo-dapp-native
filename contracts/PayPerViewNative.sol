// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract PayPerViewNative {
    struct Content {
        address payable creator;
        uint256 priceWei;      // CELO (wei)
        uint64  accessWindow;  // seconds, 0 = lifetime
        bool    active;
    }

    mapping(bytes32 => Content) public contents; // contentId => config
    mapping(bytes32 => mapping(address => uint256)) public accessUntil; // contentId => viewer => ts

    event ContentUpserted(bytes32 indexed contentId, address creator, uint256 priceWei, uint64 window, bool active);
    event Purchased(bytes32 indexed contentId, address viewer, uint256 untilTs, uint256 priceWei);

    function upsertContent(bytes32 contentId, uint256 priceWei, uint64 accessWindow, bool active) external {
        Content storage c = contents[contentId];
        if (c.creator == address(0)) c.creator = payable(msg.sender);
        require(c.creator == msg.sender, "only creator");
        c.priceWei = priceWei; c.accessWindow = accessWindow; c.active = active;
        emit ContentUpserted(contentId, msg.sender, priceWei, accessWindow, active);
    }

    function buy(bytes32 contentId) external payable {
        Content memory c = contents[contentId];
        require(c.active && c.creator != address(0), "inactive");
        require(msg.value == c.priceWei, "bad value");
        (bool ok, ) = c.creator.call{value: msg.value}(""); require(ok, "pay failed");

        uint256 untilTs = c.accessWindow == 0 ? type(uint256).max : block.timestamp + c.accessWindow;
        accessUntil[contentId][msg.sender] = untilTs;
        emit Purchased(contentId, msg.sender, untilTs, c.priceWei);
    }

    function hasAccess(bytes32 contentId, address viewer) external view returns (bool) {
        return block.timestamp <= accessUntil[contentId][viewer];
    }
}
