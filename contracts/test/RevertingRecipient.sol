// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
contract RevertingRecipient { receive() external payable { revert("Rejected"); } }
