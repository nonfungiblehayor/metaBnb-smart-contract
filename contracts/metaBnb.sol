pragma solidity ^0.8.0; //SPDX-License-Identifier: UNLICENSED
// contract address on polygon mumbai scan == 0xbDfDF4b2a0DF9B5548dC98463b02e5ee39dcb11a;

contract metaBnb {

    address payable metaEstateAdmin;

    constructor() {
       metaEstateAdmin = payable(msg.sender);
    }

    event transfer(address indexed from, address indexed to, uint indexed tokenId);
    event _approve(address indexed owner, address indexed spender, uint indexed tokenId);
    event _allApproval(address indexed owner, address indexed operator, uint indexed tokenId);

    mapping(uint => address) public _ownerOf;
    mapping(address => uint) public _balanceOf;
    mapping(address => mapping(address => uint)) public _approvalForAll;
    mapping(uint => address) public _approvals;
    mapping(uint => bool) public tokenState;

    uint public uniqueIds;
    uint maxBuyperOnce = 1;

    // function ownerOf(uint tokenId) external view  returns(address owner) {
    //     require(owner != address(0));
    //     return _ownerOf[tokenId];
    // }

    function balanceOf(address owner) external view  returns(uint) {
        return _balanceOf[owner];
    }

    function buyMetaHouse(address buyer, uint price, uint amountToBuy) external payable {
        require(price == msg.value);
        require(amountToBuy == maxBuyperOnce);
        if(coOwner[buyer] == true) {
            metaEstateAdmin.transfer(price);
            _balanceOf[buyer] += amountToBuy;
            _ownerOf[uniqueIds + 1] = buyer;
            tokenState[uniqueIds + 1] = true;
            uniqueIds ++;            
        } else {
            metaEstateAdmin.transfer(price);
            _balanceOf[buyer] += amountToBuy;
            _ownerOf[uniqueIds + 1] = buyer;
            uniqueIds ++;
        }
    }

    function getApprovalState(address investor) private view returns(bool) {
        return approvals[investor];
    }

     function getTokenState(uint tokenId) external view returns(bool) {
        return tokenState[tokenId];
    }


    function sellMetaHouse(address seller, address newOwner, uint tokenID, uint amountToSell) external {
        require(seller == msg.sender);
        require(_ownerOf[tokenID] == seller);
        require(_balanceOf[seller] >= amountToSell && amountToSell != 0);
         if(coOwner[seller] == true) {
            require(tokenState[tokenID] != true);
            _ownerOf[tokenID] = newOwner;
            _balanceOf[newOwner] += amountToSell;
            _balanceOf[seller] -= amountToSell;
         } else {
             _ownerOf[tokenID] = newOwner;
            _balanceOf[newOwner] += amountToSell;
            _balanceOf[seller] -= amountToSell;

         }
    }

    mapping(address => uint) public rentDueDate;
    mapping(address => mapping(address =>bool)) public rentLedger;
    mapping(address => uint) public rentAmountsLedger;
    mapping(address => uint) public durationRecord;

    function rentMetaHouse(address payable owner, address renter, uint tokenID, uint duration, uint rentAmount) payable external {
        require(_ownerOf[tokenID] == owner);
        require(_balanceOf[owner] >= 1);
        require(tokenState[tokenID] != true);
        require(msg.sender == renter);
        uint time = 0 seconds; 
        uint durations = duration + time;    
        uint totalPayment = rentAmount * duration;
        require(totalPayment == msg.value);
        totalPayment = msg.value;
        owner.transfer(totalPayment);
        _ownerOf[tokenID] = renter;
        rentLedger[renter][owner] = true;
        rentAmountsLedger[renter] = totalPayment;
        durationRecord[renter] = duration;
        rentDueDate[renter] = block.timestamp + durations;
    }

    function claimRentedHouse(address owner, address renter, uint tokenID) external {
        require(block.timestamp >= rentDueDate[renter]);
        require(rentLedger[renter][owner] == true);
        rentLedger[renter][owner] = false;
        _ownerOf[tokenID] = owner;
        delete rentDueDate[renter];
    } 

    function cancelRentDeal(address payable owner, address payable renter, uint tokenID, uint duration,uint rentAmount) external payable {
        require(block.timestamp < rentDueDate[renter]);
        require(rentLedger[renter][owner] == true);
        require(rentAmount == rentAmountsLedger[renter]);
        require(durationRecord[renter] == duration);
        require(msg.sender == owner);
        uint currentTime = block.timestamp;
        uint awaitingTime = rentDueDate[renter] - currentTime;
        uint cancelAmount = awaitingTime * duration;
        renter.transfer(cancelAmount);
        _ownerOf[tokenID] = owner;
    }

    mapping(address => mapping(address => bool)) public leaseAgreementLedger;
    mapping(address => mapping(address => uint)) public leaseAgreementAmount;
    mapping(address => mapping(address => uint)) public leaseAgreementDuration;


// 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db leaser
// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 owner
    
    function setLeaseAgreement(address owner, address leasePartner, uint tokenId, uint leaseAmount, uint leasePeriod) external {
        require(_ownerOf[tokenId] == owner);
        require(msg.sender == leasePartner);
        require(_balanceOf[owner] >= 1);
        require(tokenState[tokenId] != true);
        uint leaseDuration = block.timestamp + leasePeriod + 0 minutes;
        leaseAgreementLedger[owner][leasePartner] = true;
        leaseAgreementAmount[owner][leasePartner] = leaseAmount + 0 wei;
        leaseAgreementDuration[owner][leasePartner] = leaseDuration;
        _ownerOf[tokenId] = leasePartner;
    } 

    function returnLeaseItem(address payable owner, address payable leasePartner, uint tokenId, uint leaseAmount) payable external {
        require(block.timestamp >= leaseAgreementDuration[owner][leasePartner]);
        require(leaseAmount == leaseAgreementAmount[owner][leasePartner]);
        require(msg.sender == leasePartner);
        require(_ownerOf[tokenId] == leasePartner);
        require(leaseAgreementLedger[owner][leasePartner] == true);
        require(leaseAmount == msg.value);
        owner.transfer(leaseAmount);
        _ownerOf[tokenId] = owner;
        delete leaseAgreementAmount[owner][leasePartner];
        delete leaseAgreementDuration[owner][leasePartner];
        delete leaseAgreementLedger[owner][leasePartner];
    }

    enum partnerToken {
        coOwn
    }

    mapping(address => mapping(address => bool)) public partners;
    mapping(address => bool) public coOwner;
    mapping(address => mapping(address => uint)) public partnerAmount;
    // mapping(address => mapping(address => uint)) public partnerLedger;

    function buyWithAPartner(address payable partner1, address payable partner2, uint amount) payable external {
        require(msg.sender == partner2);
        amount = msg.value;
        partners[partner1][partner2] = true;
        partnerAmount[partner1][partner2] = amount;
        coOwner[partner1] = true;
        partner1.transfer(amount);
    }

    mapping(address => bool) public approvals;
    function approvePartner(address partner1, address approvingPartner, uint tokenID) external {
        require(partners[partner1][approvingPartner] == true);
        require(tokenState[tokenID] == true);
        require(msg.sender == approvingPartner);
        tokenState[tokenID] = false;
    }

    function buyOutPartner(address payable partner1, address payable buyingPartner, uint tokenID, uint buyingAmount) payable external {
        require(partners[partner1][buyingPartner] == true);
        require(tokenState[tokenID] == false);
        require(approvals[partner1] == true);
        require(partnerAmount[partner1][buyingPartner] == buyingAmount);
        require(msg.sender == buyingPartner);
        _ownerOf[tokenID] = buyingPartner;
        partner1.transfer(buyingAmount);
        delete partners[partner1][buyingPartner];
        delete partnerAmount[partner1][buyingPartner];
    }

    function sellPartnership(address partner1, address sellingPartner, uint amount, uint tokenID, address newPartner) external {
        require(msg.sender == sellingPartner);
        require(tokenState[tokenID] == false);
        require(approvals[partner1] == true);
        partners[partner1][newPartner] = true; 
        partnerAmount[partner1][newPartner] = amount;      
        delete partners[partner1][sellingPartner];
        delete partnerAmount[partner1][sellingPartner];
    }

}
