// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RealDigital.sol";

/// @title RealTokenizado Contract
/// @notice A contract that extends the functionality of RealDigital token and adds additional properties.
contract RealTokenizado is RealDigital {
    string public participant;  // Participant name associated with the token
    uint256 public cnpj8;  // 8-digit CNPJ (Cadastro Nacional da Pessoa Jurídica) associated with the token
    address public reserve;  // Address of the reserve associated with the token

    /// @dev Constructor that initializes the RealTokenizado contract.
    /// @param _name The name of the token.
    /// @param _symbol The symbol of the token.
    /// @param _authority The address of the authority for access control.
    /// @param _admin The address of the contract admin for access control.
    /// @param _participant The participant name associated with the token.
    /// @param _cnpj8 The 8-digit CNPJ associated with the token.
    /// @param _reserve The address of the reserve associated with the token.
    constructor(
        string memory _name,
        string memory _symbol,
        address _authority,
        address _admin,
        string memory _participant,
        uint256 _cnpj8,
        address _reserve
    ) RealDigital(_name, _symbol, _authority, _admin) {
        participant = _participant;
        cnpj8 = _cnpj8;
        reserve = _reserve;
    }

    /// @dev Updates the address of the reserve associated with the token.
    /// @param newReserve The new address of the reserve.
    function updateReserve(address newReserve) public onlyRole(DEFAULT_ADMIN_ROLE) {
        reserve = newReserve;
    }
}
