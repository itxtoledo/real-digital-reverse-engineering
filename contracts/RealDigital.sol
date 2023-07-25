// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./CBDCAccessControl.sol";

/// @title RealDigital Contract
/// @notice An ERC20 token contract with additional features such as freezing balances, access control, and pausable functionality.
contract RealDigital is ERC20Burnable, Pausable, CBDCAccessControl {
    mapping(address => uint256) public frozenBalanceOf; // Mapping to track frozen balances

    event FrozenBalance(address indexed wallet, uint256 amount); // Event emitted when a balance is frozen

    modifier checkFrozenBalance(address from, uint256 amount) {
        require(
            frozenBalanceOf[from] > 0
                ? balanceOf(from) - frozenBalanceOf[from] >= amount
                : true,
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

    /// @dev Pauses all token transfers.
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @dev Unpauses token transfers.
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @dev Mints new tokens and adds them to the specified address.
    /// @param to The address to mint tokens to.
    /// @param amount The amount of tokens to mint.
    function mint(address to, uint256 amount)
        public
        whenNotPaused
        onlyRole(MINTER_ROLE)
    {
        require(verifyAccount(to), "RealDigital: not permited to receive");
        _mint(to, amount);
    }

    /// @dev Hook function called before any token transfer.
    /// @param from The address transferring tokens.
    /// @param to The address receiving tokens.
    /// @param amount The amount of tokens being transferred.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        virtual
        override
        whenNotPaused
        checkFrozenBalance(from, amount)
        checkAccess(from, to)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    /// @dev Retrieves the number of decimal places for the token.
    /// @return The number of decimal places as a uint8.
    function decimals() public pure override returns (uint8) {
        return 2; // Modify this value according to the decimal places needed for your token
    }

    /// @dev Transfers tokens from one address to another.
    /// @param from The address to transfer tokens from.
    /// @param to The address to transfer tokens to.
    /// @param amount The amount of tokens to transfer.
    function move(
        address from,
        address to,
        uint256 amount
    ) public onlyRole(MOVER_ROLE) {
        _transfer(from, to, amount);
    }

    /// @dev Increases the frozen balance of an address.
    /// @param from The address to increase the frozen balance for.
    /// @param amount The amount of tokens to increase the frozen balance by.
    function increaseFrozenBalance(address from, uint256 amount)
        public
        onlyRole(FREEZER_ROLE)
    {
        frozenBalanceOf[from] += amount;
        emit FrozenBalance(from, amount);
    }

    /// @dev Decreases the frozen balance of an address.
    /// @param from The address to decrease the frozen balance for.
    /// @param amount The amount of tokens to decrease the frozen balance by.
    function decreaseFrozenBalance(address from, uint256 amount)
        public
        onlyRole(FREEZER_ROLE)
    {
        require(
            frozenBalanceOf[from] >= amount,
            "RealDigital: insufficient frozen balance"
        );
        frozenBalanceOf[from] -= amount;
    }

    /// @dev Burns tokens from the sender's address.
    /// @param amount The amount of tokens to burn.
    function burn(uint256 amount) public override whenNotPaused {
        _burn(_msgSender(), amount);
    }

    /// @dev Transfers tokens from a specified address and burns them.
    /// @param from The address to transfer tokens from.
    /// @param amount The amount of tokens to transfer and burn.
    function moveAndBurn(address from, uint256 amount)
        public
        whenNotPaused
        onlyRole(MOVER_ROLE)
    {
        _transfer(from, address(this), amount);
        _burn(address(this), amount);
    }

    /// @dev Burns tokens from a specified address.
    /// @param from The address to burn tokens from.
    /// @param amount The amount of tokens to burn.
    function burnFrom(address from, uint256 amount)
        public
        override
        whenNotPaused
    {
        super.burnFrom(from, amount);
    }

    /// @dev Checks if an address is an authorized participant.
    /// @param participant The address to check.
    /// @return A boolean indicating if the address is an authorized participant.
    function isAuthorizedParticipant(address participant)
        public
        view
        returns (bool)
    {
        return super.verifyAccount(participant);
    }
}
