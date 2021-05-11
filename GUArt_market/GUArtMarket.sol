pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "./GUArtAuction.sol";

//create God's Unchained (GU) art market to faciliate bidding and transfer of ownership or original GU Art using ERC-721 NFTs
contract GUArtMarket is ERC721Full, Ownable {

    constructor() ERC721Full("GUArtMarket", "GUAM") public {}

    using Counters for Counters.Counter;

    Counters.Counter token_ids;

    address payable foundation_address = msg.sender;  //deployer of the contract - address of the foundation

    mapping(uint => GUArtMarket) public auctions;

    //Art registered - check if it exists
    modifier GUartRegistered(uint token_id) {
        require(_exists(token_id), "Art not registered!");
        _;
    }

    function createAuction(uint token_id) public onlyOwner {
        auctions[token_id] = new GUArtAuction(foundation_address);
    }
    
    //pass on URI that contains metadata about the art.  only owner can call this to register the art
    function registerLand(string memory uri) public payable onlyOwner {
        //create new token id.. increment by 1
        token_ids.increment();
        
        //unique token_id (1 higher than previous)
        uint token_id = token_ids.current();
        
        //mint token and pass on id
        _mint(foundation_address, token_id);
        
        //set URI
        _setTokenURI(token_id, uri);
        
        //run create aunction function
        createAuction(token_id);
    }

    //end aunction for particular token id.  checked to see if it exists first
    function endAuction(uint token_id) public onlyOwner GUartRegistered(token_id) {
        //
        GUArtAuction auction = auctions[token_id];
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
    function bid(uint token_id) public payable GUartRegistered(token_id) {
        GUArtAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }

}
