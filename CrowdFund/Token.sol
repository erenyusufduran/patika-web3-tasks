// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/token/ERC20/ERC20.sol";

// It's required, because I need an token contract address for crowd fund file.

contract Token is ERC20 {

    constructor() ERC20("Qroxyn", "QRX") {
        _mint(msg.sender, 10000000000000000);
    }
}