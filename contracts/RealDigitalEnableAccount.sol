// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CBDCAccessControl.sol";

/// @title RealDigitalEnableAccount Contract
/// @notice A contract to enable or disable accounts using CBDCAccessControl contract.
contract RealDigitalEnableAccount {
    address public accessControlAddress;  // Address of the CBDCAccessControl contract
    CBDCAccessControl private accessControl;  // Instance of the CBDCAccessControl contract

    /// @dev Constructor that initializes the RealDigitalEnableAccount contract.
    /// @param _accessControlAddress The address of the CBDCAccessControl contract.
    constructor(address _accessControlAddress) {
        accessControlAddress = _accessControlAddress;
        accessControl = CBDCAccessControl(_accessControlAddress);
    }

    /// @dev Enables an account by invoking the enableAccount function of CBDCAccessControl contract.
    /// @param member The address of the account to enable.
    function enableAccount(address member) public {
        accessControl.enableAccount(member);
    }

    /// @dev Disables the account of the sender by invoking the disableAccount function of CBDCAccessControl contract.
    function disableAccount() public {
        accessControl.disableAccount(msg.sender);
    }
}
