pragma solidity ^0.5.0;


contract MultiSigWallet {

    address private _owner;
    mapping(address => bool) private _owners;

    uint constant MIN_SIGNATURES = 2;
    uint public _transactionIdx;

    struct Transaction {
      address from;
      address payable to;
      uint amount;
      uint8 signatureCount; 
      mapping (address => uint8) signatures;
    }

    mapping (uint => Transaction) private _transactions;
    uint[] private _pendingTransactions;

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier validOwner() {
        require(msg.sender == _owner || _owners[msg.sender] == true);
        _;
    }

    event DepositFunds(address from, uint amount);
    event TransactionCreated(address from, address to, uint amount, uint transactionId);
    event TransactionCompleted(address from, address to, uint amount, uint transactionId);
    event TransactionSigned(address by, uint transactionId);

    constructor()
        public {
        _owner = msg.sender;
    }

    function addOwner(address owner)
        isOwner validOwner
        public {
        _owners[owner] = true;
    }

    function removeOwner(address owner)
        isOwner
        public {
        _owners[owner] = false;
    }

    function ()
        external
        payable {
        emit DepositFunds(msg.sender, msg.value);
    }

    function withdraw(address payable _to, uint amount)
        public {
        transferTo(_to, amount);
    }
    
    function transferTo(address payable to, uint amount) internal
        validOwner
         {
        require(address(0) != to);     
        require(address(this).balance >= amount);
        uint transactionId = _transactionIdx++;

        Transaction memory transaction;
        transaction.from = msg.sender;
        transaction.to = to;
        transaction.amount = amount;
        transaction.signatureCount = 0;

        _transactions[transactionId] = transaction;
        _pendingTransactions.push(transactionId);

        emit  TransactionCreated(msg.sender, to, amount, transactionId);
    }

    function getPendingTransactions()
      view
      validOwner
      public
      returns (uint[] memory) {
      return _pendingTransactions;
    }
    
    /**
     * @dev SsignTransaction.
     *Подписать транзакцию
     * 
     * - `transactionId` id Transaction.
     */
    
   function signTransaction (uint transactionId) public {
       _signTransaction(transactionId);
   }
   // sign Transaction - подписывает транзакцию
    function _signTransaction( uint transactionId) internal validOwner{
       // получаем в transaction массив с определённым индексом(transactionId)
       // we receive in transaction an array with a certain index (transactionId)
       Transaction storage transaction= _transactions[transactionId];

      // Transaction must exist
      require(address(0) != transaction.from);
      
      // Создатель не может подписать транзакцию
      // Creator cannot sign the transaction
      require(msg.sender != transaction.from);
      // Не могу подписать транзакцию более одного раза
      // Cannot sign a transaction more than once
      require(transaction.signatures[msg.sender] != 1);

      transaction.signatures[msg.sender] = 1;
      transaction.signatureCount++;

      emit  TransactionSigned(msg.sender, transactionId);

      if (transaction.signatureCount >= MIN_SIGNATURES) {
        require(address(this).balance >= transaction.amount);
        address(transaction.to).transfer(transaction.amount);
        emit TransactionCompleted(transaction.from, transaction.to, transaction.amount, transactionId);
        deleteTransaction(transactionId);
      }
    }

    function deleteTransaction(uint transactionId)
      validOwner
      public {
      uint8 replace = 0;
      for(uint i = 0; i < _pendingTransactions.length; i++) {
        if (1 == replace) {
          _pendingTransactions[i-1] = _pendingTransactions[i];
        } else if (transactionId == _pendingTransactions[i]) {
          replace = 1;
        }
      }
      delete _pendingTransactions[_pendingTransactions.length - 1];
      _pendingTransactions.length--;
      delete _transactions[transactionId];
    }

    function walletBalance() public view
     returns (uint) {
      return address(this).balance;
    }
}
