//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

library Shared {
    // Structs
    
    struct Record {
        bytes32 bundleHashes;  // Access rules
        bool status;
       
        // TODO: uint bundleSize; // Can be requested from IPFS through oracles to measure throughput instead of latency
    }
    
    struct Request {
        address doctor; // Requester
        uint256 requestTime; // Time of receiving a request
      
        
        bool grant; // Decision of patient to consent or not
        
        bool oraclesEvaluated;
        address oracleAddresses;
       
    }
    
    struct Patient {
        bool registered;
    }
    
    struct Doctor {
        bool registered;
        
        bytes32[] tokenIDs;
        mapping (bytes32 => DoctorToken) tokens;
    }
    
    struct DoctorToken {
        bool exists;
        address oracleAddress;
        
        // TODO: maybe here we should have info about the file
    }

    struct Oracle {
        bool registered;
        
       
        
        bytes32[] tokenIDs;
        mapping (bytes32 => OracleToken) tokens;
    }
    
    struct OracleToken {
        bool exists;
        address doctorAddress;
        // TODO: maybe here we should have info about the file
    }
    
    
}
