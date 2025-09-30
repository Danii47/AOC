.text
                
#Cuenta las letras mayúsculas que contiene una cadena de caracteres
#Entrada
#	a0 --> puntero a cadena
#Salida
#	v0 --> número de letras mayúsuculas                                         

CuentaMayus: 	
	lb $t0, 0($a0)
	li $v0, 0
LoopMayus:
	slti $t2, $t0, 'A'
	slti $t3, $t0, 91 # 91 es Z + 1, ya que la Z también debe estar en el rango
	
	beq $t0, $zero, endMayus	
	
	bne $t2, $zero, continua
	beq $t3, $zero, continua	
	
	addi $v0, $v0, 1
continua: 
	
	lb $t0, 1($a0)
	addi $a0, $a0, 1
	j LoopMayus			
endMayus:
 	jr $ra
		

#Obtiene la matriz traspuesta de una matriz dada
#a0 --> puntero a matrix enteros NxM A
#a1 --> puntero a matrix enteros MxM B
#a2 --> N
#a3 --> M

MatTraspose:

	li $t0, 0   	#i
_loopI: 
_loopJ: #calculamos dirección a[i][j]
	#calculamos dirección b[j][i]
	mul $t2, $t0, $a3      	#i*M
	mul $t6, $t1, $a2      	#j*N
	

	
	add $t2, $t2, $t1	#i*M+j
	add $t6, $t6, $t0	#j*N+i
	
	sll $t2, $t2, 2		#(i*M+j)*4
	sll $t6, $t6, 2		#(j*N+i)*4
	
	
	
	add $t3, $t2, $a0	# A + (i*M+j)*4
	add $t4, $t6, $a1	# B + (j*N+i)*4
	
	
	

	
	#Cargamos y guardamos el dato
	lw $t5, 0($t3)
	addi $t1, $t1, 1	#j++
	sw $t5, 0($t4)
	
	
	bne $t1, $a3, _loopJ
	addi $t0, $t0, 1
	li $t1, 0	#j
	bne $t0, $a2, _loopI
	jr $ra
