	.data
M1:	.space	4096
M2:	.space	4096
M3:	.space	4096

	.text
	la	$s0, M1
	la	$s1, M2
	la	$s2, M3
# n := 0;
	li	$s3,0
# REPEAT
repeat:
# M3[n] := M1[n] + M2[n]
	lw	$t0,0($s0)
	lw	$t1,0($s1)
	add	$t2,$t0,$t1
	sw	$t2,0($s2)
# n := n+1
	addi	$s3,$s3,1
# Incrementamos punteros
	addi	$s0,$s0,4
	addi	$s1,$s1,4
	addi	$s2,$s2,4
# UNTIL n = 1023
	li	$t3,1024
	bne	$s3,$t3,repeat
end_repeat:
# END
	li	$v0,10
	syscall
