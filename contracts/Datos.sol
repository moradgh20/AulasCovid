// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

/**
 *  El contrato Datos contiene los datos de todas las personas registradas en la app.
 * 
 */
contract Datos {
    
    /**
     * address del administrador que ha desplegado el contrato.
     * El contrato lo despliega el admin.
     */
    address public administrador;
    

    /// Datos de una persona.
    struct DatosPersona {
	address dir;
    }
    
    /// Acceder a los datos de una persona dada su direccion.
    mapping (address => DatosPersona) public datosPersona;
    
    // Array con las direcciones de las personas registradas.
    address[] public registrados;


    /**
     * Constructor.
     * 
     */
    constructor() {
      
        administrador = msg.sender;
	registrados.push(msg.sender);
    }
    
    
    /**
     * El numero de personas registradas.
     *
     * @return El numero de personas registradas.
     */
    function registradosLength() public view returns(uint) {
        return registrados.length;
    }
    
    
    /**
     * Una persona puede registrarse con el metodo autoregistro.
     * 
     * Impedir que se puedan meter parametros vacios.
     *
     */
    function autoregistro() noRegistrados public {
        
        require(msg.sender!=address(0), "El address no puede estar vacio");
        
        datosPersona[msg.sender] = DatosPersona(msg.sender);
        
        registrados.push(msg.sender);
        
    }
     
    
    /**
     * Una persona puede resetear su cuenta con el metodo resetearCuenta.
     * 
     *
     */
    function resetearCuenta() Registrados public {
        
        uint i = 0;

	delete datosPersona[msg.sender];        

	while((i < registrados.length) && (registrados[i] != msg.sender)){

	i++;
	}

	for(uint x = i; x < registrados.length - 1 ; x++){
	registrados[x] = registrados[x+1];	
	}

	
	registrados.pop();
	i = 0;
       
    }


    /**
     * Consulta si una persona esta registrada para elegir que pantalla inicial se le muestra.
     * 
     * 
     * @return true si la persona registrada.
     */
    function elegirPantalla() public view returns (bool) {

	return estaRegistrado(msg.sender);

    } 



    /**
     * Consulta si una direccion pertenece a una persona registrada.
     * 
     * @param persona La direccion de uan persona.
     * 
     * @return true si es una persona registrada.
     */
    function estaRegistrado(address persona) public view returns (bool) {

	address _dir = datosPersona[persona].dir;
        return _dir!=address(0);
    } 



    /**
     * Obtiene los datos de una persona registrada.
     * 
     * @param persona La direccion de una persona.
     * 
     * @return los datos de una persona registrada.
     */
    function obtenerDatosPersona(address persona) soloAdmin public view returns(address) {
	
	
	if(!estaRegistrado(persona)){
	return address(0);
	} else{	
	return datosPersona[persona].dir;
	}
	
        
        
    } 


/**
     * Funcion auxiliar por si en algun momento es neceario pasar de tipo address a string.
     * 
     */
    function addressToString(address _addr) private pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(51);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

   

    /**
     * Modificador para que una funcion solo la pueda ejecutar el administrador.
     * 
     * Se usa en obtenerDatosPersona
     */
    modifier soloAdmin() {
        
        require(msg.sender == administrador, "Solo permitido al administrador");
        _;
    }


    /**
     * Modificador para que una funcion solo la pueda ejecutar una persona no registrada.
     */
    modifier noRegistrados() {
        
        require(!estaRegistrado(msg.sender), "Solo permitido a personas no registradas");
        _;
    }    


    /**
     * Modificador para que una funcion solo la pueda ejecutar una persona registrada.
     */
    modifier Registrados() {
        
        require(estaRegistrado(msg.sender), "Solo permitido a personas registradas");
        _;
    }  
    
	
    /**
     * No se permite la recepcion de dinero.
     */
    receive() external payable {
        revert("No se permite la recepcion de dinero.");
    }
}
