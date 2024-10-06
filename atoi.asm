.data
	#atoiString: .asciiz "+0"


.text
	#main:
		#la $a0, atoiString
		#jal atoi
		
		#li $v0, 10
		#syscall

  atoi:
  	### LEYENDA REGISTROS ###
		# $t0 -> Direccion del String recorrido
		# $t1 -> Almacena cada byte del String (caracteres)
		# $t2 -> Flag de signo puede ser 1 o -1, ya que al final el n�mero se multiplicar� por ese valor 
  
    add $t0, $zero, $a0
    li $t2, 1
    li $v0, 0 # Resultado
    li $v1, 0
    li $t9, 10

    START:
      lb $t1, 0($t0)
      addi $t0, $t0, 1
      beq $t1, $zero, END
      beq $t1, 32, START # En caso de encontrarse un espacio sigue recorriendo
      beq	$t1, 45, NEGATIVE # En caso de encontrarse un - marcar� el flag como -1
      beq $t1, 43, POSITIVE
      j LECTURE
    
    POSITIVE:
    	lb $t1, 0($t0)
    	addi $t0, $t0, 1
    	j LECTURE
    NEGATIVE:
      li $t2, -1
      lb $t1, 0($t0)
      addi $t0, $t0, 1
    LECTURE:
        
      blt $t1, 48, END
      bgt $t1, 57, END
      mul $v0, $v0, $t9
      mfhi $t3
      bnez $t3, EXIT_ERROR_2
      blt $v0, $0, COMPROBATE_EXIT_ERROR_2
      addi $t1, $t1, -48
      addu $v0, $v0, $t1
      blt $v0, $0, COMPROBATE_EXIT_ERROR_2
      lb $t1, 0($t0)
      addi $t0, $t0, 1
      
      j LECTURE
    END:
			beq $v0, 0, COMPROBATE_ERROR_1
      mul $v0, $v0, $t2
      jr $ra
		COMPROBATE_ERROR_1:
			addi $t0, $t0, -2
			lb $t1, 0($t0)
			blt $t1, 48, EXIT_ERROR_1
      bgt $t1, 57, EXIT_ERROR_1
			jr $ra
  
  	EXIT_ERROR_1:
  		li $v1, 1
  		jr $ra

		COMPROBATE_EXIT_ERROR_2:
			bne $v0, -2147483648, EXIT_ERROR_2
			bne $t2, -1, EXIT_ERROR_2
			jr $ra

		EXIT_ERROR_2:
			li $v1, 2
			jr $ra
