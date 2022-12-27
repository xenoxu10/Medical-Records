//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
import "./shared.sol";
contract RegulatorAgency{
    address  manager;
    mapping (uint => Shared.Patient)  patients;
    mapping (uint => Shared.Doctor)   doctors;
   
    mapping(address => uint)  docId;
   
    mapping(address=>uint)  PatientId;



    constructor(){
        manager=msg.sender;
    }
     
    function show_Manager() public view returns(address)
    {
        return manager;
    }
     modifier notOwner{
        require(msg.sender != manager, "Manager cannot call this function");
        _;
    }
    
    modifier onlyNotRegistered {
        require(!patients[PatientId[msg.sender]].registered, "Unregistered account required");
        require(!doctors[docId[msg.sender]].registered, "Unregistered account required");
       
        _;
    }
  




    //ID Generators
     function generate_doctorId() public   onlyNotRegistered returns(uint)
    {
         docId[msg.sender]=uint(keccak256(abi.encodePacked(msg.sender, block.timestamp)))%10**6;
        return docId[msg.sender];
    }    
  
      function generate_PatientId() public onlyNotRegistered returns(uint256) {
        PatientId[msg.sender]=uint(keccak256(abi.encodePacked(msg.sender, block.timestamp)))%10**6;
        return PatientId[msg.sender];
    }









    //Patient functions
     function addPatient() public onlyNotRegistered notOwner {
        require(PatientId[msg.sender]!=0,"generate Patient id");
        patients[PatientId[msg.sender]].registered = true;
    }
      function isPatientRegistered(address _addr) view public  returns (bool) {
        return patients[PatientId[_addr]].registered;
    }

    function returnPatientId(address Patient_Address) public view returns(uint)
    {
        return PatientId[Patient_Address];
    }
   








    // Doctor Functions
    function addDoctor() public onlyNotRegistered notOwner {
        require(docId[msg.sender]!=0,"generate doctor id");
        doctors[docId[msg.sender]].registered = true;
    }
    
    function isDoctorRegistered(address _addr) view public  returns (bool) {
        return doctors[docId[_addr]].registered;
    }
    function returnDoctorId(address Doctor_Address) public view returns(uint)
    {
        return docId[Doctor_Address];
    }
      function submitDoctorToken( bytes32 _tokenID, address _oracleAddress,uint _docId) public onlyNotRegistered {
       doctors[_docId].tokenIDs.push(_tokenID);
       doctors[_docId].tokens[_tokenID] = Shared.DoctorToken(true, _oracleAddress);
        
    }
    
    
    
    
    
    
    
    
    
    
   
    

}    









