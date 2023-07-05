// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title CBDCAccessControl Contract
/// @notice A contract that manages access control for the CBDC token.
contract CBDCAccessControl is AccessControl {
    // Roles for different access control functions
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ACCESS_ROLE = keccak256("ACCESS_ROLE");
    bytes32 public constant MOVER_ROLE = keccak256("MOVER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant FREEZER_ROLE = keccak256("FREEZER_ROLE");

    // Mapping to store authorized accounts
    mapping(address => bool) public authorizedAccounts;

    // Event emitted when an account is enabled
    event EnabledAccount(address member);

    // Event emitted when an account is disabled
    event DisabledAccount(address member);

    /// @dev Contract constructor.
    /// @param _authority The address with authority over the CBDC token.
    /// @param _admin The address responsible for administering access control.
    constructor(address _authority, address _admin) {
        // Set the contract admin role
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);

        // Set up the various roles with the authority address
        _setupRole(PAUSER_ROLE, _authority);
        _setupRole(MINTER_ROLE, _authority);
        _setupRole(ACCESS_ROLE, _authority);
        _setupRole(MOVER_ROLE, _authority);
        _setupRole(BURNER_ROLE, _authority);
        _setupRole(FREEZER_ROLE, _authority);
    }

    /// @dev Modifier to check if both 'from' and 'to' addresses are authorized.
    /// @param from The address of the sender.
    /// @param to The address of the receiver.
    modifier checkAccess(address from, address to) {
        require(
            authorizedAccounts[from] && authorizedAccounts[to],
            "CBDCAccessControl: accounts not authorized"
        );
        _;
    }

    /// @dev Enables an account to have access.
    /// @param member The address of the account to enable.
    function enableAccount(address member) public {
        require(
            !authorizedAccounts[member],
            "CBDCAccessControl: account already enabled"
        );
        authorizedAccounts[member] = true;
        emit EnabledAccount(member);
    }

    /// @dev Disables an account from having access.
    /// @param member The address of the account to disable.
    function disableAccount(
        address member
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            authorizedAccounts[member],
            "CBDCAccessControl: account already disabled"
        );
        authorizedAccounts[member] = false;
        emit DisabledAccount(member);
    }

    /// @dev Verifies if an account is authorized.
    /// @param account The address of the account to verify.
    /// @return A boolean indicating if the account is authorized.
    function verifyAccount(address account) public view returns (bool) {
        return authorizedAccounts[account];
    }
}
