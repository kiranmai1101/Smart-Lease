// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract SmartLeaseContract is ERC20 {

    event WrittenContractProposed(uint timestamp, string ipfsHash);
    event TenantAssigned(uint timestamp, address tenantAddress, uint rentAmount, uint depositAmount);
    event TenantSigned(uint timestamp, address tenantAddress);
    event DepositPayed(uint timestamp, address tenantAddress, uint amount);
    event RentPayed(uint timestamp, address tenantAddress, uint amount);

    struct Tenant_Details {
        address owner;
        string house_address;
        uint rentAmount;
        uint depositAmount;
        uint lateRentFee;
        uint lastBillPaymentDate;
        uint nextBillingDate;
        bool hasSignedLease;
        bool hasPaidDeposit;
        bool latePayment;
        bool registered;
        bool latePaymentChecked;
    }
    mapping(address => Tenant_Details) public addressToTenant;
        Tenant_Details[] public tenants;
	mapping (address => bool) public Landlords;
    address public landlordAddress;
    address public deployer;
    string public LeaseAgreementIpfsHash;
    uint8 public tenantOccupancy = 0;
    
	constructor() ERC20("RentIT", "RIT") {
        deployer = msg.sender;
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }
    function decimals() public view virtual override returns (uint8) {
        return 2;
    }
    modifier onlyAdmin() {
        require(msg.sender == deployer, "Only admin can call this function.");
        _;
    }
    modifier onlyTenant() {
        require(addressToTenant[msg.sender].registered == true, "Only a tenant can invoke this functionality");
        _;
    }
    modifier onlyLandlord() {
        require(Landlords[msg.sender] == true, "Only the landlord can invoke this functionality");
        _;
    }
    modifier isContractProposed() {
        require(!(isSameString(LeaseAgreementIpfsHash, "")), "The written contract has not been proposed yet");
        _;
    }
    // Checks whether tenant is making late rent payment or not
    modifier ChLatePayment() {
        require(addressToTenant[msg.sender].latePaymentChecked == true,"Use CheckLatePayment function to verify its not a late payment");
        _;
    }
    modifier hasSigned() {
        require(addressToTenant[msg.sender].hasSignedLease == true, "Tenant must sign the contract before invoking this functionality");
        _;
    }
    
     modifier notZeroAddres(address addr){
        require(addr != address(0), "0th address is not allowed!");
        _;
    }
    //Adding new landlord in RentIT
	function addLandlord(address _landlord) public onlyAdmin { 
	    Landlords[_landlord] = true;
        _mint(_landlord, 100000);
	}
	
	//Proposing Lease Agreement using IPFS hash
    function proposeLeaseAgreement(string calldata _LeaseAgreementIpfsHash) external onlyLandlord {
        LeaseAgreementIpfsHash = _LeaseAgreementIpfsHash;
        emit WrittenContractProposed(block.timestamp, _LeaseAgreementIpfsHash);
    }
    
    function displayhashvalue() public view returns (string memory){
        return LeaseAgreementIpfsHash;
    }

    function displayHouseDetails(address tenant_addr) public view returns (Tenant_Details memory){
        return addressToTenant[tenant_addr];
    }


    //Registering tenant in RentIT along with house address and rent details
    function registerTenant(address _tenantAddress, string calldata house_address, uint _rentAmount, uint _depositAmount, uint lateRentFee) 
    external onlyLandlord isContractProposed notZeroAddres(_tenantAddress){
        require(Landlords[_tenantAddress] != true, "Landlord is not allowed to be a tenant at the same time.");
        require(addressToTenant[_tenantAddress].registered == false, "Duplicate tenants are not allowed.");
        //setting the initial dates to 1970/01/01 (initialization)
        tenants.push(Tenant_Details(msg.sender, house_address, _rentAmount, _depositAmount, lateRentFee,2440588, 2440588,false, false, false, true,false));
        addressToTenant[_tenantAddress] = tenants[tenantOccupancy];
        tenantOccupancy++; 
        _mint(_tenantAddress, 100000);
        emit TenantAssigned(block.timestamp, _tenantAddress, _rentAmount, _depositAmount);
    }
    
    //Tenant signing the lease contract 
    function signContract() external onlyTenant isContractProposed
     {
        require(addressToTenant[msg.sender].hasSignedLease == false, "The tenant has already signed the contract");
        addressToTenant[msg.sender].hasSignedLease = true;
        emit TenantSigned(block.timestamp, msg.sender);
    }
    
    //Tenant pays the deposit amount corresponding to the rental house
    function payDeposit(uint _Amount) external payable onlyTenant hasSigned {
        require(_Amount == addressToTenant[msg.sender].depositAmount,"Amount of provided deposit does not match the amount of required deposit");
        require(addressToTenant[msg.sender].hasPaidDeposit == false, "The tenant has already paid the deposit");

        addressToTenant[msg.sender].hasPaidDeposit = true;
        landlordAddress = addressToTenant[msg.sender].owner;
        _transfer(msg.sender,landlordAddress,_Amount);
        
        emit DepositPayed(block.timestamp, msg.sender, _Amount);
    }
    
    //Tenant pays montly rent
    function payRent( uint _Amount) external payable onlyTenant hasSigned ChLatePayment{
        
        require(_Amount == addressToTenant[msg.sender].rentAmount,"Amount of provided rent does not match the amount of required Rent");
        
        landlordAddress = addressToTenant[msg.sender].owner;
        _transfer(msg.sender,landlordAddress,_Amount);
        
        //If tenant is making rent payement corresponding late fee will be deducted from his deposit amount
        if (addressToTenant[msg.sender].latePayment == true)
        {
            //_transfer(msg.sender,landlordAddress,addressToTenant[msg.sender].lateRentFee);
            addressToTenant[msg.sender].depositAmount -= addressToTenant[msg.sender].lateRentFee; //Deduct the late payement fee from deposit amount
            addressToTenant[msg.sender].latePayment = false; //reset the late payment flag
        }
        
        //For first rent payment set the next billing date to 30 days later to current date
        if (addressToTenant[msg.sender].lastBillPaymentDate == 2440588)
        {
            addressToTenant[msg.sender].nextBillingDate = block.timestamp + 30 days;
        }
        else //for usual montly rent payments set the nextBillingDate to 30 days later of current NextBillingDate
        {
            addressToTenant[msg.sender].nextBillingDate = addressToTenant[msg.sender].nextBillingDate + 30 days;
        }
        
        addressToTenant[msg.sender].lastBillPaymentDate = block.timestamp; //Set lastBillPayment date to current
        addressToTenant[msg.sender].latePaymentChecked = false;//Reset latePaymentChecked flag
        
        emit RentPayed(block.timestamp, msg.sender, msg.value);
    }
    
    //Check if tenant is making late rent payment
    function CheckLatePayment( ) external onlyTenant hasSigned 
    {
     //check is not for first rent payment and nextbilling date of the tenant is passed i.e., its a late rent latePayment
     //latePayement flag is set to true in this case
     if (addressToTenant[msg.sender].nextBillingDate!= 2440588 && block.timestamp>addressToTenant[msg.sender].nextBillingDate)
     {
        addressToTenant[msg.sender].latePayment = true;
     }
     addressToTenant[msg.sender].latePaymentChecked = true;
    }
    
    //Owner can settle the tenant by paying the deposit amount back and unregistering the tenant
    function settleTenant (address _tenantAddress) external onlyLandlord 
    {
        require(addressToTenant[_tenantAddress].registered == true,'Tenant must be registered to make final settlement');
        _transfer(msg.sender,_tenantAddress,addressToTenant[_tenantAddress].depositAmount);
        addressToTenant[_tenantAddress].registered = false; 
    }
    
    function isSameString(string memory string1, string memory string2) private pure returns (bool) 
    {
        return keccak256(abi.encodePacked(string1)) == keccak256(abi.encodePacked(string2));
    }
}
