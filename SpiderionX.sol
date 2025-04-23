// SPDX-License-Identifier: MIT
// Copyright (c) 2025 SpiderionUSD
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SpiderionUSD is ERC20, ERC20Burnable, ReentrancyGuard {
    uint256 private constant INITIAL_SUPPLY = 14_000_000_000 * 10 ** 18;
    uint256 private constant BURN_RATE = 2; // 2% burn rate

    // Metadata URI stored on Arweave; auto-generated public getter
    string public constant metadataURI =
        "https://w6af5kmhw2ogsasthbnio2bf2jybamw7a6e3dc6biqmx7jnego7a.arweave.net/t4BeqYe2nGkCUzhah2gl0nAQMt8HibGLwUQZf6WkM74";

    // Emitted when tokens are burned during transfers
    event TokensBurned(address indexed from, uint256 amount);

    constructor() ERC20("SpiderionUSD", "SPUSD") {
        // Mint initial supply to deployer
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /// @notice Transfers `amount` of tokens to `recipient`, enforces minimum and burns 2%
    /// @dev Applies `nonReentrant` guard; burnAmount always > 0 given minimum transfer
    function transfer(address recipient, uint256 amount)
        public
        override
        nonReentrant
        returns (bool)
    {
        // Enforce minimum transfer amount of 50 SPUSD
        require(amount >= 50 * 10 ** decimals(), "Min transfer 50 SPUSD");

        // Calculate burn portion (2% of amount)
        uint256 burnAmount = (amount * BURN_RATE) / 100;

        // Transfer net amount to recipient
        super._transfer(_msgSender(), recipient, amount - burnAmount);
        // Burn the specified portion from sender
        _burn(_msgSender(), burnAmount);
        emit TokensBurned(_msgSender(), burnAmount);

        return true;
    }

    /// @notice Transfers `amount` from `sender` to `recipient` via allowance, enforces minimum and burns 2%
    /// @dev Applies `nonReentrant` guard; automatically adjusts allowance
    function transferFrom(address sender, address recipient, uint256 amount)
        public
        override
        nonReentrant
        returns (bool)
    {
        // Enforce minimum transfer amount of 50 SPUSD
        require(amount >= 50 * 10 ** decimals(), "Min transfer 50 SPUSD");

        // Calculate burn portion (2% of amount)
        uint256 burnAmount = (amount * BURN_RATE) / 100;

        // Transfer net amount to recipient
        super._transfer(sender, recipient, amount - burnAmount);
        // Burn the specified portion from sender
        _burn(sender, burnAmount);
        emit TokensBurned(sender, burnAmount);

        // Decrease allowance by total amount
        _approve(sender, _msgSender(), allowance(sender, _msgSender()) - amount);

        return true;
    }
}
