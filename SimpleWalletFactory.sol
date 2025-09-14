// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./SimpleWallet.sol";

contract WalletFactory {
    address public owner;
    address public implementation;

    modifier onlyOwner() {
        require(msg.sender == owner, "No eres el owner");
        _;
    }

    event WalletCreated(address wallet, address owner);

    constructor() {
        owner = msg.sender;
    }

    /* 
     * Funcion que permite cambiar el address de SimpleWallet para los clones
     */
    function setImplementation(address _implementation) external onlyOwner {
        require(msg.sender == owner, "Solo el owner puede actualizar la implementation");
        require(_implementation != address(0), "El address de la implementacion no puede ser zero");
        implementation = _implementation;
    }

    /* 
     * Función que permite crear un clon de SimpleWallet 
     */
    function createWallet() external onlyOwner returns (address) {
        address clone = Clones.clone(implementation);
        SimpleWallet(clone).init(owner);
        emit WalletCreated(clone,owner);
        return clone;
    }
}