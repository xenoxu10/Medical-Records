//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;


import "./Shared.sol";
import "./Regulatory.sol";

contract Controller {
    // State variables
     RegulatorAgency Regulator;
    address public owner;
   
    mapping (uint => Shared.Oracle)  public oracles;
   
    mapping(address =>uint)  OracleId;
  

    




    // Modifier
    modifier notOwner {
        require(msg.sender != owner, "Controller owner account cannot call this function");
        _;
    }
    
    modifier onlyNotRegistered {
       
        require(!oracles[OracleId[msg.sender]].registered, "Unregistered account required");
        _;
    }
    
    
    // Constructor
    constructor()  {
        owner = msg.sender;
       // require(owner==Regulator.show_Manager(),"only manager can deploy controller smart contract");
    }




    function generate_OracleId() public onlyNotRegistered returns(uint)
    {
        OracleId[msg.sender]=uint(keccak256(abi.encodePacked(msg.sender, block.timestamp)))%10**6;
        return OracleId[msg.sender];

    }



     // Oracle Functions
    function addOracle() public onlyNotRegistered notOwner {
        require(OracleId[msg.sender]!=0,"generate oracle id");
       oracles[OracleId[msg.sender]].registered = true;
       oracles[OracleId[msg.sender]].averageContractRating = 50;
       oracles[OracleId[msg.sender]].contractRatingCount = 0;
       oracles[OracleId[msg.sender]].averageDoctorRating = 50;
       oracles[OracleId[msg.sender]].doctorRatingCount = 0;
        
        //oracles[msg.sender] = oracle;
    }
    
    function isOracleRegistered(address _addr) view public returns (bool) {
        return oracles[OracleId[_addr]].registered;
    }

      function returnOracleId(address Oracle_Address) public view returns(uint)
    {
        return OracleId[Oracle_Address];
    }

   
    
    // TODO: maybe add a modifier
    function getOracleReputations(uint oracle) view public returns (uint16) {
        Shared.Oracle storage oraclestorage = oracles[oracle];
        uint16 reputations;

        // NOTE: we are assuming oracleAddresses 
       
            
            
        reputations = (oraclestorage.averageContractRating + oraclestorage.averageDoctorRating) / 2;
        
        return reputations;
    }
    
    function submitContractOracleRatings( uint16 _ratings,uint _id) external onlyNotRegistered {
         Shared.Oracle storage neworacle = oracles[_id];
       
             
           neworacle.averageContractRating = (neworacle.contractRatingCount *neworacle.averageContractRating + _ratings) / (neworacle.contractRatingCount + 1);
            neworacle.contractRatingCount += 1;
    }
    
   
    
    function submitOracleToken( bytes32 _tokenID, address _doctorAddress,uint _id) external onlyNotRegistered {
       oracles[_id].tokenIDs.push(_tokenID);
        oracles[_id].tokens[_tokenID] = Shared.OracleToken(true, _doctorAddress);
        
    }
    
    // TODO: think about the correct modifier here
   
}