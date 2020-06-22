		.data
		.align	2
###############################################################
#
# DEFINICIÓN DE VARIABLES
#
###############################################################
# Dimensiones de la matriz
numfil:		.word	3
numcol:		.word	4
# Matriz con sus elementos
matriz:		.byte	'A','B','C','D'
		.byte	'E','F','G','H'
		.byte	'I','J','K','L'
		.align	2
# Coordenadas de fila y columna
fil:		.space	4
col:		.space	4
# Distancia del elemento al origen de la matriz
dist:		.space	4
# Dirección del elemento leído
dir_el:		.space	4
# Elemento leído
elemento:	.space	1
		.byte	0


###############################################################
#
# CÓDIGO DEL PROGRAMA PRINCIPAL
#
###############################################################

		.text
# Leer datos de entrada
		jal		leer_datos
# Cargar dirección base de la matriz
		la		$s0,matriz
# Cargar coordenada de fila
		lw		$s1,fil
# Cargar coordenada de columna
		lw		$s2,col
# Cargar número de columnas de la matriz
		lw		$s3,numcol

###############################################################
#
# CÓDIGO PARA ACCESO A UN ELEMENTO DE LA MATRIZ
#
###############################################################
# Calcular la distancia del elemento (i,j) al inicio de la matriz
		mult		$s1,$s3
		mflo		$t0
		addu		$t1,$t0,$s2
# Sumar distancia a la dirección base de la matriz
		addu		$t2,$s0,$t1
# Leer el elemento (i,j)
		lbu		$s4,0($t2)
###############################################################
#
# FIN DEL CÓDIGO PARA ACCESO A UN ELEMENTO DE LA MATRIZ
#
###############################################################

# Escribir en memoria el elemento leído y su distancia al origen
		sb		$s4,elemento
		sw		$t1,dist
		sw		$t2,dir_el
# Escribir datos por pantalla
		jal		escribir_datos
# Terminar
		li		$v0,10
		syscall





###############################################################
#
# CÓDIGO PARA LECTURA DE DATOS Y PRESENTACIÓN DE RESULTADOS
#
###############################################################
		.data
tira_fil:	.asciiz	"Introduzca la coordenada de fila (0 <= fil <= 2): "
tira_col:	.asciiz	"Introduzca la coordenada de columna (0 <= col <= 3): "
tira_nfil:	.asciiz	"Número de filas de la matriz: "
tira_ncol:	.asciiz	"Número de columnas de la matriz: "
tira_fil_e:	.asciiz	"Coordenada de fila del elemento solicitado: "
tira_col_e:	.asciiz	"Coordenada de columna del elemento solicitado: "
tira_dirb:	.asciiz	"Dirección base de la matriz: "
tira_dist:	.asciiz	"Distancia del elemento al origen de la matriz: "
tira_dir:	.asciiz	"Dirección del elemento leído: "
tira_elem:	.asciiz	"Elemento leído: "
tira_ord:	.asciiz	"Ordinal del elemento leído: "

tiraeoln:	.asciiz "\n"

		.text
###############################################################
#
# Introduccion de datos por teclado
#
###############################################################
leer_datos:
# Coordenada de fila
leer_fil:
#    Pedir coordenada de fila en ventana emergente
		la		$a0,tira_fil
		li		$v0,51
		syscall
#    Fila ahora en $a0: movemos a $t2
		move		$t2,$a0
#    Comprobar que coordenada está dentro de rango
            	blt		$t2,$zero,leer_fil
		lw		$t3,numfil
		bge		$t2,$t3,leer_fil
#    Guardar coordenada de fila
		sw		$t2,fil
# Coordenada de columna
leer_col:
#    Pedir coordenada de columna en ventana emergente
		la		$a0,tira_col
		li		$v0,51
		syscall
#    Columna ahora en $a0: movemos a $t2
		move		$t2,$a0
#    Comprobar que coordenada está dentro de rango
            	blt		$t2,$zero,leer_col
		lw		$t3,numcol
		bge		$t2,$t3,leer_col
#    Guardar coordenada de columna
		sw		$t2,col
# Retornar
		jr		$ra



###############################################################
#
# Presentacion de resultados por pantalla (en la zona Run I/O)
#
###############################################################
escribir_datos:
# Escribir dirección base de la matriz
 		la		$a0,tira_dirb
		li		$v0,4
		syscall
		la		$a0,matriz
		li		$v0,1
		syscall
		la		$a0,tiraeoln
		li		$v0,4
		syscall
# Escribir número de filas de la matriz
 		la		$a0,tira_nfil
		li		$v0,4
		syscall
		lw		$a0,numfil
		li		$v0,1
		syscall
		la		$a0,tiraeoln
		li		$v0,4
		syscall
# Escribir número de columnas de la matriz
 		la		$a0,tira_ncol
		li		$v0,4
		syscall
		lw		$a0,numcol
		li		$v0,1
		syscall
		la		$a0,tiraeoln
		li		$v0,4
		syscall
# Escribir coordenada de fila
 		la		$a0,tira_fil_e
		li		$v0,4
		syscall
		lw		$a0,fil
		li		$v0,1
		syscall
		la		$a0,tiraeoln
		li		$v0,4
		syscall
# Escribir coordenada de columna
 		la		$a0,tira_col_e
		li		$v0,4
		syscall
		lw		$a0,col
		li		$v0,1
		syscall
		la		$a0,tiraeoln
		li		$v0,4
		syscall
# Escribir distancia del elemento desde el comienzo de la matriz
 		la		$a0,tira_dist
		li		$v0,4
		syscall
		lw		$a0,dist
		li		$v0,1
		syscall
		la		$a0,tiraeoln
		li		$v0,4
		syscall
# Escribir dirección del elemento leído
 		la		$a0,tira_dir
		li		$v0,4
		syscall
		lw		$a0,dir_el
		li		$v0,1
		syscall
		la		$a0,tiraeoln
		li		$v0,4
		syscall
# Escribir elemento
 		la		$a0,tira_elem
		li		$v0,4
		syscall
		la		$a0,elemento
		li		$v0,4
		syscall
		la		$a0,tiraeoln
		li		$v0,4
		syscall
 		la		$a0,tira_ord
		li		$v0,4
		syscall
		lbu		$a0,elemento
		li		$v0,1
		syscall
		la		$a0,tiraeoln
		li		$v0,4
		syscall
# Retornar
		jr		$ra
