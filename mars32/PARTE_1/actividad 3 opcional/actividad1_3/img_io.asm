################################################################################
#
#    RUTINAS GLOBALES:
#       img_read: petición del nombre de archivo y lectura de imagen
#       img_write: petición del nombre de archivo y escritura de imagen
#	img_create: crear espacio para una imagen en memoria dinámica
#	
################################################################################

################################################################################
#
#    Sección de datos
#
################################################################################
		.data
# Nombre del fichero de imagen y tiras auxiliares
fname:		.space	100
str_fname_in:
		.asciiz	"Nombre del fichero de imagen de entrada: "
str_fname_out:
		.asciiz	"Nombre del fichero de imagen de salida: "
str_ancho:	.asciiz	"Ancho: "
str_alto:	.asciiz	"Alto:  "
str_eoln:	.asciiz	"\n"

# Tiras para mensajes de error (ver códigos en pgm_io.asm)
str_read_ok:	.asciiz	"Imagen leída correctamente"
str_write_ok:	.asciiz	"Imagen grabada correctamente"
str_read_err:	.asciiz	"Error en la lectura de la imagen: "
str_write_err:	.asciiz	"Error en la escritura de la imagen: "
str_error_1:	.asciiz	"error de apertura del fichero"
str_error_2:	.asciiz	"el archivo no es una imagen PGM"
str_error_3:	.asciiz	"ancho de la imagen desconocido"
str_error_4:	.asciiz	"el ancho de la imagen no puede ser igual a 0"
str_error_5:	.asciiz	"alto de la imagen desconocido"
str_error_6:	.asciiz	"el alto de la imagen no puede ser igual a 0"
str_error_7:	.asciiz	"el número de niveles de gris de la imagen es desconocido"
str_error_8:	.asciiz	"el número de niveles de gris de la imagen no puede ser igual a 0"
str_error_9:	.asciiz	"el número de niveles de gris de la imagen no puede ser mayor que 255"

################################################################################
#
#    Sección de código
#
################################################################################
		.text
		.globl	img_create
		.globl	img_read
		.globl	img_write


################################################################################
#
# Subrutina que reserva espacio en memoria para una imagen
#
################################################################################
# Parámetros
#	a0: imagen (por referencia)
#	a1: número de filas (por copia)
#	a2: número de columnas (por copia)
################################################################################
# Valor de retorno
#       ninguno
################################################################################
# Tipo de subrutina: hoja
################################################################################
img_create:
# Reservar espacio para la matriz
# Calcular espacio
		move	$t0,$a0
		mul	$a0,$a1,$a2
		li	$v0,9
		syscall
# El puntero al hueco generado está en $v0: copiarlo en 0($t0)		
		sw	$v0,0($t0)
# Retornar
		jr	$ra


################################################################################
#
# Subrutina que pide un nombre de fichero y lee una imagen en formato PGM
#
################################################################################
# Parámetros
#	a0: imagen (por referencia)
#	a1: número de filas (por referencia)
#	a2: número de columnas (por referencia)
################################################################################
# Valor de retorno
#       ninguno
################################################################################
# Tipo de subrutina: tallo
################################################################################
img_read:
# Marco de pila: 32 bytes
#	16 bytes para argumentos (subrutina tallo)
#	8 bytes para registros seguros $fp/$ra
		addiu	$sp,$sp,-32
# Salvar en pila registros seguros: $fp/$ra
		sw	$fp,24($sp)
		sw	$ra,28($sp)
# Iniciar puntero de marco
		move	$fp,$sp
# Salvar argumentos en pila en espacio de invocador
		sw	$a0,32($fp)
		sw	$a1,36($fp)
		sw	$a2,40($fp)
# Pedir el nombre del fichero
		la	$a0,str_fname_in
		la	$a1,fname
		li	$a2,100
		jal	ask_fname
# Invocar a la subrutina de lectura de los datos de la imagen
read_data:
		lw	$a0,32($fp)
		lw	$a1,36($fp)
		lw	$a2,40($fp)
		la	$a3,fname
		jal	pgm_read
# Escritura de mensajes
		move	$a0,$v0
		li	$a1,0
		jal	msg_print
# Igualar puntero de pila y de marco
		move	$sp,$fp
# Restaurar registros seguros
		lw	$fp,24($sp)
		lw	$ra,28($sp)
# Destruir marco de pila
		addiu	$sp,$sp,32
# Retornar
		jr	$ra


################################################################################
#
# Subrutina que pide un nombre de fichero y escribe una imagen en formato PGM
#
################################################################################
# Parámetros
#	a0: imagen (por referencia)
#	a1: número de filas (por valor)
#	a2: número de columnas (por valor)
################################################################################
# Valor de retorno
#       ninguno
################################################################################
# Tipo de subrutina: tallo
################################################################################
img_write:
# Marco de pila: 32 bytes
#	16 bytes para argumentos (subrutina tallo)
#	8 bytes para registros seguros $fp/$ra
		addiu	$sp,$sp,-32
# Salvar en pila registros seguros: $fp/$ra
		sw	$fp,24($sp)
		sw	$ra,28($sp)
# Iniciar puntero de marco
		move	$fp,$sp
# Salvar argumentos en pila en espacio de invocador
		sw	$a0,32($fp)
		sw	$a1,36($fp)
		sw	$a2,40($fp)
# Pedir el nombre del fichero
		la	$a0,str_fname_out
		la	$a1,fname
		li	$a2,100
		jal	ask_fname
# Invocar a la subrutina de escritura de los datos de la imagen
write_data:
		lw	$a0,32($fp)
		lw	$a1,36($fp)
		lw	$a2,40($fp)
		la	$a3,fname
		jal	pgm_write
# Escritura de mensajes
		move	$a0,$v0
		li	$a1,1
		jal	msg_print
# Igualar puntero de pila y de marco
		move	$sp,$fp
# Restaurar registros seguros
		lw	$fp,24($sp)
		lw	$ra,28($sp)
# Destruir marco de pila
		addiu	$sp,$sp,32
# Retornar
		jr	$ra


################################################################################
#
#    RUTINAS AUXILIARES:
#       ask_fname: petición del nombre de fichero de imagen
#       msg_print: escritura de mensajes de error
#	
################################################################################


################################################################################
#
# Subrutina que pide un nombre de fichero
#
################################################################################
# Parámetros
#	a0: tira de caracteres con mensaje indicativo (por referencia, entrada)
#	a1: tira de caracteres con nombre de fichero (por referencia, salida)
#	a2: longitud máxima del nombre del fichero (por valor)
################################################################################
# Valor de retorno
#       v0: tira de caracteres con nombre de fichero (por referencia, salida)
################################################################################
# Tipo de subrutina: hoja
################################################################################
ask_fname:
		move	$t0,$a0
		move	$t1,$a1
		move	$t2,$a2
# Pedir el nombre de fichero
		li	$v0,54
		syscall
# Borrar el fin de línea final y poner un nulo
		move	$t3,$t1
		lbu	$t4,str_eoln
loop_ask_fname:
		lbu	$t5,0($t3)
		beq	$t5,$t4,end_loop_ask_fname
		addiu	$t3,$t3,1
		b	loop_ask_fname
end_loop_ask_fname:
		sb	$zero,0($t3)
# Imprimir mensaje con el nombre de la imagen
		move	$a0,$t0
		li	$v0,4
		syscall
		move	$a0,$t1
		li	$v0,4
		syscall
		la	$a0,str_eoln
		li	$v0,4
		syscall
# Retornar
		move	$v0,$t1
		jr	$ra



################################################################################
#
# Subrutina que escribe mensajes de error
#
################################################################################
# Parámetros
#	a0: código del error
#	a1: operación realizada (0: lectura; 1: escritura)
################################################################################
# Valor de retorno
#       v0: código del error
################################################################################
# Tipo de subrutina: hoja
################################################################################
msg_print:
# Copiar argumento en $t0
		move	$t0,$a0
# Mensajes
# Comprobación de error
		bne	$t0,$zero,msg_error
# Lectura o escritura correcta
		bne	$a1,$zero,msg_write_ok
msg_read_ok:
		la	$a0,str_read_ok
		b	msg_eoln
msg_write_ok:
		la	$a0,str_write_ok
		b	msg_eoln
# Error de lectura o escritura
msg_error:
		bne	$a1,$zero,msg_write_err
msg_read_err:
		la	$a0,str_read_err
		li	$v0,4
		syscall
		b	msg_error1
msg_write_err:
		la	$a0,str_write_err
		li	$v0,4
		syscall
		b	msg_error1
msg_error1:
		bne	$t0,-1,msg_error2
		la	$a0,str_error_1
		b	msg_eoln
msg_error2:
		bne	$t0,-2,msg_error3
		la	$a0,str_error_2
		b	msg_eoln
msg_error3:
		bne	$t0,-3,msg_error4
		la	$a0,str_error_3
		b	msg_eoln
msg_error4:
		bne	$t0,-4,msg_error5
		la	$a0,str_error_4
		b	msg_eoln
msg_error5:
		bne	$t0,-5,msg_error6
		la	$a0,str_error_5
		b	msg_eoln
msg_error6:
		bne	$t0,-6,msg_error7
		la	$a0,str_error_6
		b	msg_eoln
msg_error7:
		bne	$t0,-7,msg_error8
		la	$a0,str_error_7
		b	msg_eoln
msg_error8:
		bne	$t0,-8,msg_error9
		la	$a0,str_error_8
		b	msg_eoln
msg_error9:
		bne	$t0,-9,msg_end
		la	$a0,str_error_9
		b	msg_eoln
msg_eoln:		
		li	$v0,4
		syscall
		la	$a0,str_eoln
		li	$v0,4
		syscall
# Terminar
msg_end:
# Copiar valor de retorno
		move	$v0,$t0
# Retornar
		jr	$ra

		
