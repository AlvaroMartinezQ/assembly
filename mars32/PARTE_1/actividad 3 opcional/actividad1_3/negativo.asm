################################################################################
#
#    RUTINA PARA EL C�LCULO DEL NEGATIVO DE UNA IMAGEN
#    AUTOR: Luis Rinc�n C�rcoles (luis.rincon@urjc.es)
#    FECHA:
#         Versi�n 1: 8-3-2013
#         Versi�n 2: 20-10-2015
#	
################################################################################
			.text
			.globl	negativo

################################################################################
#
# Subrutina que obtiene el negativo de una imagen
#
################################################################################
# Par�metros
#	a0: imagen de entrada (por referencia)
#	a1: n�mero de filas (por valor)
#	a2: n�mero de columnas (por valor)
#       a3: imagen de salida (por referencia)
################################################################################
# Valor de retorno
#       ninguno
################################################################################
# Tipo de subrutina: hoja
################################################################################
# ALGORITMO UTILIZADO
# PROCEDURE negativo (VAR img_in: Imagen; filas, columnas: INTEGER;
#                     VAR img_out: Imagen);
#              {Cada imagen es un array de caracteres}
# VAR
#    fil, col: INTEGER;
# BEGIN
#    fil := 0;
#    REPEAT
#       col := 0;
#       REPEAT
#          img_out[fil][col] := 255 - img_in[fil][col];
#          col := col + 1;
#       UNTIL col = columnas;
#       fil := fil + 1;
#    UNTIL fil = filas;
# END;
################################################################################
negativo:
# Bucle de proceso
# fil := 0;
			move	$t1,$zero
# REPEAT
repeat_1:
# col := 0;
			move	$t0,$zero
# REPEAT
repeat_2:
# img_out[fil][col] := 255 - img_in[fil][col];
   # Leer p�xel de entrada
      # Calcular desplazamiento respecto del origen
			mult	$t1,$a2
			mflo	$t2
			addu	$t3,$t2,$t0
      # Sumar desplazamiento con registro base
			addu	$t4,$a0,$t3
      # Leer p�xel actual
			lbu	$t9,0($t4)
   # Calcular el negativo del p�xel le�do
			li	$t8,255
			sub	$t9,$t8,$t9
   # Escribir pixel resultante
      # Sumar desplazamiento con registro base
			addu	$t5,$a3,$t3
      # Escribir p�xel		
			sb	$t9,0($t5)
# Incrementar contador
# col := col + 1;
			addiu	$t0,$t0,1
# UNTIL col = columnas
until_2:
			bne	$t0,$a2,repeat_2
# Incrementar contador
# fil := fil + 1;
			addiu	$t1,$t1,1
# UNTIL col = columnas
until_1:
			bne	$t1,$a1,repeat_1
## END {subrutina}
negativo_end:
# Fin del c�digo de la subrutina
			jr		$ra
