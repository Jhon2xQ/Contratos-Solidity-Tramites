// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract Tramites {
    uint private tramiteCounter;
    uint private MovimientoCounter;

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

    event tramiteCreado(uint idTramite, address creador, uint tipoTramite);
    event movimientoCreado(uint idTramite, uint idMovimiento, address emisor, address receptor);
    event movimientoEliminado(uint idTramite, uint idMovimiento);

    mapping (address => bool) private autorizacion;
    mapping (address => uint[]) private userTramites;
    mapping (uint => Tramite) private allTramites;
    mapping (uint => Movimiento) private allMovimientos;

    modifier onlyEmisor(uint _idTramite) {
        uint longitudS = allTramites[_idTramite].seguimiento.length;
        require(longitudS > 1, "No se puede borrar el primer movimiento");
        uint idUltimoMovimiento = allTramites[_idTramite].seguimiento[longitudS - 1];
        require(msg.sender == allMovimientos[idUltimoMovimiento].emisor, "No eres el emisor");
        _;
    }

    modifier onlyReceptor(uint _idTramite) {
        uint longitudS = allTramites[_idTramite].seguimiento.length;
        if(longitudS == 0) {
            _;
        } else {
        uint idUltimoMovimiento = allTramites[_idTramite].seguimiento[longitudS - 1];
        require(msg.sender == allMovimientos[idUltimoMovimiento].receptor, "No eres el receptor");
        _;
        }
    }

    // ============================ TRAMITES =============================
    //funcion para iniciar un nuevo trámite y registrar el primer movimiento
    function crearTramite(uint _tipoTramite, address _receptor, uint[] calldata _documentos) 
    external
    {
        userTramites[msg.sender].push(tramiteCounter);  
        allTramites[tramiteCounter] = Tramite(msg.sender, _tipoTramite, new uint[](0));
        emit tramiteCreado(tramiteCounter, msg.sender, _tipoTramite);
        crearMovimiento(tramiteCounter, _receptor, _documentos);
        tramiteCounter ++;
    }

    //funcion para añadir movimientos al historial de un tramite si el receptor es al que fue digirido.
    function crearMovimiento(uint _idTramite, address _receptor, uint[] calldata _documentos) 
    public
    onlyReceptor(_idTramite) 
    {
        allMovimientos[MovimientoCounter] = Movimiento(msg.sender, _receptor, block.timestamp, _documentos);
        allTramites[_idTramite].seguimiento.push(MovimientoCounter);
        emit movimientoCreado(_idTramite, MovimientoCounter, msg.sender, _receptor);
        MovimientoCounter ++;
    }

    //quitar el ultimo movimiento pero solo si fue creado por el mismo que llama la funcion.
    function quitarMovimiento(uint _idTramite) 
    external
    onlyEmisor(_idTramite) 
    {
        uint idEliminado = allTramites[_idTramite].seguimiento[allTramites[_idTramite].seguimiento.length - 1];
        emit movimientoEliminado(_idTramite, idEliminado);
        allTramites[_idTramite].seguimiento.pop();
    }

    // =================== CONSUMO DE DATOS ==================

    //Obtener una estructura tramite por su id
    function getTramite(uint _idTramite) external view returns (Tramite memory) {
        return allTramites[_idTramite];
    }

    //obtener una estructura movimiento por su id
    function getMovimiento(uint _idMovimiento) external view returns (Movimiento memory) {
        return allMovimientos[_idMovimiento];
    }

    //Obtener la lista de Tramites creados por un usuario
    function getUserTramites(address _sender) external view returns (Tramite[] memory) {
        uint[] memory idTramites = userTramites[_sender];
        Tramite[] memory tramites = new Tramite[](idTramites.length);
        for (uint i = 0; i < idTramites.length; i++) 
        {
            tramites[i] = allTramites[idTramites[i]];
        }
        return tramites;
    }

    //Obtener el historial en orden de un determiando tramite
    function getHistorial(uint _idTramite) external view returns (Movimiento[] memory) {
        uint[] memory seguimiento = allTramites[_idTramite].seguimiento;
        Movimiento[] memory historial = new Movimiento[](seguimiento.length);

        for (uint i = 0; i < seguimiento.length; i++) {
            historial[i] = allMovimientos[seguimiento[i]];
        }
        return historial;
    }

    /*
    -SERIA BUENO AGREGAR AUTORIZACION PARA QUE SOLO DETERMINADAS DIRECCIONES PUEDAN LLAMAR LAS FUNCIONES
    -SE PUEDE AGREGAR UN RELAYER PARA QUE SE DELEGUE TODOS LOS CONSTOS DE TRANSACCION A UNA DIRECCION
    */
}