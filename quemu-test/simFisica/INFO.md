# Verificacion de que el código en arm de simFisica está bien

Para ello primero se debe compilar el código en arm, para ello:

- Copiar el código en el `./quemu-test/main.s`.
- Ejecutar el comando `make` en el directorio `./quemu-test/`.
- Ejecutar el comando `make runQEMU` en el directorio `./quemu-test/`.
- Ejecutar el comando `make runGDB` en el directorio `./quemu-test/`, pero en otra terminal.
- Una vez dentro correr toda la simulación.
- Una vez terminado, correr: `x/4096f direccion_base_de_x` (probablemente sea `0x00000000400801e8`).
- Copiar la respuesta y pegarla en un archivo temporal, usemos `./quemu-test/simFisica/quemu-temp.txt`.
- Borrar en ese archivo todas las direccione y dejar solo los valores flotantes, quedando algo así:
  ```txt
  100 25
  45.7589 25
  25 25
  ...
  ```
- Luego compilar el archivo en c, para ello correr el comando `gcc simFisica.c -o simFisica`.
- Luego correr el comando `./simFisica > c-temp.txt`.
- En este archivo se debe borrar los `.0000` ya que en el archivo anterior no los tiene.
- Luego correr el comando `diff quemu-temp.txt c-temp.txt` o verificar manualmente si son iguales.
