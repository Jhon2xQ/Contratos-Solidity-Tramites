// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SimpleWallet is Initializable {
    address public owner;
    
    event Executed(address target, bytes data);

    modifier onlyOwner() {
        require(msg.sender == owner, "no eres el owner");
        _;
    }
    
    /*
     * No es necesario la inicialización de variables.
     */
    constructor() {
        _disableInitializers();
    }
    
    /* 
     * Inicialización del contrato, llamado una sola vez.
     */
    function init(address _owner) external initializer {
        require(_owner != address(0), "invalid owner");
        owner = _owner;
    }

    /*
     * Funcion que permite llamar a funciones del contrato de tramites 
     */
    function callTramites(address tramites, bytes calldata data) external onlyOwner {
        (bool ok, ) = tramites.call(data);
        require(ok, "call failed");
        emit Executed(tramites, data);
    }
}