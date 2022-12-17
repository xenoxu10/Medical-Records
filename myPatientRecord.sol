//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
import "./Shared.sol";
import "./MyController.sol";
import "./Regulatory.sol";
contract PatientRecords{
    mapping(uint=> Shared.Record) public recordNum;
    mapping(uint=> Shared.Request) public requestNum;

    Controller controller;
    RegulatorAgency Regulator;
    
    constructor(address _RegulatoryAgencyAddress,address _contrllerAddress)
    {
        //require(msg.sender==Regulator.show_Manager(),"only manager can deploy controller smart contract");
    
        controller=Controller(_contrllerAddress);
        Regulator=RegulatorAgency(_RegulatoryAgencyAddress);
    }

   
    
     modifier onlyPatient {
      require(Regulator.isPatientRegistered(msg.sender),"first do the Patient registration");
       _;    
    }
    
     modifier onlyDoctor {
       require(Regulator.isDoctorRegistered(msg.sender),"first do the Doctor registration");
       _; 
    }
    modifier onlyOracle {
       require(controller.isOracleRegistered(msg.sender),"first do the Oracle registration registration");
       _; 
    }
   
    //function generate_doctorId()

    function addRecords(bytes32 _bundleHash) public onlyPatient {
    
         Shared.Record storage record = recordNum[Regulator.returnPatientId(msg.sender)];
        record.bundleHashes=_bundleHash;
        
    }



    function requestRecord(  ) public onlyDoctor

     {
        
       
        Shared.Request storage request= requestNum[Regulator.returnDoctorId(msg.sender)];
        request.doctor=msg.sender;  
        request.requestTime = block.timestamp;
      
        request.grant = false;
        request.oraclesEvaluated = false;
        //recordNum[PatientId[msg.sender]].requests[PatientId[msg.sender]] = request;  //check
         //recordNum[Regulator.returnPatientId(msg.sender)].requestCount += 1;
        
    }

     function respondRequest(uint _DocId, bool _grant) public onlyPatient  {
         requestNum[_DocId].grant = _grant;
        if (_grant) {
            //emit requestRespondedOracles();
        
            // call function after 2 hours
        }
     }

       
    function addOracleResponse( uint _DocId, bytes32 _bundleHash,uint256 Patientid,uint oracleId) public onlyOracle {
        Shared.Request storage request = requestNum[_DocId];
        require(recordNum[Patientid].bundleHashes == _bundleHash ,"record not found");
        require(request.grant, "Granted request required");
        require(!request.oraclesEvaluated, "Unevaluated request required");
        uint16 oracleRating;
        uint16 latency = (uint16)(block.timestamp - request.requestTime);
        
        if (latency <= 1 hours) {
                
            
                
            // TODO LATER: this should not be bundle hash but rather ks_kPp#
            uint16 input_start = 1;
            uint16 input_end = 3600;
            uint16 output_start = 2**16 - 1;
            uint16 output_end = 1;

            // TODO: make sure this is working correctly
             oracleRating *= output_start + ((output_end - output_start) / (input_end - input_start)) * (latency - input_start);
            request.oracleAddresses=msg.sender;
            request.oracleRatings[msg.sender] = oracleRating;
            
        
       
           evaluateOracles( _DocId,oracleId);
       }
       
        else{
            oracleRating = 0;
        }

    
               

            // TODO: shouldn't be in ledger, directly send to measure reputation
           
            
        
    }
    
    
    
    event tokenCreatedDoctor(bytes32 tokenID, address oracleAddress); // oracle info
    event tokenCreatedOracle(bytes32 tokenID, address doctorAddress); // doctor info
    function evaluateOracles( uint _DocId,uint Oracleid) internal {
    
        
        Shared.Request storage request = requestNum[_DocId];
        
        uint16 reputations = controller.getOracleReputations(Oracleid);
        uint16 ratings;
        
        address OracleAddress= request.oracleAddresses;
      
        
      
            uint16 oracleRating = request.oracleRatings[request.oracleAddresses];
            uint16 oracleReputation = reputations;
            
            uint16 oracleScore = oracleRating * (oracleReputation + 1)**2;
            
         
            
            ratings= oracleRating;
        
        
        controller.submitContractOracleRatings(ratings, Oracleid);
        
        bytes32 tokenID = keccak256(abi.encodePacked(request.doctor, OracleAddress, block.timestamp));
        
        emit tokenCreatedDoctor(tokenID, OracleAddress);
        emit tokenCreatedOracle(tokenID, request.doctor);

        Regulator.submitDoctorToken(tokenID,OracleAddress,_DocId);
        controller.submitOracleToken(tokenID, request.doctor,Oracleid);
        request.oraclesEvaluated=true;        
    }
   




     

     
}