	.data
m1:	.asciiz "Caso de prueba 2\n"
m2:	.asciiz "Fin del caso de prueba 2\n"
	.text
# Comienzo
main:
# Mensaje inicial
	li	$v0,4	# syscall 4 (print_str)
	la	$a0,m1
	syscall
# Proceso
	li	$t0,0x00400002
	sw	$3,0($t0)
	sw	$3,2($t0)
	sw	$3,4($t0)
# Mensaje final
	li	$v0,4	# syscall 4 (print_str)
	la	$a0,m2
	syscall
# Terminar
	li	$v0,17	# syscall 4 (print_str)
	li	$a0,0
	syscall
