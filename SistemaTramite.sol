// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract TramiteBee {

    uint16 tramiteCounter;
    uint16 MovimientoCounter;

    struct Tramite{
        address creator;
        uint typeTramite;
        uint timestamp;
        uint[] history;
    }

    struct Movimiento{
        address from;
        address to;
        uint[] documents;
    }

    mapping (uint => Tramite) public _allTramites;
    mapping (uint => Movimiento) public _allMovements;

    function create_tramite(uint _type, address _to, uint[] memory _documents) external {
        _allTramites[tramiteCounter] = Tramite({
            creator: msg.sender,
            typeTramite: _type,
            timestamp: block.timestamp,
            history: new uint[](0)
        });
        push_movimiento(tramiteCounter, _to, _documents);
        tramiteCounter ++;
    }

    //¿Podrá haber casos en los que el movimiento vaya por dos caminos en un mismo tramite?
    //Se debe hacer un movimiento siempre y cuando el tramite esta dirigido a mi
    function push_movimiento(uint _idTramite, address _to, uint[] memory _documents) public {
        Tramite storage t = _allTramites[_idTramite];
        _allMovements[MovimientoCounter] = Movimiento({
            from: msg.sender,
            to: _to,
            documents: _documents
        });
        t.history.push(MovimientoCounter);
        MovimientoCounter ++;
    }
    
    //no de deberia poder quitar el primer movimiento
    function pop_movimiento(uint _idTramite) external {
        Tramite storage t = _allTramites[_idTramite];
        uint idMov = t.history[t.history.length - 1];
        require(msg.sender == _allMovements[idMov].from);
        t.history.pop();
    }

    function get_tramite(uint _id) external  view returns (Tramite memory){
        return _allTramites[_id];
    }
    function get_movimiento(uint _idMovemnet) external  view returns (Movimiento memory) {
        Movimiento memory m = _allMovements[_idMovemnet]; 
        return m;
    }

    function get_last_tramite() external view returns(Tramite memory) {
        return (_allTramites[tramiteCounter - 1]);
    }

    function get_last_movimiento() external view returns(Movimiento memory) {
        return (_allMovements[MovimientoCounter-1]);
    }

    function get_length_history(uint _idTramite) external view returns (uint) {
        return (_allTramites[_idTramite].history.length);
    }
}