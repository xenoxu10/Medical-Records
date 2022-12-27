//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
import "./shared.sol";
import "./myController.sol";
import "./RegulatorAgency.sol";
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
        record.status=true;
        
    }



    function requestRecord(uint Pid) public onlyDoctor

     {
         require(recordNum[Pid].status,"record not found");
        
       
        Shared.Request storage request= requestNum[Pid];
        request.doctor=msg.sender;  
       
      
        request.grant = false;
        request.oraclesEvaluated = false;
        //recordNum[PatientId[msg.sender]].requests[PatientId[msg.sender]] = request;  //check
         //recordNum[Regulator.returnPatientId(msg.sender)].requestCount += 1;
        
    }

     function respondRequest(uint Pid,uint _DocId, bool _grant) public onlyPatient  {
         requestNum[Pid].grant = _grant;
         requestNum[Pid].requestTime = block.timestamp;
        if (_grant) {
            //emit requestRespondedOracles();
        
            // call function after 2 hours
        }
     }

       
    function addOracleResponse( uint _DocId, bytes32 _bundleHash,uint256 Patientid,uint oracleId) public onlyOracle {
        Shared.Request storage request = requestNum[Patientid];
        require(recordNum[Patientid].bundleHashes == _bundleHash ,"record not found");
        require(request.grant, "Granted request required");
        require(!request.oraclesEvaluated, "Unevaluated request required");
        
        uint16 latency = (uint16)(block.timestamp - request.requestTime);
        request.oracleAddresses=msg.sender;
       
        
        if (latency <= 1 hours) {       
           evaluateOracles( _DocId,oracleId,Patientid);
       }
       
        else{
            request.oraclesEvaluated=false; 
        }

    
               

            // TODO: shouldn't be in ledger, directly send to measure reputation
           
            
        
    }
    
    
    
    event tokenCreatedDoctor(bytes32 tokenID, address oracleAddress); // oracle info
    event tokenCreatedOracle(bytes32 tokenID, address doctorAddress); // doctor info
    function evaluateOracles( uint _DocId,uint Oracleid,uint PatientID) internal {
    
        
        Shared.Request storage request = requestNum[PatientID];
        
        bytes32 tokenID = keccak256(abi.encodePacked(request.doctor,request.oracleAddresses, block.timestamp));
        
        emit tokenCreatedDoctor(tokenID, request.oracleAddresses);
        emit tokenCreatedOracle(tokenID, request.doctor);

        Regulator.submitDoctorToken(tokenID,request.oracleAddresses,_DocId);
        controller.submitOracleToken(tokenID, request.doctor,Oracleid);
        request.oraclesEvaluated=true;        
    }
   




     

     
}
