// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;


/**
 *  El contrato Escuela representa las aulas de la escuela.
 * 
 */
contract Escuela {
    
    /**
     * address del administrador que ha desplegado el contrato.
     * El contrato lo despliega el admin.
     */
    address public administrador;
    
    /// Nombre de la escuela
    string public escuela;
	

    /// Datos de un Aula.
    struct DatosAula {
        uint indice;
        string nombre;
    }

        
    /**
     * Datos de una entrada.
     */
    struct Entrada {
	address dir;
	string fecha;
	string ent;
	string sal;
        string puesto;
	string estado;
	string info;
    }


     /**
     * Datos de ultima entrada.
     */
    struct UltimaEntrada {
	string aula;
        uint turno;
	string fecha;
    }


    /**
     * Datos de una alerta de usuario.
     */
    struct AlertaUsuario {
	string aula;
	string fecha;
	uint estado;
    }


    
    /// Aulas de la escuela.
    DatosAula[] public aulas;

    /// Alertas de la escuela.
    UltimaEntrada[] public alertasEscuela;

    /// Alertas para un usuario.
    mapping (address => AlertaUsuario) public alertasUsuario;

    /// Turnos de la escuela.
    mapping (string => mapping (string  => uint[] )) public turnos;

    /// Mapping para evitar duplicados de turnos.
    mapping (string => mapping (string  => mapping ( uint => bool ))) public turnos_existentes;


    /// Direcciones de las personas que han asistido a algun aula en alguna de las fechas y en algun turno.
    mapping (string => mapping (string => mapping (uint => address[] ))) public personas;
   
    /// Direcciones de las personas que han asistido a algun aula en alguna de las fechas.
    mapping (string => mapping (string => address[] )) public personasTotales;
    
    // Dada la fecha actual, el nombre del aula, el turno y la dirección de la persona, devuelve
    // la entrada correspondiente a dicha persona.
    mapping (string => mapping (string => mapping (uint => mapping (address => Entrada)))) public datosAula;

    
    /// Ultimas entradas de cada persona.
    mapping (address => UltimaEntrada[] ) public ultimosRegistros;


    /**
     * Constructor.
     * 
     * @param _nombre Nombre de la escuela.
     */
    constructor(string memory _nombre) {
      
        administrador = msg.sender;
        escuela = _nombre;
    }
    

    
    /**
     * El numero de aulas creadas.
     *
     * @return El numero de aulas creadas.
     */
    function aulasLength() public view returns(uint) {
        return aulas.length;

    }


    /**
     * El numero de alertas existentes.
     *
     * @return El numero de alertas existentes.
     */
    function alertasLength() public view returns(uint) {
        return alertasEscuela.length;

    }

	  /**
     * El numero de ultimosRegistros existentes.
     *
     * @return El numero de ultimosRegistros existentes.
     */
    function ultimosRegistrosLength(address dir) public view returns(uint) {
	return ultimosRegistros[dir].length;
    }
        
    /**
     * Permite obtener la longitud del array de personasTotales.
     * 
     */
    function personasLength(string memory _nombre, string memory _fecha) public view returns(uint) {

	uint longitud = personasTotales[_fecha][_nombre].length;

	if(longitud == 0){
	  longitud = 1;
	}

  	return longitud;

    }



    /**
     * Permite obtener un address del array de personas.
     * 
     */
    function dirPersonas(string memory _nombre, string memory _fecha, uint _indice) public view returns(address) {

	if(personasTotales[_fecha][_nombre].length > 0){
	address _dirUno = personasTotales[_fecha][_nombre][_indice];
	return _dirUno;

	}else{
	return msg.sender;
	}			
	
    }


        /**
     * La alerta (si la hay) de un usuario.
     *
     */
    function alertas(address _dir) public view returns (AlertaUsuario memory) {

	return alertasUsuario[_dir]; 
    }



    /**
     * Eliminar la alerta de un usuario
     *
     */
    function reiniciarAlerta() public {

	alertasUsuario[msg.sender].estado = 0;


    }

        /**
     * El aula del que se desea ver el historial.
     *
     */
    function aulaPulsada(uint x) public view returns (string memory) {

	return aulas[x].nombre; 
    }

    
    /**
     * Crear un aula. 
     *
     * Las aulas se meteran en el array aulas, y nos referiremos a ellas por su posicion en el array.
     * 
     * @param _nombre El nombre del aula.
     * 
     * @return La posicion en el array aulas,
     */
    function crearAula(string memory _nombre) public returns (uint) {
        
        bytes memory bn = bytes(_nombre);
        require(bn.length != 0, "El nombre del aula no puede ser vacio");
        
        aulas.push(DatosAula(aulas.length, _nombre));

        return aulas.length - 1;
    }
    
 
    /**
     * Las personas pueden registrar su asistencia a un aula con el metodo guardarEntrada.
     * 
     * Impedir que se pueda meter un nombre vacio.
     *
     * @param _nombre El nombre del aula. 
     * @param _ent Hora de entrada al aula.
     * @param _fecha Fecha de entrada al aula.
     * @param _puesto Puesto en el aula.
     */
    function guardarEntrada(string memory _nombre, string memory _ent, string memory _fecha, string memory _puesto, uint _turno) public {
        
	
        bytes memory a = bytes(_nombre);
        require(a.length != 0, "El nombre no puede ser vacio");

	bytes memory b = bytes(_ent);
	require(b.length != 0, "La hora de entrada no puede ser vacio");

	bytes memory c = bytes(_fecha);
	require(c.length != 0, "La fecha no puede ser vacio");

	bytes memory d = bytes(_puesto);
        require(d.length != 0, "El puesto no puede ser vacio");

	datosAula[_fecha][_nombre][_turno][msg.sender].dir = msg.sender;
	datosAula[_fecha][_nombre][_turno][msg.sender].fecha = _fecha;
	datosAula[_fecha][_nombre][_turno][msg.sender].ent = _ent; 
	datosAula[_fecha][_nombre][_turno][msg.sender].puesto = _puesto;
 	
	if (alertasUsuario[msg.sender].estado==0) {
   	datosAula[_fecha][_nombre][_turno][msg.sender].estado = "Inicial";
	} else if (alertasUsuario[msg.sender].estado==1) {
   	datosAula[_fecha][_nombre][_turno][msg.sender].estado = "Sospechoso";
	} else if (alertasUsuario[msg.sender].estado==2) {
   	datosAula[_fecha][_nombre][_turno][msg.sender].estado = "Positivo";
	} else {
   	datosAula[_fecha][_nombre][_turno][msg.sender].estado = "Negativo";
	}

        personas[_fecha][_nombre][_turno].push(msg.sender);
	personasTotales[_fecha][_nombre].push(msg.sender);
	ultimosRegistros[msg.sender].push(UltimaEntrada(_nombre,_turno,_fecha));
	
	if (turnos_existentes[_fecha][_nombre][_turno] == false){
	   turnos[_fecha][_nombre].push(_turno);
	   turnos_existentes[_fecha][_nombre][_turno] = true;
	}

        
    }
    

    /**
     * Las personas pueden registrar su salida del aula con el metodo guardarSalida.
     * 
     * Impedir que se pueda meter un nombre vacio.
     *
     * @param _nombre El nombre del aula. 
     * @param _sal Hora de salida al aula.
     * @param _fecha Fecha de entrada al aula.
     */
    function guardarSalida(string memory _nombre, string memory _sal, string memory _fecha, uint _turno) public {

	datosAula[_fecha][_nombre][_turno][msg.sender].sal = _sal;
        
    }



    /**
     * El administrador puede eliminar un aula con el metodo eliminarAula.
     * 
     * Impedir que se pueda meter un indice vacio.
     *
     * @param _indice El nombre del aula. 
     */
    function eliminarAula(uint _indice) public {
     
        require(_indice >= 0, "El indice no puede ser negativo");


	aulas[_indice ].nombre = aulas[aulas.length - 1].nombre;	
	aulas[_indice ].indice = aulas[aulas.length - 1].indice;
	aulas.pop();
        
    }



    /**
     * Permite al administrador obtener los datos de un aula para que sean visualizados.
     * 
     */
    function guardarEntradasAula(string memory _nombre, string memory _fecha) public view returns(Entrada[] memory) {

	uint cont = 0;
	uint iterador = 0;

	uint num_turnos = turnos[_fecha][_nombre].length;
	
	for(uint j = 0; j < num_turnos ; j++){

	cont = cont + personas[_fecha][_nombre][turnos[_fecha][_nombre][j]].length;

	}	


	if(num_turnos > 0){

	Entrada[] memory entradas = new Entrada[](cont);

	for(uint j = 0; j < num_turnos ; j++){

	address[] memory _dir = personas[_fecha][_nombre][turnos[_fecha][_nombre][j]];	

	for(uint i = iterador; i < _dir.length + iterador ; i++){

	entradas[i].dir = datosAula[_fecha][_nombre][turnos[_fecha][_nombre][j]][_dir[i]].dir;
	entradas[i].fecha = datosAula[_fecha][_nombre][turnos[_fecha][_nombre][j]][_dir[i]].fecha;
	entradas[i].ent = datosAula[_fecha][_nombre][turnos[_fecha][_nombre][j]][_dir[i]].ent;
	entradas[i].sal = datosAula[_fecha][_nombre][turnos[_fecha][_nombre][j]][_dir[i]].sal;
	entradas[i].puesto = datosAula[_fecha][_nombre][turnos[_fecha][_nombre][j]][_dir[i]].puesto;
	entradas[i].estado = datosAula[_fecha][_nombre][turnos[_fecha][_nombre][j]][_dir[i]].estado;
	entradas[i].info = datosAula[_fecha][_nombre][turnos[_fecha][_nombre][j]][_dir[i]].info;
	
	}
	iterador = iterador + _dir.length;
	}
	iterador = 0;
	cont = 0;
	num_turnos = 0;
	return entradas;

	}
	else{
	
	Entrada[] memory entradas_dos = new Entrada[](1);
	entradas_dos[0].dir = address(0x3b3ddfb4C96a81B305294f445a7d7Cb185b0FBb2);
  	entradas_dos[0].fecha = "DISPONIBLES";
	entradas_dos[0].ent = "EN LA FECHA";
	entradas_dos[0].sal = "Y";
	entradas_dos[0].puesto = "ESTA";
	entradas_dos[0].estado = "AULA";

	return entradas_dos;

	}	

    }


    /**
     * Permite cambiar el estado de una persona a Negativo.
     * 
     */
    function estadoNegativo(string memory fechaNeg) public {

	uint longit = 0;

	if(ultimosRegistros[msg.sender].length > 0){
	longit = ultimosRegistros[msg.sender].length - 1;
	}

	string memory _nombre = ultimosRegistros[msg.sender][longit].aula ;
	string memory _fecha  = ultimosRegistros[msg.sender][longit].fecha ;
	uint _turno  = ultimosRegistros[msg.sender][longit].turno ;
	uint i = 0;

	bytes memory a = bytes(_nombre);
	bytes memory b = bytes(_fecha);


	datosAula[_fecha][_nombre][_turno][msg.sender].estado = "Negativo";
	datosAula[_fecha][_nombre][_turno][msg.sender].info = string(abi.encodePacked("Desde el ", fechaNeg));

	alertasEscuela.push(UltimaEntrada(_nombre, _turno, _fecha));

	bytes memory f = bytes(alertasEscuela[i].aula);
	bytes memory g = bytes(alertasEscuela[i].fecha);	

	while((i < alertasEscuela.length) && ((keccak256(f) != keccak256(a))||(alertasEscuela[i].turno != _turno)||(keccak256(g) != keccak256(b)))){

	i++;
        f = bytes(alertasEscuela[i].aula);
	g = bytes(alertasEscuela[i].fecha);
	}

	for(uint x = i; x < alertasEscuela.length - 1 ; x++){
	alertasEscuela[x].aula = alertasEscuela[x+1].aula;
	alertasEscuela[x].turno = alertasEscuela[x+1].turno;
	alertasEscuela[x].fecha = alertasEscuela[x+1].fecha;	
	}

	alertasEscuela.pop();
	i = 0;
	alertasUsuario[msg.sender].estado = 3;
	alertasUsuario[msg.sender].aula = "";
	alertasUsuario[msg.sender].fecha = "";

    }



    /**
     * Permite cambiar el estado de una persona a Positivo, y pone en Sospechoso el de las.
     * personas que han compartido aula en la misma fecha, aula y turno que dicha persona.
     */
    function estadoPositivo(string memory fechaPos) public {


	uint longit = 0;

	if(ultimosRegistros[msg.sender].length > 0){
	longit = ultimosRegistros[msg.sender].length - 1;
	}

	string memory _nombre = ultimosRegistros[msg.sender][longit].aula ;
	string memory _fecha  = ultimosRegistros[msg.sender][longit].fecha ;
	uint _turno  = ultimosRegistros[msg.sender][longit].turno ;


	bytes memory c = bytes("Positivo");    

	for(uint i = 0; i < personas[_fecha][_nombre][_turno].length; i++){

        bytes memory d = bytes(datosAula[_fecha][_nombre][_turno][personas[_fecha][_nombre][_turno][i]].estado);

	if((keccak256(d) != keccak256(c))){
	datosAula[_fecha][_nombre][_turno][personas[_fecha][_nombre][_turno][i]].estado = "Sospechoso";
	datosAula[_fecha][_nombre][_turno][personas[_fecha][_nombre][_turno][i]].info = string(abi.encodePacked("Desde el ", fechaPos));
	
    	alertasUsuario[personas[_fecha][_nombre][_turno][i]].estado = 1;
	alertasUsuario[personas[_fecha][_nombre][_turno][i]].aula = _nombre;
	alertasUsuario[personas[_fecha][_nombre][_turno][i]].fecha = _fecha;

	}
	
	}
	

	datosAula[_fecha][_nombre][_turno][msg.sender].estado = "Positivo";
	datosAula[_fecha][_nombre][_turno][msg.sender].info = string(abi.encodePacked("Desde el ", fechaPos));
        alertasEscuela.push(UltimaEntrada(_nombre, _turno, _fecha));
	alertasUsuario[msg.sender].estado = 2;
	alertasUsuario[msg.sender].aula = _nombre;
	alertasUsuario[msg.sender].fecha = _fecha;

    }
    
    
    /**
     * No se permite la recepcion de dinero.
     */
    receive() external payable {
        revert("No se permite la recepcion de dinero.");
    }
}
