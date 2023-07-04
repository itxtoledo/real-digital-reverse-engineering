// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title AddressDiscovery Contract
/// @notice A contract that allows updating and discovering addresses for smart contracts.
contract AddressDiscovery is AccessControl {
    // Role for accessing the updateAddress function
    bytes32 public constant ACCESS_ROLE = keccak256("ACCESS_ROLE");

    // Mapping to store the discovered addresses
    mapping(bytes32 => address) public addressDiscovery;

    /// @dev Contract constructor.
    /// @param _admin The address of the contract admin.
    constructor(address _admin) {
        // Set the contract admin role
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        // Set the role admin for ACCESS_ROLE as the default admin role
        _setRoleAdmin(ACCESS_ROLE, DEFAULT_ADMIN_ROLE);
    }

    /// @dev Updates the address for a specific smart contract.
    /// @param smartContract The identifier for the smart contract.
    /// @param newAddress The new address to be associated with the smart contract.
    /// @dev This function can only be called by an address with the ACCESS_ROLE.
    function updateAddress(bytes32 smartContract, address newAddress) public onlyRole(ACCESS_ROLE) {
        // Update the address for the smart contract
        addressDiscovery[smartContract] = newAddress;
    }
}
