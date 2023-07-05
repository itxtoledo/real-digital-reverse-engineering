// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./CBDCAccessControl.sol";

/// @title RealDigital Contract
/// @notice An ERC20 token contract with additional features such as freezing balances, access control, and pausable functionality.
contract RealDigital is ERC20Burnable, Pausable, CBDCAccessControl {
    mapping(address => uint256) public frozenBalanceOf; // Mapping to track frozen balances

    event FrozenBalance(address wallet, uint256 amount); // Event emitted when a balance is frozen

    modifier checkFrozenBalance(address from, uint256 amount) {
        require(
            balanceOf(from) - frozenBalanceOf[from] >= amount,
            "RealDigital: insufficient frozen balance"
        );
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
    function isAuthorizedParticipant(
        address participant
    ) public view returns (bool) {
        return super.verifyAccount(participant);
    }

    /// @dev Mints new tokens and adds them to the specified address.
    /// @param to The address to mint tokens to.
    /// @param amount The amount of tokens to mint.
    function mint(
        address to,
        uint256 amount
    ) public whenNotPaused onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @dev Burns tokens from sender address.
    /// @param amount The amount of tokens to burn.
    function burn(uint256 amount) public override whenNotPaused {
        super.burn(amount);
    }

    function move(
        address from,
        address to,
        uint256 amount
    ) public onlyRole(MOVER_ROLE) {
        _transfer(from, to, amount);
    }

    /// @dev Burns tokens from a specified address.
    /// @param from The address to burn tokens from.
    /// @param amount The amount of tokens to burn.
    function moveAndBurn(
        address from,
        uint256 amount
    ) public whenNotPaused onlyRole(MOVER_ROLE) {
        _burn(from, amount);
    }

    /// @dev Burns tokens from a specified address.
    /// @param from The address to burn tokens from.
    /// @param amount The amount of tokens to burn.
    function burnFrom(
        address from,
        uint256 amount
    ) public override whenNotPaused {
        super.burnFrom(from, amount);
    }

    /// @dev Hook function called before any token transfer.
    /// @param from The address transferring tokens.
    /// @param to The address receiving tokens.
    /// @param amount The amount of tokens being transferred.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override checkFrozenBalance(from, amount) whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    /// @dev Pauses all token transfers.
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @dev Unpauses token transfers.
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function increaseFrozenBalance(
        address from,
        uint256 amount
    ) public onlyRole(FREEZER_ROLE) {
        frozenBalanceOf[from] += amount;
        emit FrozenBalance(from, amount);
    }

    function decreaseFrozenBalance(
        address from,
        uint256 amount
    ) public onlyRole(FREEZER_ROLE) {
        require(
            frozenBalanceOf[from] >= amount,
            "RealDigital: insufficient frozen balance"
        );
        frozenBalanceOf[from] -= amount;
    }
}
