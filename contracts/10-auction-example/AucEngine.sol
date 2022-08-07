//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract AucEngine {
  address public owner;
  // constant - must be assigned at the declaration and can't be changed
  // immutable - can be assigned in the constructor
  uint constant DURATION = 2 days; // being converted into seconds
  uint constant FEE = 10; // %
  struct Auction {
    address payable seller;
    uint startingPrice;
    uint finalPrice;
    uint startAt; // time
    uint endAt;
    uint discountRate; // на сколко цена падает за каждую секунду
    string item; // what we sell
    bool stopped; // whether the auction is finished or not
  }
  Auction[] public auctions;
  event AuctionCreated(uint index, string itemName, uint startingPrice, uint duration);
  event AuctionEnded(uint index, uint finalPrice, address winner);
  constructor() {
    owner = msg.sender;
  }

// calldata - immutable thing, being stored in memory
  function createAuction(uint _startingPrice, uint _discountRate, string calldata _item, uint _duration ) external {
    uint duration = _duration == 0 ? DURATION : _duration;
    // prevent price from turning negative
    require(_startingPrice >= _discountRate * duration, "increase starting price");

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

    emit AuctionCreated(auctions.length - 1, _item, _startingPrice, duration);
  }
  modifier notStopped(uint index) {
    require(!auctions[index].stopped, "stopped!");
    _;
  }

  function getPriceFor(uint index) public view notStopped(index) returns(uint) {
    Auction memory cAuction = auctions[index];
    uint elapsed = block.timestamp - cAuction.startAt;
    uint discount = elapsed * cAuction.discountRate;
    return cAuction.startingPrice - discount;
  }

  function buy(uint index) external payable notStopped(index) {
    Auction storage cAuction = auctions[index];
    require(cAuction.endAt > block.timestamp, "time's up");
    uint cPrice = getPriceFor(index);
    require(msg.value >= cPrice, "payment insufficient");
    cAuction.stopped = true;
    cAuction.finalPrice = cPrice;
    uint refund = msg.value - cPrice;
    // отправить остаток денег назад покупателю
    if (refund > 0) {
      payable(msg.sender).transfer(refund);
    }
    // отправить устроителю аукциона его выручку минус комиссия
    uint comission = (cPrice * FEE) / 100;
    cAuction.seller.transfer(cPrice - comission);
    emit AuctionEnded(index, cPrice, msg.sender);
  }
}