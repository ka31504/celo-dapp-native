// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// OpenZeppelin imports qua URL (Remix tự tải)
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.9.3/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v4.9.3/contracts/utils/Counters.sol";


contract Ownable2 {
    address public owner;
    event OwnershipTransferred(address indexed from, address indexed to);
    constructor() { owner = msg.sender; emit OwnershipTransferred(address(0), msg.sender); }
    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "0 addr"); emit OwnershipTransferred(owner, newOwner); owner = newOwner;
    }
}

contract ReentrancyGuard2 {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status = _NOT_ENTERED;
    modifier nonReentrant() { require(_status != _ENTERED, "reentrancy"); _status = _ENTERED; _; _status = _NOT_ENTERED; }
}

contract Ticketing721Native is ERC721URIStorage, Ownable2, ReentrancyGuard2 {
    using Counters for Counters.Counter;
    Counters.Counter private _ids;

    struct EventInfo {
        string name;
        uint256 priceWei;      // CELO (wei)
        uint64  eventStart;
        uint64  maxSupply;
        uint64  sold;
        bool    lockTransfersUntilStart;
        string  baseURI;
        address payable payout;
        bool    active;
    }

    mapping(uint256 => EventInfo) public eventsInfo;
    mapping(uint256 => uint256) public ticketEvent; // tokenId -> eventId

    event EventCreated(uint256 indexed eventId, string name, uint256 priceWei, uint64 start, uint64 maxSupply);
    event TicketMinted(uint256 indexed eventId, uint256 indexed tokenId, address buyer, uint256 priceWei);
    event EventStatus(uint256 indexed eventId, bool active);

    constructor() ERC721("CeloTicket", "CTIX") {}

    function createEvent(
        string memory name,
        uint256 priceWei,
        uint64 eventStart,
        uint64 maxSupply,
        bool lockTransfersUntilStart,
        string memory baseURI,
        address payable payout
    ) external onlyOwner returns (uint256 eventId) {
        require(maxSupply > 0, "supply=0");
        require(payout != address(0), "payout=0");
        _ids.increment(); eventId = _ids.current();
        eventsInfo[eventId] = EventInfo({
            name: name,
            priceWei: priceWei,
            eventStart: eventStart,
            maxSupply: maxSupply,
            sold: 0,
            lockTransfersUntilStart: lockTransfersUntilStart,
            baseURI: baseURI,
            payout: payout,
            active: true
        });
        emit EventCreated(eventId, name, priceWei, eventStart, maxSupply);
    }

    function setActive(uint256 eventId, bool active) external onlyOwner {
        eventsInfo[eventId].active = active; emit EventStatus(eventId, active);
    }

    function buy(uint256 eventId) external payable nonReentrant {
        EventInfo storage ev = eventsInfo[eventId];
        require(ev.active, "inactive");
        require(ev.sold < ev.maxSupply, "sold out");
        require(msg.value == ev.priceWei, "bad value");
        (bool ok, ) = ev.payout.call{value: msg.value}(""); require(ok, "pay failed");

        uint256 tokenId = uint256(keccak256(abi.encodePacked(eventId, ev.sold + 1, block.prevrandao, msg.sender)));
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, string(abi.encodePacked(ev.baseURI, _toString(tokenId), ".json")));
        ticketEvent[tokenId] = eventId;
        ev.sold++;

        emit TicketMinted(eventId, tokenId, msg.sender, ev.priceWei);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal override
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        if (from != address(0)) {
            EventInfo memory ev = eventsInfo[ticketEvent[tokenId]];
            if (ev.lockTransfersUntilStart) {
                require(block.timestamp >= ev.eventStart, "locked until event start");
            }
        }
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value; uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) { digits -= 1; buffer[digits] = bytes1(uint8(48 + uint256(value % 10))); value /= 10; }
        return string(buffer);
    }
}
