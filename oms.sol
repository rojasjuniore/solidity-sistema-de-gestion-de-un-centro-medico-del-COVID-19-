pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
// import "./ERC20.sol";
import "./centroSalud.sol";

contract OMS_COVID {
    // instancia del contrato token
    // ERC20Basic private token;

    // direccion de la oms
    address public OMS; //  owner Dueño del contrato

    // constructor del
    constructor() public {
        OMS = msg.sender;
    }

    // mapping para relacionar los centros de salud (direccion/address) con la valides de la gestion
    mapping(address => bool) public validacionCentroSalud;

    // Relaciona con una direccion de un centro de salud con su contrato
    mapping(address => address) public centroDeSaludContrato;

    // Ejemplo:
    // owner ->0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 -> true = "tiene permiso para crear smart contrat"
    // 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c -> false = "No tiene permiso para crear smart contrat"

    /*array de direcciones que almacene los centros de salud validacion centro de salud
    Validados*/
    address[] public direccionContratosSalud;

    // array de las direcciones que soliciten acceso
    address[] Solicitudes;

    // Eventos a emitir
    event SolicitudAcceso(address);
    event NuevoCentroValidado(address);
    event NuevoContrato(address, address);

    // Modificador que permita unicamente la ejecucion de funciones por la OMS

    modifier UnicamenteOms(address _direccion) {
        require(
            _direccion == OMS,
            "NO tiene permiso para realizar esta funcion"
        );
        _;
    }

    // funcion para solicitar acceso al sistema medico

    function solicitarAcceso() public {
        // almacenamos las solicitudes - direccion
        Solicitudes.push(msg.sender);

        // Emision de Eventos
        emit SolicitudAcceso(msg.sender);
    }

    // Visualizamos solicitudes de acceso
    function visualizarSolicitudes()
        public
        view
        UnicamenteOms(msg.sender)
        returns (address[] memory)
    {
        // retornamos un array de solicitudes
        return Solicitudes;
    }

    // funcion para validar nuevos centro de salud que puedan autogestionarse -> UnicamenteOms
    function centroSalud(address _centroSalud)
        public
        UnicamenteOms(msg.sender)
    {
        // asignacion del estado de valides al centro de salud
        validacionCentroSalud[_centroSalud] = true;
        // Emision de Eventos
        emit NuevoCentroValidado(_centroSalud);
    }

    function factoryCentroSalud() public {
        // filtrado para que unicamente los centro de salud validados sean capaces de ejecuar esta funcion
        require(
            validacionCentroSalud[msg.sender] == true,
            "No tienes persmiso para realizar esta funcion"
        );

        // Generar un smart Contract -> generar su direccion
        address contratoCentroSalud = address(new CentroSalud(msg.sender));

        // Almacenamineto de la direccion del contrato en el array
        direccionContratosSalud.push(contratoCentroSalud);

        // Relacion entre el centro de salud y su contrato.
        centroDeSaludContrato[msg.sender] = contratoCentroSalud;

        // Emision del Eventos
        emit NuevoContrato(contratoCentroSalud, msg.sender);
    }
}
