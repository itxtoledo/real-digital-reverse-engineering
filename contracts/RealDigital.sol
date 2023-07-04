// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./CBDCAccessControl.sol";

/// @title RealDigital Contract
/// @notice An ERC20 token contract with additional features such as freezing balances and access control.
contract RealDigital is ERC20, Pausable, CBDCAccessControl {
    mapping(address => uint256) public frozenBalanceOf;  // Mapping to track frozen balances

    event FrozenBalance(address wallet, uint256 amount);  // Event emitted when a balance is frozen

    modifier checkFrozenBalance(address from, uint256 amount) {
        require(balanceOf(from) - frozenBalanceOf[from] >= amount, "RealDigital: insufficient frozen balance");
        _;
    }

    /// @dev Modifier to restrict functions to authorized participants only.
    modifier onlyParticipant() {
        require(isAuthorizedParticipant(msg.sender), "RealDigital: caller is not an authorized participant");
        _;
    }

    /// @dev Constructor that initializes the RealDigital contract.
    /// @param _name The name of the token.
    /// @param _symbol The symbol of the token.
    /// @param _authority The address of the authority role.
    /// @param _admin The address of the admin role.
    constructor(
        string memory _name,
        string memory _symbol,
        address _authority,
        address _admin
    ) ERC20(_name, _symbol) CBDCAccessControl(_authority, _admin) {}

    /// @dev Checks if an address is an authorized participant.
    /// @param participant The address to check.
    /// @return A boolean indicating if the address is an authorized participant.
    function isAuthorizedParticipant(address participant) public view returns (bool) {
        return super.verifyAccount(participant);
    }

    /// @dev Mints new tokens and adds them to the specified address.
    /// @param to The address to mint tokens to.
    /// @param amount The amount of tokens to mint.
    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, msg.sender), "RealDigital: must have minter role to mint");
        _mint(to, amount);
    }

    /// @dev Burns tokens from a specified address.
    /// @param from The address to burn tokens from.
    /// @param amount The amount of tokens to burn.
    function burnFrom(address from, uint256 amount) public {
        require(hasRole(BURNER_ROLE, msg.sender), "RealDigital: must have burner role to burn");
        _burn(from, amount);
    }

    /// @dev Hook function called before any token transfer.
    /// @param from The address transferring tokens.
    /// @param to The address receiving tokens.
    /// @param amount The amount of tokens being transferred.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override checkFrozenBalance(from, amount) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
