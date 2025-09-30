.data
	#atoiString: .asciiz "  -2147483648dasdds"


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
    
    li $v0, 0 # Resultado
    li $t9, 10
  

    START:
      lb $t1, 0($t0)
      li $t7, 32
      li $t8, 45
      addi $t0, $t0, 1
      beq $t1, $t7, START # En caso de encontrarse un espacio sigue recorriendo
      beq $t1, $t8, NEGATIVE # En caso de encontrarse un - marcar� el flag como -1
      li $t7, 43
      li $t2, 1
      beq $t1, $t7, POSITIVE
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
        

 
      slti $t6, $t1 ,48
      slti  $at, $t1 ,58
      
      bnez $t6, END
      beqz $at, END
      
      addi $t1, $t1, -48
      mul $v0, $v0, $t9
      mfhi $t3
      slt $at, $v0, $0
      bnez $t3, EXIT_ERROR_2
      #blt $v0, $0, COMPROBATE_EXIT_ERROR_2
      
      
      
      addu $v0, $v0, $t1
      
      bnez $at, COMPROBATE_EXIT_ERROR_2
      
      # blt $v0, $0, COMPROBATE_EXIT_ERROR_2
      slt $t6, $v0, $0
      
      
      lb $t1, 0($t0)
      bnez $t6, COMPROBATE_EXIT_ERROR_2
      
      addi $t0, $t0, 1
      
      j LECTURE
    END:
	  beq $v0, $zero, COMPROBATE_ERROR_1
      mul $v0, $v0, $t2
      li $v1, 0
      jr $ra
		COMPROBATE_ERROR_1:
			
			lb $t1, -2($t0)
			li $t7, 48
			li $v1, 0
      			bne $t1, $t7, EXIT_ERROR_1
      		
			jr $ra
  
  	EXIT_ERROR_1:
  		li $v1, 1
  		jr $ra

		COMPROBATE_EXIT_ERROR_2:
			li $t8, -2147483648
			li $t7, -1
			bne $v0, $t8, EXIT_ERROR_2
			bne $t2, $t7, EXIT_ERROR_2
			li $v1, 0
			jr $ra

		EXIT_ERROR_2:
			li $v1, 2
			jr $ra
