// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract Tramites {
    uint tramiteCounter;
    uint MovimientoCounter;

    struct Tramite{
        address creador;
        uint tipoTramite;
        uint[] seguimiento;
    }

    struct Movimiento{
        address emisor;
        address receptor;
        uint timestamp;
        uint[] documentos;
    }

    mapping (uint => Tramite) allTramites;
    mapping (uint => Movimiento) allMovimientos;

    modifier onlyEmisor(uint _idTramite) {
        uint longitudS = allTramites[_idTramite].seguimiento.length;
        require(longitudS > 1, "No se puede borrar el primer movimiento");
        uint idUltimoMovimiento = allTramites[_idTramite].seguimiento[longitudS - 1];
        require(msg.sender == allMovimientos[idUltimoMovimiento].emisor, "No eres el emisor");
        _;
    }

    function crearTramite(uint _tipoTramite, address _receptor, uint[] calldata _documentos) external {
        allTramites[tramiteCounter] = Tramite(msg.sender, _tipoTramite, new uint[](0));
        crearMovimiento(tramiteCounter, _receptor, _documentos);
        tramiteCounter ++;
    }

    function crearMovimiento(uint _idTramite, address _receptor, uint[] calldata _documentos) public {
        allMovimientos[MovimientoCounter] = Movimiento(msg.sender, _receptor, block.timestamp, _documentos);
        allTramites[_idTramite].seguimiento.push(MovimientoCounter);
        MovimientoCounter ++;
    }

    function quitarMovimiento(uint _idTramite) external onlyEmisor(_idTramite) {
        allTramites[_idTramite].seguimiento.pop();
    }

    //funciones para consumo de datos

    function getTramite(uint _idTramite) external view returns (Tramite memory) {
        return allTramites[_idTramite];
    }

    function getMovimiento(uint _idMovimiento) external view returns (Movimiento memory) {
        return allMovimientos[_idMovimiento];
    }

    function getLength(uint _idTramite) external view returns (uint) {
        return allTramites[_idTramite].seguimiento.length;
    }
}