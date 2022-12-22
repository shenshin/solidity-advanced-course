//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract AucEngine {
    address public owner;
    // constant - must be assigned at the declaration and can't be changed
    // immutable - can be assigned in the constructor
    uint256 constant DURATION = 2 days; // being converted into seconds
    uint256 constant FEE = 10; // %
    struct Auction {
        address payable seller;
        uint256 startingPrice;
        uint256 finalPrice;
        uint256 startAt; // time
        uint256 endAt;
        uint256 discountRate; // на сколко цена падает за каждую секунду
        string item; // what we sell
        bool stopped; // whether the auction is finished or not
    }
    Auction[] public auctions;
    event AuctionCreated(
        uint256 index,
        string itemName,
        uint256 startingPrice,
        uint256 duration
    );
    event AuctionEnded(uint256 index, uint256 finalPrice, address winner);

    constructor() {
        owner = msg.sender;
    }

    // calldata - immutable thing, being stored in memory
    function createAuction(
        uint256 _startingPrice,
        uint256 _discountRate,
        string calldata _item,
        uint256 _duration
    ) external {
        uint256 duration = _duration == 0 ? DURATION : _duration;
        // prevent price from turning negative
        require(
            _startingPrice >= _discountRate * duration,
            'increase starting price'
        );

        Auction memory newAuction = Auction({
            seller: payable(msg.sender),
            startingPrice: _startingPrice,
            finalPrice: _startingPrice,
            startAt: block.timestamp, // sec
            endAt: block.timestamp + duration, // sec
            discountRate: _discountRate,
            item: _item,
            stopped: false
            // what about adding a winner here
        });

        auctions.push(newAuction);

        emit AuctionCreated(
            auctions.length - 1,
            _item,
            _startingPrice,
            duration
        );
    }

    modifier notStopped(uint256 index) {
        require(!auctions[index].stopped, 'stopped!');
        _;
    }

    function getPriceFor(uint256 index)
        public
        view
        notStopped(index)
        returns (uint256)
    {
        Auction memory cAuction = auctions[index];
        uint256 elapsed = block.timestamp - cAuction.startAt;
        uint256 discount = elapsed * cAuction.discountRate;
        return cAuction.startingPrice - discount;
    }

    function buy(uint256 index) external payable notStopped(index) {
        Auction storage cAuction = auctions[index];
        require(cAuction.endAt > block.timestamp, "time's up");
        uint256 cPrice = getPriceFor(index);
        require(msg.value >= cPrice, 'payment insufficient');
        cAuction.stopped = true;
        cAuction.finalPrice = cPrice;
        uint256 refund = msg.value - cPrice;
        // отправить остаток денег назад покупателю
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        // отправить устроителю аукциона его выручку минус комиссия
        uint256 comission = (cPrice * FEE) / 100;
        cAuction.seller.transfer(cPrice - comission);
        emit AuctionEnded(index, cPrice, msg.sender);
    }
}
