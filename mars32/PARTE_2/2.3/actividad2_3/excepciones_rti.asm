###############################################################
#
# MANEJADOR DE EXCEPCIONES: VARIABLES Y DEFINICIONES
#
###############################################################		
		.kdata

# Zona de salvaguarda de registros
		.align	2
sv_at:		.word	0
sv_a0:		.word	0
sv_v0:		.word	0
sv_ra:		.word	0

# Mensajes
__msgExc__:	.asciiz "Ha ocurrido una excepci�n\n"
__msgExcCode__:	.asciiz "   C�digo de excepci�n  : "
__msgVAddr__:	.asciiz	"   Registro VAddr   ($8): "
__msgStatus__:	.asciiz "   Registro Status ($12): "
__msgCause__:	.asciiz "   Registro Cause  ($13): "
__msgEPC__:	.asciiz "   Registro EPC    ($14): "
__eoln__:	.byte	'\n'
__msgAbort__:	.asciiz	"Programa abortado\n"

# Mensajes espec�ficos para cada excepci�n
INT_MSG:	.asciiz	" [Interrupci�n]"
MOD_MSG:	.asciiz	" [TLB]"
TLBL_MSG:	.asciiz	" [TLBL]"
TLBS_MSG:	.asciiz	" [TLBS]"
ADEL_MSG:	.asciiz	" [Error de direcci�n en lectura de dato o instrucci�n]"
ADES_MSG:	.asciiz	" [Error de direcci�n en almacenamiento]"
IBE_MSG:	.asciiz	" [Direcci�n err�nea de instrucci�n]"
DBE_MSG:	.asciiz	" [Direcci�n err�nea de dato]"
SYSCALL_MSG:	.asciiz	" [Llamada a sistema no implementada]"
BKPT_MSG:	.asciiz	" [Punto de ruptura]"
RI_MSG:		.asciiz	" [Instrucci�n reservada]"
CpU_MSG:	.asciiz	""
OV_MSG:		.asciiz	" [Desbordamiento aritm�tico]"
TRAP_MSG:	.asciiz	" [Trap]"
R14_MSG:	.asciiz	""
DIVZ_MSG:	.asciiz	" [Divisi�n por cero]"
ID16_MSG:	.asciiz	""
ID17_MSG:	.asciiz	""
C2E_MSG:	.asciiz	" [Coprocesador 2]"
R19_MSG:	.asciiz	""
R20_MSG:	.asciiz	""
R21_MSG:	.asciiz	""
MDMX_MSG:	.asciiz	" [MDMX]"
WATCH_MSG:	.asciiz	" [Watch]"
MCHECK_MSG:	.asciiz	" [Chequeo de m�quina]"
R25_MSG:	.asciiz	""
R26_MSG:	.asciiz	""
R27_MSG:	.asciiz	""
R28_MSG:	.asciiz	""
R29_MSG:	.asciiz	""
CACHE_ERR_MSG:	.asciiz	" [Cache]"
R31_MSG:	.asciiz	""
# Tabla de punteros a los mensajes de excepci�n
		.align	2
MSG_TABLE:	.word	INT_MSG, MOD_MSG, TLBL_MSG, TLBS_MSG	 	# Excepciones 0-3
		.word	ADEL_MSG, ADES_MSG, IBE_MSG, DBE_MSG 		# Excepciones 4-7
		.word	SYSCALL_MSG, BKPT_MSG, RI_MSG, CpU_MSG	 	# Excepciones 8-11
		.word	OV_MSG, TRAP_MSG, R14_MSG, DIVZ_MSG 		# Excepciones 12-15
		.word	ID16_MSG, ID17_MSG, C2E_MSG, R19_MSG	 	# Excepciones 16-19
		.word	R20_MSG, R21_MSG, MDMX_MSG, WATCH_MSG 		# Excepciones 20-23
		.word	MCHECK_MSG, R25_MSG, R26_MSG, R27_MSG 		# Excepciones 24-27
		.word	R28_MSG, R29_MSG, CACHE_ERR_MSG, R31_MSG 	# Excepciones 28-31
# Tabla de vectores de excepci�n para las rutinas de tratamiento gen�ricas
EXV_TABLE:	.word	INT_RTE, GEN_RTE, GEN_RTE, GEN_RTE 		# Excepciones 0-3
		.word	GEN_RTE, GEN_RTE, GEN_RTE, GEN_RTE 		# Excepciones 4-7
		.word	SYSCALL_RTE, GEN_RTE, GEN_RTE, GEN_RTE 		# Excepciones 8-11
		.word	GEN_RTE, GEN_RTE, GEN_RTE, GEN_RTE	 	# Excepciones 12-15
		.word	GEN_RTE, GEN_RTE, GEN_RTE, GEN_RTE 		# Excepciones 16-19
		.word	GEN_RTE, GEN_RTE, GEN_RTE, GEN_RTE	 	# Excepciones 20-23
		.word	GEN_RTE, GEN_RTE, GEN_RTE, GEN_RTE 		# Excepciones 24-27
		.word	GEN_RTE, GEN_RTE, GEN_RTE, GEN_RTE 		# Excepciones 28-31
# Direcciones de E/S de los dispositivos
		.eqv	D7SEG_RIGHT_ADDR,0xFFFF0010			# Display de 7 segmentos derecho
		.eqv	D7SEG_LEFT_ADDR,0xFFFF0011			# Display de 7 segmentos izquierdo
		.eqv	HEXKEY_CTRL_ADDR,0xFFFF0012			# Teclado hexadecimal: control
		.eqv	COUNTER_ADDR,0xFFFF0013				# Contador
		.eqv	HEXKEY_DATA_ADDR,0xFFFF0014			# Teclado hexadecimal: datos
# C�digos de los servicios de llamada a sistema (syscall)
		.eqv	WRITE_D7SEG,1001
		.eqv	SET_COUNTER,1002
# C�digos de interrupci�n en el registro Cause
		.eqv	INT_COUNTER_CODE,0x00000400			# Interrupci�n del temporizador: bit 10
# Mensaje para la interrupci�n del contador/temporizador
COUNTER_MSG:	.asciiz	"Interrupci�n del contador/temporizador\n"


###############################################################
#
# MANEJADOR DE EXCEPCIONES: C�DIGO
#
###############################################################		
		.ktext	0x80000180
EXCEPTION_HANDLER_ENTRY:
# Salvar registros por si hubiera que retornar del manejador
	# No se salvan $k0/$k1: est�n reservados para uso del kernel
	# No se usa la pila para salvar registros: manejador no reentrante
	# Salvar $at en $k0 (antes de utilizar pseudoinstrucciones)
		move	$k0,$at
	# Salvar copia de $at en memoria
		sw	$k0,sv_at
# Identificar la causa de la excepci�n
identify_cause:
   # Copiar registro Cause ($13-coprocesador 0) en $k0
		mfc0	$k0,$13
   # Extraer el campo de c�digo de excepci�n (ExcCode)
		andi	$k0,$k0,0x7c
# Saltar a la rutina de tratamiento
get_exception_vector:
		la	$k1,EXV_TABLE
		addu	$k1,$k1,$k0
		lw	$k1,0($k1)
jump_RTE:
		jr	$k1
# Punto de retorno de las excepciones
# que no abortan la ejecuci�n del programa
continue_exception:
# Restaurar registros
restore_regs:
   # Restaurar $at
		lw	$at,sv_at
   # Borrar registro Cause ($13-coprocesador 0)
   		mtc0	$zero,$13
# Retornar del manejador de excepci�n
return_exception:
		eret

###############################################################
# RUTINA GEN�RICA DE TRATAMIENTO DE EXCEPCI�N
# La rutina imprimir� el mensaje gen�rico por pantalla
###############################################################
GEN_RTE:
	# Salvar copia de $v0 en memoria
		sw	$v0,sv_v0
	# Salvar copia de $a0 en memoria
		sw	$a0,sv_a0
	# Salvar copia de $ra en memoria
		sw	$ra,sv_ra
	# Imprimir mensajes
		jal	MSG_PRINT
	# Abortar la ejecuci�n del programa que gener� la excepci�n
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgAbort__
		syscall
		li	$v0,17		# syscall 17 (exit with code)
		li	$a0,1		# Error
		syscall

###############################################################
# RUTINA DE TRATAMIENTO DE EXCEPCI�N POR SYSCALL
###############################################################
SYSCALL_RTE:
# Chequear el registro $v0 para identificar el servicio y saltar a rutina
##### EL ALUMNO SUSTITUIR� ESTOS COMENTARIOS POR C�DIGO ENSAMBLADOR
##### QUE SALTE A LA RUTINA DE SERVICIO CORRESPONDIENTE

# Si el servicio no est� implementado, presentar mensajes y abortar
		j	GEN_RTE
# Punto de retorno para los servicios syscall implementados
continue_syscall:
# Sumar 4 al EPC para saltarse la instrucci�n syscall invocadora
		mfc0	$k0,$14
		addi	$k0,$k0,4
		mtc0	$k0,$14
# Volver al cuerpo principal del manejador
		j	continue_exception

###############################################################
# A PARTIR DE AQU� ESCRIBIREMOS LAS RUTINAS DE SERVICIO SYSCALL
###############################################################
###############################################################
# Rutina para el servicio WRITE_D7SEG
###############################################################
WRITE_D7SEG_RTE:
##### EL ALUMNO ESCRIBIR� AQU� EL C�DIGO ENSAMBLADOR
##### QUE IMPLEMENTE LA RUTINA DE SERVICIO
# Si $a1=0, escribir sobre el visualizador derecho y saltar a continue_syscall
# Si $a1=1, escribir sobre el visualizador izquierdo y saltar a continue_syscall
# Si $a1 no es ni 0 ni 1, saltar directamente a continue_syscall sin escribir en el visualizador
		j	continue_syscall
###############################################################
# Rutina para el servicio SET_COUNTER
###############################################################
SET_COUNTER_RTE:
##### EL ALUMNO ESCRIBIR� AQU� EL C�DIGO ENSAMBLADOR
##### QUE IMPLEMENTE LA RUTINA DE SERVICIO
# Si $a0=1 � $a0=0, escribir sobre el registro de control del contador
# para activar o desactivar las interrupciones y saltar a continue_syscall
# Si $a0 no es ni 0 ni 1, saltar directamente a continue_syscall
# sin escribir en el registro de control del contador
		j	continue_syscall

###############################################################
# RUTINA DE TRATAMIENTO DE EXCEPCI�N POR INTERRUPCI�N
###############################################################
INT_RTE:
   # Chequear el registro de Causa $13 para identificar 
   # la interrupci�n producida y as� saltar a la RTI correspondiente
##### EL ALUMNO SUSTITUIR� ESTOS COMENTARIOS POR C�DIGO ENSAMBLADOR
##### QUE SALTE A LA RUTINA DE TRATAMIENTO CONCRETA

# Si la RTI no est� implementada, presentar mensajes
	# Salvar copia de $v0 en memoria
		sw	$v0,sv_v0
	# Salvar copia de $a0 en memoria
		sw	$a0,sv_a0
	# Salvar copia de $ra en memoria
		sw	$ra,sv_ra
	# Imprimir mensajes
		jal	MSG_PRINT
	# Restaurar copia de $v0 en memoria
		lw	$v0,sv_v0
	# Restaurar copia de $a0 en memoria
		lw	$a0,sv_a0
	# Restaurar copia de $ra en memoria
		lw	$ra,sv_ra
# Volver al cuerpo principal del manejador
		j	continue_exception
###############################################################
# A PARTIR DE AQU� ESCRIBIREMOS LAS RTI
###############################################################
###############################################################
# Rutina para la interrupci�n del contador/temporizador
###############################################################
COUNTER_RTE:
	# Salvar registros
		sw	$a0,sv_a0	# Salvar $a0
		sw	$v0,sv_v0	# Salvar $v0
	# Escribir mensaje informativo
 		li	$v0,4		# syscall 4 (print_str)
		la	$a0,COUNTER_MSG
		syscall
	# Restaurar registros
		lw	$a0,sv_a0	# Restaurar $a0
		lw	$v0,sv_v0	# Restaurar $v0
# Volver al cuerpo principal del manejador
		j	continue_exception


###############################################################
# SUBRUTINA PARA IMPRESI�N DE MENSAJES
# Imprime los mensajes gen�ricos y espec�ficos por consola
###############################################################
MSG_PRINT:
	# Imprimir mensaje gen�rico de aviso de excepci�n
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgExc__
		syscall
	# Imprimir causa de la excepci�n
		# Imprimir c�digo de causa (decimal)
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgExcCode__
		syscall
		li	$v0,1		# syscall 1 (print_int)
		srl	$a0,$k0,2
		syscall
		# Imprimir mensaje indicando la excepci�n producida
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,MSG_TABLE
		addu	$a0,$a0,$k0
		lw	$a0,0($a0)
		syscall
		li	$v0,11		# syscall 11 (print_char)
		lb	$a0,__eoln__
		syscall
	# Imprimir contenido de los registros Status, Cause, EPC y VAddr
		# VAddr
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgVAddr__
		syscall
		li	$v0,34		# syscall 34 (print_int_hexadecimal)
		mfc0	$a0,$8
		syscall
		li	$v0,11		# syscall 11 (print_char)
		lb	$a0,__eoln__
		syscall
		# Status
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgStatus__
		syscall
		li	$v0,34		# syscall 34 (print_int_hexadecimal)
		mfc0	$a0,$12
		syscall
		li	$v0,11		# syscall 11 (print_char)
		lb	$a0,__eoln__
		syscall
		# Cause
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgCause__
		syscall
		li	$v0,34		# syscall 34 (print_int_hexadecimal)
		mfc0	$a0,$13
		syscall
		li	$v0,11		# syscall 11 (print_char)
		lb	$a0,__eoln__
		syscall
		# EPC
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgEPC__
		syscall
		li	$v0,34		# syscall 34 (print_int_hexadecimal)
		mfc0	$a0,$14
		syscall
		li	$v0,11		# syscall 11 (print_char)
		lb	$a0,__eoln__
		syscall
	# Retornar
		jr	$ra

