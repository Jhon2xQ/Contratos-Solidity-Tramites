// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SimpleWallet {
    address public owner;

    event Executed(address target, bytes data);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // Solo el factory llamará a init (en clones no existe constructor)
    function init(address _owner) external {
        require(owner == address(0), "already initialized");
        owner = _owner;
    }

    function callTramites(address tramites, bytes calldata data) external onlyOwner {
        (bool ok, ) = tramites.call(data);
        require(ok, "call failed");
        emit Executed(tramites, data);
    }
}
