// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RealDigital.sol";
import "./CBDCAccessControl.sol";

/// @title RealDigitalDefaultAccount Contract
/// @notice A contract to manage default accounts for RealDigital tokens.
contract RealDigitalDefaultAccount is CBDCAccessControl {
    RealDigital public realDigital; // Reference to the RealDigital contract

    mapping(uint256 => address) public defaultAccount; // Mapping to store default accounts

    /// @dev Constructor that initializes the RealDigitalDefaultAccount contract.
    /// @param token The address of the RealDigital contract.
    /// @param _authority The address of the authority role.
    /// @param _admin The address of the admin role.
    constructor(
        RealDigital token,
        address _authority,
        address _admin
    ) CBDCAccessControl(_authority, _admin) {
        realDigital = token;
    }

    /// @dev Adds a default account for a given CNPJ8 (8-digit Brazilian company identification number).
    /// @param cnpj8 The CNPJ8 for which to set the default account.
    /// @param wallet The address of the default account.
    function addDefaultAccount(uint256 cnpj8, address wallet)
        public
        onlyRole(ACCESS_ROLE)
    {
        require(
            defaultAccount[cnpj8] == address(0),
            "RealDigitalDefaultAccount: Default account already set"
        );
        defaultAccount[cnpj8] = wallet;
    }

    /// @dev Updates the default wallet for a given CNPJ8.
    /// @param cnpj8 The CNPJ8 for which to update the default wallet.
    /// @param newWallet The new address of the default wallet.
    function updateDefaultWallet(uint256 cnpj8, address newWallet)
        public
        onlyRole(ACCESS_ROLE)
    {
        require(
            defaultAccount[cnpj8] != address(0),
            "RealDigitalDefaultAccount: Default account not set"
        );
        defaultAccount[cnpj8] = newWallet;
    }
}
