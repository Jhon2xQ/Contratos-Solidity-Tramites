// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./SimpleWallet.sol";

contract WalletFactory {
    address public immutable implementation; // lógica base

    event WalletCreated(address wallet, address owner);

    constructor() {
        implementation = address(new SimpleWallet());
    }

    function createWallet(address owner) external returns (address) {
        address clone = Clones.clone(implementation);
        SimpleWallet(clone).init(owner);
        emit WalletCreated(clone, owner);
        return clone;
    }
}
