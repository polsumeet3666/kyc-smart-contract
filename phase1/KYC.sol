pragma solidity ^0.5.1;
contract kyc {

    //owner (admin) for kyc contract
    address adminAddress;
    constructor() public{
        adminAddress = msg.sender;
    }
    /* Struct customer
    uname - username of the customer
    dataHash - customer data
    rating - rating given to customer given based on regularity
    upvotes - number of upvotes recieved from banks
    bank - address of bank that validated the customer account */
    struct Customer {
        string uname;
        string dataHash;
        uint upvotes;
        address bank;
        string password;
        uint rating;
    }
    // Struct Organisation
    // name - name of the bank/organisation
    // ethAddress - ethereum address of the bank/organisation
    // rating - rating based on number of valid/invalid verified accounts
    // KYC_count - number of KYCs verified by the bank/organisation
    struct Organisation {
        string name;
        address ethAddress;
        uint KYC_count;
        string regNumber;
        bool isAllowedKyc;
        uint rating;
    }
    // Struct Organisation
    // uname - username of the customer
    // bankAddress - ethereum address of the bank/organisation
    // isAllowed - Flag determining if a bank is allowed to do the KYC
    struct Request {
        string uname;
        address bankAddress;
    }
    // list of all customers
    Customer[] public allCustomers;
    // list of all Banks/Organisations
    Organisation[] public allBanks;
    // list of all requests
    Request[] public allRequests;
    // list of all valid KYCs
    Request[] public validKYCs;
    /*** function to add request for KYC
    @param Uname Username for the customer and bankAddress
    @param bankAddress bankAddress
    Function is made payable as banks need to provide some currency to start of the KYC process */
    function addRequest(string memory Uname, address bankAddress) public payable {
        // loop to check is request is already added
        for(uint i = 0; i < allRequests.length; ++ i) {
            if(stringsEqual(allRequests[i].uname, Uname) && allRequests[i].bankAddress == bankAddress) {
                return;
            }
        }
        allRequests.length ++;
        allRequests[allRequests.length - 1] = Request(Uname, bankAddress);
    }
    /** function to remove request for KYC
    @param Uname Username for the customer
    @return 0 This function returns 0 if removal is successful else this return 1 if the Username
    for the customer is not found */
    function removeRequest(string memory Uname) public payable returns(int) {
        for(uint i = 0; i < allRequests.length; ++ i) {
            if(stringsEqual(allRequests[i].uname, Uname)) {
            for(uint j = i+1;j < allRequests.length; ++ j) {
                allRequests[i-1] = allRequests[i];
            }
            allRequests.length --;
            return 0;
            }
        }
        // throw error if uname not foundreturn 1;
    }
    /**function to add request for KYC
    @param Uname Username for the customer and bankAddress
    @param bankAddress bankaddress
    Function is made payable as banks need to provide some currency to start of the KYC process */
    function addKYC(string memory Uname, address bankAddress) public payable {
        for(uint i = 0; i < validKYCs.length; ++ i) {
            if(stringsEqual(validKYCs[i].uname, Uname) && validKYCs[i].bankAddress == bankAddress) {
                return;
            }
        }
        validKYCs.length ++;
        validKYCs[validKYCs.length - 1] = Request(Uname, bankAddress);
    }
    /** function to remove from valid KYC
    @param Uname Username for the customer
    @return - This function returns 0 if removal is successful else this return 1 if the Username for the customer is not found */
    function removeKYC(string memory Uname) public payable returns(int) {
        for(uint i = 0; i < validKYCs.length; ++ i) {
            if(stringsEqual(validKYCs[i].uname, Uname)) {
                for(uint j = i+1;j < validKYCs.length; ++ j) {
                    validKYCs[i-1] = validKYCs[i];
                }
                validKYCs.length --;
                return 0;
            }
        }
        // throw error if uname not found
        return 1;
    }
    // function to compare two string value
    // This is an internal fucntion to compare string values
    // @Params - String a and String b are passed as Parameters
    // @return - This function returns true if strings are matched and false if the strings are not matching
    function stringsEqual(string storage _a, string memory _b) internal view returns (bool) {
        bytes storage a = bytes(_a);bytes memory b = bytes(_b);
        if (a.length != b.length)
        return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
        {
            if (a[i] != b[i])
            return false;
        }
        return true;
    }
    /*** function to add a customer profile to the database
    @param Uname Username and the hash of data for the customer are passed as parameters
    @param DataHash string format for hash generated
    @return 0 if successful
    @return 1 if size limit of the database is reached
    @return 2 if customer already in network
    */
    function addCustomer(string memory Uname, string memory DataHash) public isValidBank payable returns(int) {
        // throw error if username already in use
        for(uint i = 0;i < allCustomers.length; i++) {
            if(stringsEqual(allCustomers[i].uname, Uname))
            return 2;
        }
        allCustomers.push(Customer(Uname, DataHash, 0, msg.sender,"null",0));
        return 0;
    }
    /**
    function to remove fraudulent customer profile from the database
    @param Uname - customer's username is passed as parameter
    @return 0 if successful
    @return 1 if customer profile not in database */
    function removeCustomer(string memory Uname) public isValidBank payable returns(int) {
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].uname, Uname)) {
                for(uint j = i+1;j < allCustomers.length; ++ j) {
                    allCustomers[i-1] = allCustomers[i];
                }
                allCustomers.length --;
                return 0;
            }
        }
        // throw error if uname not found
        return 1;
    }

    // function to modify a customer profile in database
    // @params - Customer username and datahash are passed as Parameters
    // returns 0 if successful
    // returns 1 if customer profile not in database
    function modifyCustomer(string memory Uname, string memory DataHash) public isValidBank payable returns(uint) {
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].uname, Uname)) {
                allCustomers[i].dataHash = DataHash;
                allCustomers[i].bank = msg.sender;
                return 0;
            }
        }
        // throw error if uname not found
        return 1;
    }
    /** function to return customer profile data
    @param Uname Customer username is passed as the Parameters
    @return 0 This function return the cutomer data if found, else this function returns an error string. */
    function viewCustomer(string memory Uname) public payable returns(string memory) {
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].uname, Uname)) {
                return allCustomers[i].dataHash;
            }
        }
        return "Customer not found in database!";
    }
    // function to modify customer rating
    // @params - Customer Username and a bool variable - true for upvote and false for down vote is passed to the function
    // @return - This function return 0 if it is successful
    function updateKYCVotes(string memory Uname, bool ifIncrease) public payable returns(uint){
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].uname, Uname)) {
                //update rating
                if(ifIncrease) {
                    allCustomers[i].upvotes ++;
                    if(allCustomers[i].upvotes > 5) {
                        addKYC(Uname, allCustomers[i].bank);
                    }
                }
                else {
                    allCustomers[i].upvotes --;
                    if(allCustomers[i].upvotes < 5) {
                        removeKYC(Uname);
                    }
                }
                return 0;
            }
        }
    }

    //modifier for isAdmin
    //to be applied to function which admin can only perform.
    modifier isAdmin() {
        require(msg.sender == adminAddress,"Error: Permission denied. Only Admin can perform these operations");
        _;
    }

    /** addBank to allBanks list
    @param _bankName - name of bank
    @param _regNumber - bank's reg number
    @param _bankAddr - bank's address
    @param _isAllowedKyc - flag if bank is allowed to do kyc
    @return 0- for error , 1- for success */
    function addBank(string memory _bankName,string memory _regNumber,address _bankAddr,bool _isAllowedKyc) public isAdmin  returns(uint){
        // check if bank is already created
        for(uint i = 0;i < allBanks.length;i++){
            if (stringsEqual(allBanks[i].name,_bankName)){
                return 0;
            }
        }
        allBanks.push(Organisation({
            name:_bankName,
            ethAddress:_bankAddr,
            KYC_count:0,
            regNumber:_regNumber,
            isAllowedKyc:_isAllowedKyc,
            rating:0
        }));
        return 1;
    }

    /**
    remove bank
    @param _bankAddr - bank address to remove
    @return 0 for error, 1 for success
     */
     function removeBank(address _bankAddr) public isAdmin returns (uint) {
         bool isPresent = false;
         uint index = 0;
         for(uint i = 0;i < allBanks.length;i++){
            if (allBanks[i].ethAddress == _bankAddr){
                isPresent = true;
                index = i;
                break;
            }
         }
         if (isPresent){
            for(uint i = index;i<allBanks.length-1;i++){
                    allBanks[i] = allBanks[i+1];
                }
            delete allBanks[allBanks.length-1];
            allBanks.length--;
            return 1;
         }
         return 0;
     }

     /**
     fetch bank's name using bank's ethaddress
     @param _bankAddr banks eth address
     @return bankName  banks name
     */
     function getBankName(address _bankAddr) public view returns(string memory) {
         for(uint i = 0;i<allBanks.length;i++){
             if (allBanks[i].ethAddress == _bankAddr){
                 return allBanks[i].name;
             }
         }
         return "0";
     }

     /**
     get bank's eth address using bank's name
     @param _bankName bank's name
     @return ethAddress of bank */
     function getBankAddress(string memory _bankName) public view returns (address){
        address result;
          for(uint i = 0;i<allBanks.length;i++){
             if (stringsEqual(allBanks[i].name,_bankName)){
                 result = allBanks[i].ethAddress;
                 break;
             }
         }
         return result;
     }

    /**
    block bank from submitting kyc data
    @param _bankAddr bank's eth address
    @return 0 for error, 1 for success */
    function blockBankFormSubmittingKyc(address _bankAddr) public isAdmin returns (uint){
        for(uint i = 0;i<allBanks.length;i++){
             if (allBanks[i].ethAddress == _bankAddr){
                 allBanks[i].isAllowedKyc = false;
                 return 1;
             }
        }
        return 0;
    }
    /**
    unblock bank from submitting kyc data
    @param _bankAddr bank's eth address
    @return 0 for error, 1 for success */
    function unblockBankFormSubmittingKyc(address _bankAddr) public isAdmin returns (uint){
        for(uint i = 0;i<allBanks.length;i++){
             if (allBanks[i].ethAddress == _bankAddr){
                 allBanks[i].isAllowedKyc = true;
                 return 1;
             }
        }
        return 0;
    }

    /* to check current address is valid bank or not */
    modifier isValidBank() {
        bool result = false;
        for(uint i = 0;i<allBanks.length;i++){
            if(allBanks[i].ethAddress == msg.sender){
                result = true;
            }
        }
        require(result == true,"Given Bank is not present in list");
        _;
    }

    /**
    function to set password for customer data
    @param _uname customer name
    @param _password customer password
    @return true if password set successful
    @return false if password set unsuccessful
    @return error if password already set*/
    function setCustomerPassword(string memory _uname,string memory _password) public returns (bool){
        bool result = false;
        for(uint i = 0;i<allCustomers.length;i++){
            if (stringsEqual(allCustomers[i].uname,_uname)){
                require(stringsEqual(allCustomers[i].password,"null"),"Error: Password already set");
                allCustomers[i].password = _password;
                result = true;
                break;
            }
        }
        if(result){
            return true;
        }
        return false;
    }

    /**
    function to add rating of costomer
    @param _uname customer name
    @return 0 if added rating successfully
    @return 1 if rating failed */
    function addRatingToCustomer(string memory _uname) public isValidBank returns (uint){
        for (uint i = 0;i<allCustomers.length;i++){
            if (stringsEqual(allCustomers[i].uname,_uname)){
                allCustomers[i].rating++;
                return 0;
            }
        }
        return 1;
    }
    /**
    function to get rating of costomer
    @param _uname customer name
    @return customer's rating
    @return 0 is no customer found */
    function getCustomersRating(string memory _uname) public view isValidBank returns (uint){
        for (uint i = 0;i<allCustomers.length;i++){
            if (stringsEqual(allCustomers[i].uname,_uname)){
                return allCustomers[i].rating;
            }
        }
        return 0;
    }
    /**
    function to add rating to bank
    @param _bankAddr banks eth address
    @return 0 if added rating successfully
    @return 1 if additioin failed */
    function addRatingToBank(address _bankAddr) public isValidBank returns (uint){
        for(uint i = 0;i<allBanks.length;i++){
            if (allBanks[i].ethAddress == _bankAddr){
                allBanks[i].rating++;
                return 0;
            }
        }
        return 1;
    }
    /**
    function to get rating to bank
    @param _bankAddr banks eth address
    @return bank's rating
    @return -1 if no bank found */
    function getBanksRating(address _bankAddr) public view isValidBank returns (uint){
        for(uint i = 0;i<allBanks.length;i++){
            if (allBanks[i].ethAddress == _bankAddr){
                return allBanks[i].rating;
            }
        }
        return 0;
    }
}