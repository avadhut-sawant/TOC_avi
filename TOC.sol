pragma solidity ^0.4.18;

// Core Contract for Trusted Chain Offer
contract TCO {
    // Contract Variables
	address validMerchant;
	address validCustomer;
	address owner;
	uint offerID;
	uint responseID;

    // Model for the Structured Offer
	struct Offer{
		address offerer;
		bytes16 productID;
		uint acceptance;
		uint support;	
		uint discount_percent;
		uint acceptance_received;
	}
	
	// Same Response can be modeled for 
	// both Standard and Free Form Offers
    struct Response{	
		uint offerID;
		address Acceptor;
		uint AgreedAcceptance;
	}

	// Model for the Free Form Offer
	struct ffOffer {
		address ffofferer;
		bytes32 need;
		uint deal;
	}
	
	// Instantiate the offer types and responses
	mapping (uint => Offer) Offers;
	uint[] public offers; 

	mapping (uint => Response) Responses;
	uint[] public responses;

	mapping (uint => ffOffer) freeFormOffers;
	uint[] public ffidx;

    // Denotes the Contract Owner
	modifier onlyOwner{
        require(msg.sender == owner);
        _;
 	}

    //1. Set the Contract owner
    //2. Initialiae the set of Valid Offerers and Acceptors
    //3. Initialize the Offer ID and Response ID Keys
	function TCO() public{
        owner = msg.sender;
		validMerchant = bytesToAddress("0xb8c7185df05220f80e5dd9578a03f854a9505271");
		validCustomer = bytesToAddress("0xb8c7185df05220f80e5dd9578a03f854a9505271");
		offerID = 0;
		responseID = 0;
    }    
	
	//Utility function to convert string to address
    function bytesToAddress (bytes b) constant public returns (address) {
    uint result = 0;
    for (uint i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 16 + (c - 48);
            }
            if(c >= 65 && c<= 90) {
                result = result * 16 + (c - 55);
            }
            if(c >= 97 && c<= 122) {
                result = result * 16 + (c - 87);
            }
        }
        return address(result);
    }

    // Denotes Valid Merchants / Offerers
	modifier onlyValidMerchant{
		require (msg.sender == validMerchant);	
		_;
	}

    //1. Offer initiated by Offerer / Merchant
    //2. Offer Responded by Customer / Acceptors
    //3. Offer Completed > threshold limit satisfied
	event OfferCreated(uint offerID, bytes16 productID, uint acceptance, uint support, uint discount_percent, address merchant);
	event OfferResponded(uint offerID,uint acceptance);
	event OfferCompleted(uint offerID,uint total_accept);
    event ffOfferCreated(uint offerID, bytes32 need, uint deal);
    
    //Generate Offer IDs 
	function ObtainOfferID() private {
		offerID = offerID + 1;
	}

    //1. Create the "Structured" offer as desired by the offerer
    //2. Raise the appropriate event for acceptors / Customers
	function setOffer(bytes16 _productID, uint _acceptance, uint _support, uint _dis_percent) public 	{

		ObtainOfferID();	
      	var offer = Offers[offerID];

        offer.offerer = msg.sender;
        offer.productID = _productID;
        offer.acceptance = _acceptance;
	    offer.support = _support;
	    offer.discount_percent = _dis_percent;
	    offer.acceptance_received = 0; 	
        
        offers.push(offerID) -1;

 	    OfferCreated(offerID, _productID, _acceptance, _support, _dis_percent, msg.sender);	
    }

    //1. Create the Response (common for Structured and Free Form offers)
    //2. Raise event of Offer Acceptance
	function setResponse(uint _offerID, uint _acceptance) public{

		responseID = responseID + 1;

		var response = Responses[responseID];
		response.offerID = _offerID;
		response.Acceptor = msg.sender;
		response.AgreedAcceptance = _acceptance;	
		Offers[offerID].acceptance_received = Offers[offerID].acceptance_received + _acceptance;
		
		responses.push(responseID) -1;
		
		if (Offers[offerID].acceptance_received < Offers[offerID].acceptance) {
			OfferResponded(_offerID, _acceptance);
		} else {
			OfferCompleted(_offerID, Offers[offerID].acceptance_received);	
		}
    }
 
    // Set the Free form Need from Customer   
    function setffNeed(bytes32 _need, uint _deal) public{
		
		offerID = offerID + 1;
		
      	var ffoffer = freeFormOffers[offerID];

		ffoffer.ffofferer = msg.sender;			
		ffoffer.need = _need;
		ffoffer.deal = _deal;

		ffidx.push(offerID) -1;
		
		ffOfferCreated(offerID, _need, _deal);
    }

    //1. Create the Response (common for Structured and Free Form offers)
    //2. Raise event of Offer Deal
	function setFFResponse(uint _offerID) public{

    		responseID = responseID + 1;

	    	var response = Responses[responseID];
		    response.offerID = _offerID;
		    response.Acceptor = msg.sender;
		    response.AgreedAcceptance = freeFormOffers[_offerID].deal;	

		    responses.push(responseID) -1;
		
			OfferCompleted(_offerID, freeFormOffers[_offerID].deal);
    }

    // Getter Functions for quick checks
    function getOfferLength() constant public returns(uint){
        return offers.length;
    }    
    
    // Getter Functions for quick checks
    function getOffers(uint _id) constant public returns(address,bytes16,uint){
        return (Offers[_id].offerer,Offers[_id].productID,Offers[_id].acceptance);
    }
}