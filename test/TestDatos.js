var Datos = artifacts.require("./Datos.sol");

contract('Usamos el contrato Datos:', accounts => {

  let datos;

  before(async () => {
    datos = await Datos.deployed();
  });


  it("el numero de registrados debe ser 2", async () => {

	  await datos.autoregistro();
	  let c = await datos.registradosLength.call();

      assert.equal(c.toNumber(), 2, "El numero de personas registradas deberia ser 2.");
	  
	  

  });


   it("el numero de registrados debe ser 1", async () => {

	  
	  await datos.resetearCuenta();
	  let c = await datos.registradosLength.call();

      assert.equal(c.toNumber(), 1, "El numero de personas registradas deberia ser 1.");
	  
	  

  });
 
 
 
    it("el numero de registrados debe ser 4", async () => {

	  
	  await datos.autoregistro({from: accounts[3]});
	  await datos.autoregistro({from: accounts[4]});
	  await datos.autoregistro({from: accounts[5]});
	  let c = await datos.registradosLength.call();

      assert.equal(c.toNumber(), 4, "El numero de personas registradas deberia ser 4.");
	  
	  

  });
 
 




});
