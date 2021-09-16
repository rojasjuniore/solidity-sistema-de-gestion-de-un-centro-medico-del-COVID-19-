// Funcion que permita crear un contrato inteligente de un centro de salud
// contrato autogestioname del centro de salud
 contract CentroSalud { 
    
    // Direcciones iniciales
     address public direccionCentroSalud;
     address public direccionContrato;
     
     constructor(address _direccion) public {
         direccionCentroSalud = _direccion;
         direccionContrato = address(this);
     }
     
     
    // Mapping para almacenar un id con un resultado de una prueba de covid
    // mapping(bytes32=>bool) resultadoCovid;
    // hash[persona]-> true o false
    
    // Mapping para relacionar el hash de la prueba con el codigo de IPSF
    // mapping(bytes32=>string) resultadoCovidIpfs;
    
     // estructura de los resultado
    struct Resultados {
        bool diagnotico;
        string CodigoIpfs;
    }
    
    // mapping para relacionar el hash de la persona con los resultados (diagnotico y codigo ipfs)
    mapping(bytes32 => Resultados) resultadoCovid;
   
    
    // Eventos
    event nuevoResultado (bool, string);
    
    // funcion apra validar el centro de salud
    modifier UnicamenteCentroSalud(address _direccion){
        require(_direccion == direccionCentroSalud, "NO tiene permiso para realizar esta funcion");
        _;
    }
    
    // funcion para emitir resultados de una prueba covid
    // 123456x | true | QmUKts4VSbN2nmtzM8q3KuqLdPHRMQeBjerPBVjhhU9ock
    function resultadosPruebaCovid(string memory _idPersona, bool _resultadoCovid, string memory _codigoIpfs) 
    public UnicamenteCentroSalud(msg.sender) {

        // hash de la identificacion de la persona.
        bytes32 hashIdPersonas = keccak256(abi.encodePacked(_idPersona));
        
        // relacion del hash de la persona con la estructura del resultado
        resultadoCovid[hashIdPersonas] = Resultados(_resultadoCovid, _codigoIpfs);
        
        // Emision del evento
        emit nuevoResultado(_resultadoCovid, _codigoIpfs);
        
    }
    
    // funcion que permita la visualizacion de los resultados 
    function visualizarResultados(string memory _idPersona) public view returns (string memory, string memory){
        
        
      // hash de la identida de la persona 
    bytes32 hashIdPersonas = keccak256(abi.encodePacked(_idPersona));
    
    // retorno de un boleano como un string
    string memory resultadorPrueba;
    
    if(resultadoCovid[hashIdPersonas].diagnotico == true){
        resultadorPrueba  = "Positivo";
    }else {
        resultadorPrueba  = "Negativo";
    }
    
    // retorno de los parametros necesarios
    return (resultadorPrueba,resultadoCovid[hashIdPersonas].CodigoIpfs );

    }
    
}