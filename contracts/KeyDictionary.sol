// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RealDigital.sol";

/// @title KeyDictionary Contract
/// @notice A contract that manages customer data and key mapping for participants in a digital system.
contract KeyDictionary {
    struct CustomerData {
        uint256 taxId;      // The customer's CPF (tax identification number)
        uint256 bankNumber; // The participant's code
        uint256 account;    // The customer's account number
        uint256 branch;     // The customer's branch number
        address wallet;     // The customer's wallet address
        bool registered;    // Indicates whether the customer is registered or not
        address owner;      // The wallet address of the participant who added the customer
    }

    event KeyRequested(address owner, uint256 proposalId, bytes32 key);

    modifier onlyParticipant() {
        require(isParticipant(msg.sender), "KeyDictionary: caller is not a participant");
        _;
    }

    mapping(bytes32 => CustomerData) public customerData;  // Mapping to store customer data using key
    mapping(address => bytes32) public walletToKey;       // Mapping to map wallet address to key
    mapping(bytes32 => address) public keyToWallet;       // Mapping to map key to wallet address
    uint256 public proposalIdCounter;                     // Counter for proposal IDs

    RealDigital public cbdc;  // Instance of the RealDigital contract

    constructor(RealDigital token) {
        cbdc = token;
    }

    /// @dev Checks if an account is a participant.
    /// @param account The address to check.
    /// @return A boolean indicating if the account is a participant.
    function isParticipant(address account) public view returns (bool) {
        return cbdc.isAuthorizedParticipant(account);
    }

    /// @dev Adds a new customer account.
    /// @param key The unique key for the customer.
    /// @param _taxId The CPF (tax identification number) of the customer.
    /// @param _bankNumber The participant's code.
    /// @param _account The account number of the customer.
    /// @param _branch The branch number of the customer.
    /// @param _wallet The wallet address of the customer.
    function addAccount(
        bytes32 key,
        uint256 _taxId,
        uint256 _bankNumber,
        uint256 _account,
        uint256 _branch,
        address _wallet
    ) public onlyParticipant {
        require(keyToWallet[key] == address(0), "KeyDictionary: key already exists");
        require(walletToKey[_wallet] == bytes32(0), "KeyDictionary: wallet already registered");

        customerData[key] = CustomerData({
            taxId: _taxId,
            bankNumber: _bankNumber,
            account: _account,
            branch: _branch,
            wallet: _wallet,
            registered: true,
            owner: msg.sender
        });

        walletToKey[_wallet] = key;
        keyToWallet[key] = _wallet;
    }

    /// @dev Gets the wallet address associated with a key.
    /// @param key The key to retrieve the wallet address for.
    /// @return The wallet address associated with the key.
    function getWallet(bytes32 key) public view returns (address) {
        return keyToWallet[key];
    }

    /// @dev Gets the key associated with a wallet address.
    /// @param wallet The wallet address to retrieve the key for.
    /// @return The key associated with the wallet address.
    function getKey(address wallet) public view returns (bytes32) {
        return walletToKey[wallet];
    }

    /// @dev Gets the customer data associated with a key.
    /// @param key The key to retrieve the customer data for.
    /// @return The customer data associated with the key.
    function getCustomerData(bytes32 key) public view returns (CustomerData memory) {
        return customerData[key];
    }

    /// @dev Updates the customer data associated with a key.
    /// @param key The key to update the customer data for.
    /// @param _taxId The new CPF (tax identification number) of the customer.
    /// @param _bankNumber The new participant's code.
    /// @param _account The new account number of the customer.
    /// @param _branch The new branch number of the customer.
    /// @param _wallet The new wallet address of the customer.
    function updateData(
        bytes32 key,
        uint256 _taxId,
        uint256 _bankNumber,
        uint256 _account,
        uint256 _branch,
        address _wallet
    ) public {
        require(keyToWallet[key] != address(0), "KeyDictionary: key does not exist");
        require(customerData[key].owner == msg.sender, "KeyDictionary: only the owner can update data");

        CustomerData storage data = customerData[key];
        data.taxId = _taxId;
        data.bankNumber = _bankNumber;
        data.account = _account;
        data.branch = _branch;
        data.wallet = _wallet;
    }

    /// @dev Requests a new key for a customer account.
    /// @param key The key for the new customer account.
    /// @param _taxId The CPF (tax identification number) of the customer.
    /// @param _bankNumber The participant's code.
    /// @param _account The account number of the customer.
    /// @param _branch The branch number of the customer.
    /// @param _wallet The wallet address of the customer.
    function requestKey(
        bytes32 key,
        uint256 _taxId,
        uint256 _bankNumber,
        uint256 _account,
        uint256 _branch,
        address _wallet
    ) public onlyParticipant {
        require(keyToWallet[key] == address(0), "KeyDictionary: key already exists");

        emit KeyRequested(msg.sender, proposalIdCounter, key);
        proposalIdCounter++;

        customerData[key] = CustomerData({
            taxId: _taxId,
            bankNumber: _bankNumber,
            account: _account,
            branch: _branch,
            wallet: _wallet,
            registered: false,
            owner: msg.sender
        });
    }

    /// @dev Authorizes a requested key.
    /// @param proposalId The ID of the key request proposal.
    /// @param key The key to authorize.
    function authorizeKey(uint256 proposalId, bytes32 key) public {
        require(proposalId < proposalIdCounter, "KeyDictionary: invalid proposalId");
        require(keyToWallet[key] == address(0), "KeyDictionary: key already exists");

        CustomerData storage data = customerData[key];
        require(data.registered == false, "KeyDictionary: key already registered");

        data.registered = true;
        data.owner = msg.sender;
        walletToKey[data.wallet] = key;
        keyToWallet[key] = data.wallet;
    }
}
