################################################################################
#
#    ORGANIZACIÓN Y ARQUITECTURA DE COMPUTADORES
#    Programa que calcula el negativo de una imagen
#    AUTOR: Luis Rincón Córcoles (luis.rincon@urjc.es)
#
################################################################################

################################################################################
#
#    Sección de datos
#
################################################################################
			.data
			.align	2
# Imagen de entrada: es un puntero a una región de memoria dinámica
#                    donde se encuentra la imagen
imagen_in:		.space	4
# Dimensiones de la imagen
ancho:			.space	4
alto:			.space	4
# Imagen de salida: es un puntero a una región de memoria dinámica
#                   donde se encuentra la imagen
imagen_out:		.space	4


################################################################################
#
#    Sección de código
#
################################################################################

			.text
			.globl	main
main:
# Reservar marco de pila (sólo espacio para parámetros)
			addiu	$sp,$sp,-16
# Leer imagen de entrada
leer_imagen:
			la	$a0,imagen_in
			la	$a1,alto
			la	$a2,ancho
			jal	img_read
# Si hay error de lectura, ir a fin
retorno_lectura:
			bne	$v0,$zero,fin_prog

# Crear espacio para la imagen de salida
			la	$a0,imagen_out
			lw	$a1,alto
			lw	$a2,ancho
			jal	img_create

# Aquí se incluye llamada a la subrutina de proceso de la imagen
proceso:
			lw	$a0,imagen_in	# Se copia el puntero en $a0
			lw	$a1,alto	# Se copia el alto en $a1
			lw	$a2,ancho	# Se copia el ancho en $a2
			lw	$a3,imagen_out
			jal	negativo

# Escribir resultados
escribir_imagen:
			lw	$a0,imagen_out	# Se copia el puntero en $a0
			lw	$a1,alto	# Se copia el alto en $a1
			lw	$a2,ancho	# Se copia el ancho en $a2
			jal	img_write
# Terminar
# Borrar marco de pila
			addiu	$sp,$sp,16
fin_prog:
			li	$v0,10
			syscall

