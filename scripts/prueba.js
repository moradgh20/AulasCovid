module.exports = async callback => {

    try {
        const Escuela = artifacts.require("./Escuela.sol");
		const Datos = artifacts.require("./Datos.sol");

        // Usar las cuentas de usuario
        const accounts = await web3.eth.getAccounts();
        if (accounts.length < 8) {
            throw new Error("No hay cuentas.");
        }
	
        let escuela = await Escuela.deployed();
		let datos = await Datos.deployed();
		let administrador = await escuela.administrador();
        console.log("Cuenta del administrador =", administrador);
	
		let lidiaAccount = accounts[3];
		await datos.autoregistro({from: lidiaAccount});
		await escuela.guardarEntrada("B10", "10:00","10/07/2021","23",2);
		console.log("Dir:");
		console.log(lidiaAccount);
		//console.log(evaAccount);
    } catch (err) {   // Capturar errores
        console.log(`Error: ${err}`);
    } finally {
        console.log("FIN");
    }

    callback();      // Terminar
};
