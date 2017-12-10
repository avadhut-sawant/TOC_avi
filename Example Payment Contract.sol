pragma solidity ^0.4.18;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract Transfer is usingOraclize {

    string response;
    bytes32 id;
    
    function __callback(bytes32 myid, string result) public {
        require(msg.sender == oraclize_cbAddress());
            response = result;
            id = myid;
    }

    function doTransaction() public {
        oraclize_setProof(proofType_NONE);
       oraclize_query("URL","http://52.18.174.96:8880/getCustomerBalances",'{"company":"GB0010001","passWord":"123456","userName" :"HACKATHON1","customerId": "190856"}');
    }
    
    function getResult() constant public returns(string){
        return response;
    }
}