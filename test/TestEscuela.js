var Escuela = artifacts.require("./Escuela.sol");

contract('Usamos el contrato Escuela:', accounts => {

  let escuela;

  before(async () => {
    escuela = await Escuela.deployed();
  });

  it("El numero de aulas existentes deberia ser 1.", async () => {

	  await escuela.crearAula("R40");
	  let c = await escuela.aulasLength.call();

      assert.equal(c.toNumber(), 1, "El numero de aulas existentes deberia ser 1.");
	 
  });


   it("El numero de aulas existentes deberia ser 0.", async () => {
	   
	  await escuela.eliminarAula(0);
	  let c = await escuela.aulasLength.call();

      assert.equal(c.toNumber(), 0, "El numero de aulas existentes deberia ser 0.");
  });
 
    it("El numero de entradas registradas deberia ser 3.", async () => {

	await escuela.crearAula("R40");
	await escuela.crearAula("R50");
	await escuela.crearAula("R60");


	let c = await escuela.aulasLength.call();
    assert.equal(c.toNumber(), 3, "El numero de aulas existentes deberia ser 3.");
	  
  });

});
