// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RealDigital.sol";

/// @title STR Contract
/// @notice A contract that facilitates minting and burning of tokens by authorized participants.
contract STR {
    RealDigital public realDigital;  // Instance of the RealDigital token contract

    /// @dev Modifier to restrict access to only authorized participants.
    modifier onlyParticipant() {
        require(realDigital.isAuthorizedParticipant(msg.sender), "STR: caller is not an authorized participant");
        _;
    }

    /// @dev Constructor that sets the instance of the RealDigital token contract.
    /// @param _realDigital The address of the RealDigital token contract.
    constructor(RealDigital _realDigital) {
        realDigital = _realDigital;
    }

    /// @dev Requests to mint a specified amount of tokens.
    /// @param amount The amount of tokens to be minted.
    function requestToMint(uint256 amount) public onlyParticipant {
        realDigital.mint(msg.sender, amount);
    }

    /// @dev Requests to burn a specified amount of tokens.
    /// @param amount The amount of tokens to be burned.
    function requestToBurn(uint256 amount) public onlyParticipant {
        realDigital.burnFrom(msg.sender, amount);
    }
}
