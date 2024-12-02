// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MultiSend is ReentrancyGuard {
    using Address for address payable;
    using SafeERC20 for IERC20;

    function send(address[] calldata recipients, uint256[] calldata amounts) external payable nonReentrant {
        require(recipients.length == amounts.length, "MultiSend: Recipients and amounts arrays length mismatch");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(recipients[i] != address(0), "MultiSend: Cannot send to zero address");
            totalAmount += amounts[i];
        }

        require(msg.value == totalAmount, "MultiSend: Incorrect Ether value sent");

        for (uint256 i = 0; i < recipients.length; i++) {
            payable(recipients[i]).sendValue(amounts[i]);
        }
    }

    function sendToken(address token, address[] calldata recipients, uint256[] calldata amounts) external nonReentrant {
        require(recipients.length == amounts.length, "MultiSend: Recipients and amounts arrays length mismatch");

        uint256 totalAmount = 0;
        IERC20 erc20 = IERC20(token);

        for (uint256 i = 0; i < amounts.length; i++) {
            require(recipients[i] != address(0), "MultiSend: Cannot send to zero address");
            totalAmount += amounts[i];
        }

        require(erc20.allowance(msg.sender, address(this)) >= totalAmount, "MultiSend: Not enough allowance");

        for (uint256 i = 0; i < recipients.length; i++) {
            erc20.safeTransferFrom(msg.sender, recipients[i], amounts[i]);
        }
    }
}