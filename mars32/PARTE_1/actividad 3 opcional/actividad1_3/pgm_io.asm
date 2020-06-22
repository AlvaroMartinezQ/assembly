################################################################################
#
#    LECTURA Y ESCRITURA DE IMÁGENES EN FORMATO PGM
#    
################################################################################
#
#    RUTINAS GLOBALES:
#       pgm_read: lectura de archivo con imagen PGM
#       pgm_write: escritura de archivo con imagen PGM
#	
#################################################################################
#    Limitaciones:
#       El tamaño de la imagen no puede superar los  MBytes
#       No se pueden leer imágenes en color
#       El número de niveles de gris de la imagen no puede ser superior a 255
#
################################################################################


################################################################################
#
# Códigos de error de las subrutinas
#
################################################################################
#
#   0: lectura o escritura correcta
#  -1: error de apertura del fichero
#  -2: el archivo no es una imagen PGM (no tiene el número mágico)
#  -3: ancho de la imagen desconocido
#  -4: ancho de la imagen igual a 0
#  -5: alto de la imagen desconocido
#  -6: alto de la imagen igual a 0
#  -7: número de niveles de gris desconocido
#  -8: número de niveles de gris igual a 0
#  -9: número de niveles de gris de la imagen mayor que 255
#
################################################################################

		
################################################################################
#
#    Sección de datos
#
################################################################################				
		.data

eoln:		.asciiz	"\n"
tab_char:	.byte	9 		# Tabulador: '\t'
lf_char:	.byte	10		# Salto de línea: '\lf'
cr_char:	.byte	13		# Retorno de carro: '\cr'
sp_char:	.byte	32		# Espacio en blanco: ' '

		.align	2
buffer:		.space	10


		
################################################################################
#
#    Sección de código
#
################################################################################
		.text
		.globl	pgm_read
		.globl	pgm_write

################################################################################
#
# Subrutina que lee una imagen en formato PGM
#
################################################################################
# Parámetros
#	a0: imagen (por referencia)
#	a1: número de filas (por referencia)
#	a2: número de columnas (por referencia)
#       a3: tira de caracteres con el nombre del fichero
################################################################################
# Valor de retorno
#       v0: código de error (=0 si correcto, <0 si error)
################################################################################
# Tipo de subrutina: tallo
################################################################################
pgm_read:
# Marco de pila: 48 bytes
#	16 bytes para argumentos (subrutina tallo)
#	32 bytes para registros seguros $s0/$s1/$s2/$s3/$fp/$ra
		addiu	$sp,$sp,-48
# Salvar en pila registros seguros: $s0/$s1/$s2/$s3/$fp/$ra
		sw	$s0,24($sp)
		sw	$s1,28($sp)
		sw	$s2,32($sp)
		sw	$s3,36($sp)
		sw	$fp,40($sp)
		sw	$ra,44($sp)
# Iniciar puntero de marco
pgm_read_fpinit:
		move	$fp,$sp
# Salvar argumentos en pila en espacio de invocador
		sw	$a0,48($fp)
		sw	$a1,52($fp)
		sw	$a2,56($fp)
		sw	$a3,60($fp)
# Copiar registros de argumentos en $s0, $s1,$s2
		move	$s0,$a0
		move	$s1,$a1
		move	$s2,$a2
# Abrir el fichero para leer
pgm_read_fopen:
		li	$v0,13
		lw	$a0,60($fp)
		li	$a1,0
		li	$a2,0
		syscall
# Si error de apertura, ir a fin
		blt	$v0,$zero,error_open
# Descriptor en $s3
pgm_read_fd_save_s3:
		move	$s3,$v0
# Leer cadena mágica (2 bytes) y ponerla en buffer
pgm_read_magic:
		li	$v0,14
		move	$a0,$s3
		la	$a1,buffer
		li	$a2,2
		syscall
# Comprobar que la cadena mágica es "P5"
		li	$t0,'5'
		sll	$t0,$t0,8
		ori	$t0,$t0,'P'
		lhu	$t1,buffer
		bne	$t0,$t1,error_P5

# Saltarse comentarios
pgm_read_comment_loop:
# Saltar hasta carácter no "blanco"
		move	$a0,$s3
		jal	jump_whitesp
# Si el carácter leído no es '#', salir del bucle
		li	$t0,'#'
		lbu	$t1,buffer
		bne	$t0,$t1,pgm_read_comment_loop_end
# Si el carácter leído es '#', llegar hasta el salto de línea
		move	$a0,$s3
		jal	jump_lf
# Continuar en el bucle
		b	pgm_read_comment_loop
pgm_read_comment_loop_end:

# Leer ancho, debe ser mayor que 0
pgm_read_width:
		move	$a0,$s3
		jal	read_num
		bne	$v0,$zero,error_width01
		beq	$v1,$zero,error_width02
		sw	$v1,0($s2)
# Saltar hasta carácter no "blanco"
		move	$a0,$s3
		jal	jump_whitesp
# Leer alto, debe ser mayor que 0
pgm_read_height:
		move	$a0,$s3
		jal	read_num
		bne	$v0,$zero,error_height01
		beq	$v1,$zero,error_height02
		sw	$v1,0($s1)
# Saltar hasta carácter no "blanco"
		move	$a0,$s3
		jal	jump_whitesp
# Leer número de niveles de gris (debe ser menor o igual que 255)
pgm_read_gray:
		move	$a0,$s3
		jal	read_num
		bne	$v0,$zero,error_gray01
		beq	$v1,$zero,error_gray02
		bgt	$v1,255,error_gray03
# El último carácter leído es un "blanco", y lo daremos por bueno
# Reservar espacio para la matriz
# Calcular espacio
		lw	$t0,0($s2)
		lw	$t1,0($s1)
		mul	$a0,$t0,$t1
# Reservar espacio en memoria dinámica
		li	$v0,9
		syscall
# El puntero al hueco generado está en $v0: copiarlo en 0($s0)		
		sw	$v0,0($s0)
# Leer datos de la imagen, línea por línea
pgm_read_img_data:
# Poner puntero inicial y final
		lw	$t0,0($s0)
		lw	$t2,0($s1)
		lw	$t3,0($s2)
		mul	$t1,$t2,$t3
		addu	$t1,$t0,$t1
pgm_read_loop:
		li	$v0,14
		move	$a0,$s3
		move	$a1,$t0
		move	$a2,$t3
		syscall
# Incrementar puntero
		addu	$t0,$t0,$t3
# Condición de salir
		bne	$t0,$t1,pgm_read_loop
# Leido correctamente
		move	$t0,$zero
		b	pgm_read_end
# Terminar
# Erorres
error_open:
		li	$t0,-1
		b	pgm_read_end
error_P5:
		li	$t0,-2
		b	pgm_read_end
error_width01:
		li	$t0,-3
		b	pgm_read_end
error_width02:
		li	$t0,-4
		b	pgm_read_end
error_height01:
		li	$t0,-5
		b	pgm_read_end
error_height02:
		li	$t0,-6
		b	pgm_read_end
error_gray01:
		li	$t0,-7
		b	pgm_read_end
error_gray02:
		li	$t0,-8
		b	pgm_read_end
error_gray03:
		li	$t0,-9
		b	pgm_read_end
# Secuencia de salida de la subrutina
pgm_read_end:
# Cerrar archivo
pgm_read_fclose:
		li	$v0,16
		move	$a0,$s3
		syscall
# Copiar valor de retorno
		move	$v0,$t0
pgm_read_return:
# Igualar puntero de pila y de marco
		move	$sp,$fp
# Restaurar registros seguros: $s0/$s1/$s2/$s3/$fp/$ra
		lw	$s0,24($sp)
		lw	$s1,28($sp)
		lw	$s2,32($sp)
		lw	$s3,36($sp)
		lw	$fp,40($sp)
		lw	$ra,44($sp)
# Destruir marco de pila
		addiu	$sp,$sp,48
# Retornar
		jr	$ra



################################################################################
#
# Subrutina que escribe una imagen en formato PGM
#
################################################################################
# Parámetros
#	a0: imagen (por referencia)
#	a1: número de filas (por copia)
#	a2: número de columnas (por copia)
################################################################################
# Valor de retorno
#       v0: código de error (=0 si correcto, <0 si error)
################################################################################
# Tipo de subrutina: tallo
################################################################################
pgm_write:
# Marco de pila: 48 bytes
#	16 bytes para argumentos (subrutina tallo)
#	32 bytes para registros seguros $s0/$s1/$s2/$s3/$fp/$ra
		addiu	$sp,$sp,-48
# Salvar en pila registros seguros: $s0/$s1/$s2/$s3/$fp/$ra
		sw	$s0,24($sp)
		sw	$s1,28($sp)
		sw	$s2,32($sp)
		sw	$s3,36($sp)
		sw	$fp,40($sp)
		sw	$ra,44($sp)
# Iniciar puntero de marco
pgm_write_fpinit:
		move	$fp,$sp
# Salvar argumentos en pila en espacio de invocador
		sw	$a0,48($fp)
		sw	$a1,52($fp)
		sw	$a2,56($fp)
		sw	$a3,60($fp)
# Copiar registros de argumentos en $s0, $s1,$s2
		move	$s0,$a0
		move	$s1,$a1
		move	$s2,$a2
# Abrir el fichero para escribir
pgm_write_fopen:
		li	$v0,13
		lw	$a0,60($fp)
		li	$a1,1
		li	$a2,1
		syscall
# Si error de apertura, ir a fin
		blt	$v0,$zero,error_write_open
# Descriptor en $s3
pgm_write_fd_save_s3:
		move	$s3,$v0
# Escribir cadena mágica P5
pgm_write_magic:
		li	$t0,'P'
		sb	$t0,buffer
		li	$t0,'5'
		sb	$t0,buffer+1
		li	$v0,15
		move	$a0,$s3
		la	$a1,buffer
		li	$a2,2
		syscall
# Escribir fin de línea
		li	$v0,15
		move	$a0,$s3
		la	$a1,lf_char
		li	$a2,1
		syscall
# No se escriben comentarios
# Escribir ancho
		move	$a0,$s3
		move	$a1,$s2
		jal	write_num
# Escribir blanco
		li	$v0,15
		move	$a0,$s3
		la	$a1,sp_char
		li	$a2,1
		syscall
# Escribir alto
		move	$a0,$s3
		move	$a1,$s1
		jal	write_num
# Escribir fin de línea
		li	$v0,15
		move	$a0,$s3
		la	$a1,lf_char
		li	$a2,1
		syscall
# Escribir grises
		move	$a0,$s3
		li	$a1,255
		jal	write_num
# Escribir fin de línea
		li	$v0,15
		move	$a0,$s3
		la	$a1,lf_char
		li	$a2,1
		syscall
# Escribir datos de la imagen, línea por línea
pgm_write_img_data:
# Poner puntero inicial y final
		move	$t0,$s0
		move	$t2,$s1
		move	$t3,$s2
		mul	$t1,$t2,$t3
		addu	$t1,$t0,$t1
pgm_write_loop:
		li	$v0,15
		move	$a0,$s3
		move	$a1,$t0
		move	$a2,$t3
		syscall
# Incrementar puntero
		addu	$t0,$t0,$t3
# Condición de salir
		bne	$t0,$t1,pgm_write_loop
# Escrito correctamente
		move	$t0,$zero
		b	pgm_write_end
# Terminar
# Erorres
error_write_open:
		li	$t0,-1
		b	pgm_write_end
# Secuencia de salida de la subrutina
pgm_write_end:
# Cerrar archivo
pgm_write_fclose:
		li	$v0,16
		move	$a0,$s3
		syscall
# Copiar valor de retorno
		move	$v0,$t0
pgm_write_return:
# Igualar puntero de pila y de marco
		move	$sp,$fp
# Restaurar registros seguros: $s0/$s1/$s2/$s3/$fp/$ra
		lw	$s0,24($sp)
		lw	$s1,28($sp)
		lw	$s2,32($sp)
		lw	$s3,36($sp)
		lw	$fp,40($sp)
		lw	$ra,44($sp)
# Destruir marco de pila
		addiu	$sp,$sp,48
# Retornar
		jr	$ra



################################################################################
#
#    RUTINAS AUXILIARES:
#       read_num: lee en fichero un entero representado en ASCII
#       write_num: escribe en fichero un entero representado en ASCII
#	is_whitesp: indica si el carácter actual es un blanco
#       jump_whitesp: salta blancos en un fichero
#	jump_lf: salta caracteres en fichero hasta llegar al retorno de línea
#	
#################################################################################



################################################################################
#
# Rutina que lee de fichero un valor numérico en ASCII
# El primer carácter está en buffer
# Si encuentra algo que no sea numérico o "blanco": error
#
################################################################################
# Parámetros
#	a0: descriptor del fichero
################################################################################
# Valor de retorno
#       v0: código de error
#       v1: valor leído
################################################################################
# Tipo de subrutina: tallo
################################################################################
read_num:
# Marco de pila: 32 bytes
#	16 bytes para argumentos (subrutina tallo)
#	8 bytes para registros seguros $fp/$ra
		addiu	$sp,$sp,-32
# Salvar en pila registros seguros: $fp/$ra
		sw	$fp,24($sp)
		sw	$ra,28($sp)
# Iniciar puntero de marco
		move	$fp,$sp
# Poner descriptor en $t9
		move	$t9,$a0
# Poner valor acumulado a 0
		move	$v1,$zero
loop_read_num:
# Si el carácter actual no es un dígito, error
		lbu	$t0,buffer
		li	$t1,'0'
		subu	$t2,$t0,$t1
		blt	$t2,$zero,end_loop_read_num
		bgt	$t2,9,end_loop_read_num
# Acumular el valor
		li	$t3,10
		mul	$v1,$v1,$t3
		addu	$v1,$v1,$t2
# Leer el siguiente carácter
# Faltaría comprobar si fin de fichero
		li	$v0,14
		move	$a0,$t9
		la	$a1,buffer
		li	$a2,1
		syscall
# Continuar en el bucle
		b	loop_read_num
end_loop_read_num:
# Último carácter leído no es un dígito
# Si ese carácter no es un "blanco": error
		lbu	$a0,buffer
		jal	is_whitesp
		bne	$v0,$zero,ok_read_num
error_read_num:
		li	$v0,-1
		b	end_read_num
ok_read_num:
		move	$v0,$zero
end_read_num:
# Igualar puntero de pila y de marco
		move	$sp,$fp
# Restaurar puntero de pila
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
# Rutina que se salta caracteres en blanco en un fichero
# Como mínimo se lee un carácter
# El último carácter leído está en la primera posición del buffer
#
################################################################################
# Parámetros
#	a0: descriptor del fichero
################################################################################
# Valor de retorno
#       ninguno
################################################################################
# Tipo de subrutina: tallo
################################################################################
jump_whitesp:
# Marco de pila: 32 bytes
#	16 bytes para argumentos (subrutina tallo)
#	8 bytes para registros seguros $fp/$ra
		addiu	$sp,$sp,-32
# Salvar en pila registros seguros: $fp/$ra
		sw	$fp,24($sp)
		sw	$ra,28($sp)
# Iniciar puntero de marco
		move	$fp,$sp
# Poner descriptor en $t9
		move	$t9,$a0
# Bucle
loop_jump_whitesp:
# Leer un carácter
		li	$v0,14
		move	$a0,$t9
		la	$a1,buffer
		li	$a2,1
		syscall
# Carácter leído en $a0
# Faltaría comprobar si fin de fichero
		lbu	$a0,buffer
		jal	is_whitesp
		bne	$v0,$zero,loop_jump_whitesp
# Si llegamos aquí, estamos en un carácter que no es blanco
end_loop_jump_whitesp:
# Igualar puntero de pila y de marco
		move	$sp,$fp
# Restaurar puntero de pila
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
# Rutina que indica si el carácter actual es un "blanco"
#
################################################################################
# Parámetros
#	a0: carácter actual
#################################################################################
# Valor de retorno
#       v0: 1 si cierto, 0 si falso
#################################################################################
# Tipo de subrutina: hoja
##################################################################################
is_whitesp:
# Si tabulador, seguir leyendo
		lbu	$t0,tab_char
		beq	$a0,$t1,is_whitesp_then
		lbu	$t0,cr_char
		beq	$a0,$t0,is_whitesp_then
		lbu	$t0,lf_char
		beq	$a0,$t0,is_whitesp_then
		lbu	$t0,sp_char
		beq	$a0,$t0,is_whitesp_then
is_whitesp_else:
		li	$v0,0
		b	is_whitesp_endif
is_whitesp_then:
		li	$v0,1
is_whitesp_endif:
# Retornar
		jr	$ra



################################################################################
#
# Rutina que se salta caracteres hasta el próximo fin de línea
# Como mínimo se lee un carácter
# El último carácter leído es el lf
#
################################################################################
# Parámetros
#	a0: descriptor del fichero
################################################################################
# Valor de retorno
#       ninguno
################################################################################
# Tipo de subrutina: hoja
################################################################################
jump_lf:
# Poner descriptor en $t9
		move	$t9,$a0
# Bucle
loop_jump_lf:
# Leer un carácter
		li	$v0,14
		move	$a0,$t9
		la	$a1,buffer
		li	$a2,1
		syscall
# Carácter leído en $t0
		lbu	$t0,buffer
# Si no igual a LF, seguir
		lbu	$t1,lf_char
		bne	$t0,$t1,loop_jump_lf
# Si llegamos aquí, estamos en un carácter LF
end_loop_jump_lf:
		jr	$ra



################################################################################
#
# Rutina que escribe en fichero un valor numérico en ASCII
# Pone los dígitos en orden inverso en buffer
#
################################################################################
# Parámetros
#	a0: descriptor del fichero
#	a1: dato numérico
#################################################################################
# Valor de retorno
#       ninguno
#################################################################################
# Tipo de subrutina: hoja
#################################################################################
write_num:
		move	$t0,$a0
		move	$t1,$a1
# Escribir en buffer
		move	$t9,$t1
		li	$t8,10
		la	$t2,buffer
loop_write_num_01:
		div	$t9,$t8
		mfhi	$t7
		addiu	$t7,$t7,'0'
		sb	$t7,0($t2)
		addiu	$t2,$t2,1
		mflo	$t9
		bne	$t9,$zero,loop_write_num_01
end_loop_write_num_01:
# Escribir en fichero
		la	$t3,buffer
loop_write_num_02:
		addiu	$t2,$t2,-1
		li	$v0,15
		move	$a0,$t0
		move	$a1,$t2
		li	$a2,1
		syscall
		bne	$t2,$t3,loop_write_num_02
# Retornar
		jr	$ra



