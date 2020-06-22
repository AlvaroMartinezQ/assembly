	.data
A:	.space	2048
X:	.space	2048

	.text
# Código 1
# for (i=0; i<2^9; i++) {
#   x[i] = a[i];
#   tmp = tmp + x[i];
# }
	la	$s0,A
	la	$s1,X
	li	$t0,0
	li	$t9,512
	li	$t3,0
for1:	bge	$t0,$t9,end_for1
	lw	$t1,0($s0)
	sw	$t1,0($s1)
	lw	$t2,0($s1)
	add	$t3,$t3,$t2
	addi	$s0,$s0,4
	addi	$s1,$s1,4
	addi	$t0,$t0,1
	b	for1
end_for1:
# Código 2:
# for (i=2^9-1; i>=0; i--) {
#    x[i] = i;
# }
	la	$s1,X
	addi	$s1,$s1,2044 # $s1 apunta al último elemento del vector
	li	$t0,511
	li	$t9,0
for2:	blt	$t0,$t9,end_for2
	sw	$t0,0($s1)
	addi	$s1,$s1,-4
	addi	$t0,$t0,-1
	b	for2
end_for2:

# END
	li	$v0,10
	syscall
