// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './GUArtAuction.sol';


//create God's Unchained (GU) art market to faciliate bidding and transfer of ownership or original GU Art using ERC-721 NFTs
contract GUArtMarket is ERC721, Ownable {
    constructor() ERC721("GUArtMarket", "GUAM") public {}
    
    // cast a payable address for the Martian Development Foundation to be the beneficiary in the auction
    // this contract is designed to have the owner of this contract (foundation) to pay for most of the function calls
    //deployer of the contract - address of the foundation
    // (all but bid and withdraw)
    address payable foundation_address = address(uint160(owner()));

    //using Counters for Counters.Counter;
    //Counters.Counter token_ids;

    mapping(uint => GUArtAuction) public auctions;

    //Art registered - check if it exists
    modifier GUartRegistered(uint token_id) {
        require(_exists(token_id), "Art not registered!");
        _;
    }

    function createAuction(uint token_id) public onlyOwner {
        auctions[token_id] = new GUArtAuction(foundation_address);
    }

    function getAuction(uint token_id) public view GUartRegistered(token_id) returns(GUArtAuction auction) {
        return auctions[token_id];
    }
    
    //pass on URI that contains metadata about the art.  only owner can call this to register the art
    //token_ids.increment();  //create new token id.. increment by 1
    //uint token_id = token_ids.current();  //unique token_id (1 higher than previous)
    function registerArt(string memory tokenURI) public payable onlyOwner {
        uint _id = totalSupply();
        _mint(msg.sender, _id);  //mint token and pass on id
        _setTokenURI(_id, tokenURI);  //set URI
        createAuction(_id);  //run create aunction function
    }

    //end aunction for particular token id.  checked to see if it exists first
    function endAuction(uint token_id) public onlyOwner GUartRegistered(token_id) {
        GUArtAuction auction = getAuction(token_id);
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
    }

    function auctionEnded(uint token_id) public view returns(bool) {
        GUArtAuction auction = auctions[token_id];
        return auction.ended();
    }

    function highestBid(uint token_id) public view GUartRegistered(token_id) returns(uint) {
        GUArtAuction auction = auctions[token_id];
        return auction.highestBid();
    }

    function pendingReturn(uint token_id, address sender) public view GUartRegistered(token_id) returns(uint) {
        GUArtAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }
    
    //allows users to send in ether and send to aunction contract
    //function sould be public payable to accept ether
    function bid(uint token_id) public payable GUartRegistered(token_id) {
        GUArtAuction auction = auctions[token_id];
        //accepting the address from the msg.sender
        auction.bid.value(msg.value)(msg.sender);
    }

}
