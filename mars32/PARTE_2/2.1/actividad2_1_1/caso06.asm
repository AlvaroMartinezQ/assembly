	.data
m1:	.asciiz "Caso de prueba 6\n"
m2:	.asciiz "Fin del caso de prueba 6\n"
	.text
# Comienzo
main:
# Mensaje inicial
	li	$v0,4	# syscall 4 (print_str)
	la	$a0,m1
	syscall
# Proceso
	li	$s0,1
	tnei	$zero,0
	tlti	$s0,0
	teqi	$s0,0
	tgei	$s0,0
# Mensaje final
	li	$v0,4	# syscall 4 (print_str)
	la	$a0,m2
	syscall
# Terminar
	li	$v0,17	# syscall 4 (print_str)
	li	$a0,0
	syscall
