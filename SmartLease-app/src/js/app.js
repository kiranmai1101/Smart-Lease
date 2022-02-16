web3= new Web3(window.web3.currentProvider); 
var contractAddress='0x6e0e74717Bb181BCB3b32b61Eee80f3EeF8ae196';
var decentralized_address_p = document.getElementById('decentralized_address');
var abi;
var currentAccount;
//var current_account_position;

var c_abi;
var SmartLeaseContract;
var claims;


if(window.ethereum) {
    window.ethereum.on('accountsChanged', function () {
        window.location.reload();
    });
}

async function getCurrentAccount(){
    const acc = await ethereum.request({ method: 'eth_requestAccounts'});
    return acc[0];
}



$.getJSON('../SmartLeaseContract.json').then(function(data){
    c_abi = data['abi'];
    SmartLeaseContract = new web3.eth.Contract(c_abi,contractAddress);
    getCurrentAccount().then((value)=>{decentralized_address_p.innerHTML+=value; currentAccount = value;});
});


function adminFunction(){ 
    adminDiv.style.display = "block";
    landlordDiv.style.display = "none";
    tenantDiv.style.display = "none";
}

function landlordFunction(){
    adminDiv.style.display = "none";
    landlordDiv.style.display = "block";
    tenantDiv.style.display = "none";  
}

function registerFunction(){
    adminDiv.style.display = "none";
    landlordDiv.style.display = "none";
    tenantDiv.style.display = "block";
}


function register(InputAddress){
    console.log("Registering Landlords");
    var success=1;
    var tmp = async function(){ 
        try{
            return await SmartLeaseContract.methods.addLandlord(InputAddress).send({from:currentAccount});
        } 
        catch(e){
            success=0;
            alert("Transaction failed");
        }
    }
    tmp().then((val)=>{
        //console.log(val);
        if(success==1){
            alert("Success");
        }
    }); 
}

function propose_lease(Inputhash){
    console.log("Proposing Lease Agreement");
    var success=1;
    var tmp = async function(){ 
        try{
            return await SmartLeaseContract.methods.proposeLeaseAgreement(Inputhash).send({from:currentAccount});
        } 
        catch(e){
            success=0;
            alert("Transaction failed");
        }
    }
    tmp().then((val)=>{
        //console.log(val);
        if(success==1){
            alert("Success");
            hash_flag = 1;
        }
    }); 
}


async function registerTenants(){
    var tenant_address = document.getElementById("tenant_addr").value;
    var house_address = document.getElementById("house_addr").value;
    var rent_amount = parseInt(document.getElementById("rent_amount").value)+'00';
    var deposit_amount = parseInt(document.getElementById("deposit_amount").value)+'00';
    var late_rent_fee = parseInt(document.getElementById("late_rent_fee").value)+'00';
    console.log("Registering Tenants");
    var success=1;
    var tmp = async function(){ 
        try{
            return await SmartLeaseContract.methods.registerTenant(tenant_address, house_address, rent_amount, deposit_amount, late_rent_fee).send({from:currentAccount});
        } 
        catch(e){
            success=0;
            alert("Transaction failed");
        }
    }
    tmp().then((val)=>{
        //console.log(val);
        if(success==1){
            alert("Success");
        }
    }); 
}

function settleTenant(Inputaddress){
    console.log("Settle Tenant");
    var success=1;
    var tmp = async function(){ 
        try{
            return await SmartLeaseContract.methods.settleTenant(Inputaddress).send({from:currentAccount});
        } 
        catch(e){
            success=0;
            alert("Transaction failed");
        }
    }
    tmp().then((val)=>{
        //console.log(val);
        if(success==1){
            alert("Success");
        }
    }); 
}

function displayHash(){
    console.log("Displaying Hash Value");
    var success=1;
    var tmp = async function(){ 
        try{
            var p = await SmartLeaseContract.methods.displayhashvalue().call({from:currentAccount});
            document.getElementById('display_hash').innerHTML += p;
        } 
        catch(e){
            success=0;
            alert("Transaction failed");
        }
    }
    tmp().then((val)=>{
        //console.log(val);
        if(success==1){
            alert("Success");
        }
    }); 
}

function displayHouseDetails(){
    console.log("Displaying House Details");
    var success=1;
    var tmp = async function(){ 
        try{
            var p = await SmartLeaseContract.methods.displayHouseDetails(currentAccount).call({from:currentAccount});
            var c = document.getElementById('house')
            c.innerHTML= p[1];
            var c1 = document.getElementById('rent_amt')
            c1.innerHTML= p[2]/100;
            var c2 = document.getElementById('deposit_amt')
            c2.innerHTML= p[3]/100;
            var c3 = document.getElementById('late_fee')
            c3.innerHTML= p[4]/100;
            var c4 = document.getElementById('signed_lease')
            c4.innerHTML= p[7];
        } 
        catch(e){
             success=0;
             alert("Transaction failed");
         }
    }
    tmp().then((val)=>{
        if(success==1){
            alert("Success");
        }
    }); 
}

function signContract(){
    console.log("Tenant signing contract");
    var success=1;
    var tmp = async function(){ 
        try{
            return await SmartLeaseContract.methods.signContract().send({from:currentAccount});
        } 
        catch(e){
            success=0;
            alert("Transaction failed");
        }
    }
    tmp().then((val)=>{
        //console.log(val);
        if(success==1){
            alert("Success");
        }
    }); 
}

function payDeposit(Inputamount){
    console.log("Tenant paying deposit");
    var success=1;
    var tmp = async function(){ 
        try{
            return await SmartLeaseContract.methods.payDeposit(Inputamount).send({from:currentAccount});
        } 
        catch(e){
            success=0;
            alert("Transaction failed");
        }
    }
    tmp().then((val)=>{
        //console.log(val);
        if(success==1){
            alert("Success");
        }
    }); 
}

function checkLatePayment(){
    console.log("Tenant checking late fee payment");
    var success=1;
    var tmp = async function(){ 
        try{
            return await SmartLeaseContract.methods.CheckLatePayment().send({from:currentAccount});
        } 
        catch(e){
            success=0;
            alert("Transaction failed");
        }
    }
    tmp().then((val)=>{
        //console.log(val);
        if(success==1){
            alert("Success");
        }
    }); 
}

function payRent(Inputamount){
    console.log("Tenant paying rent");
    var success=1;
    var tmp = async function(){ 
        try{
            return await SmartLeaseContract.methods.payRent(Inputamount).send({from:currentAccount});
        } 
        catch(e){
            success=0;
            alert("Transaction failed");
        }
    }
    tmp().then((val)=>{
        //console.log(val);
        if(success==1){
            alert("Success");
        }
    }); 
}


