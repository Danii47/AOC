.text

Parser:

	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1 8($sp)
	sw $s2, 12($sp)
	sw $a0, 16($sp)

	
	addi $s0, $a0, -1
	move $s1, $0 # Valor que indica lo que toca hacer
	move $s2, $a1
	
	GAP_FORWARDS:
	
		addi $s0, $s0, 1
		lb $t1 0($s0)

		beq $t1, ' ', GAP_FORWARDS
		beq $t1, '\t', GAP_FORWARDS
		
		beq $t1, $zero, ERROR_INVALID_SYNTAX
		
		beq $s1, 1, PARAM
		beq $s1, 2, KEY
		beq $s1, 3, STRING

	COMMAND:	
		# lb $t1 0($s0)
		
		addi $s0, $s0, 1
		bne $t1, 'e', ERROR_INCORRECT_COMMAND
		
		lb $at, 0($s0)
		
		addi $s0, $s0, 1
		lb $t1, 0($s0)
		
		lb $t2, 1($s0)
		
		bne $at, 'n', ERROR_INCORRECT_COMMAND
		bne $t1, 'c', ERROR_INCORRECT_COMMAND
		
		addi $s1, $zero, 1
		
		beq $t2, ' ', GAP_FORWARDS
		beq $t2, '\t', GAP_FORWARDS
		
		beq $t2, $zero, ERROR_INVALID_SYNTAX
		
		j ERROR_INCORRECT_COMMAND

PARAM:
		beq $t1, '-', COMPROBATE_PARAM
		
		addi $s0, $s0, -1
		
		j CASE_C
		

COMPROBATE_PARAM:
		
		addi $s0, $s0, 1
		lb $t1 0($s0)
		beq $t1, '-', COMPROBATE_PARAM2
		
		addi $s0, $s0, -2
		
		j CASE_C


COMPROBATE_PARAM2:
	
		addi $s0, $s0, 1
		lb $t2 1($s0)
		lb $t1 0($s0)

		beq $t2, ' ', COMPROBATE_PARAM3
		beq $t2, '\t', COMPROBATE_PARAM3
		
		j ERROR_INVALID_SYNTAX
COMPROBATE_PARAM3:
		
		beq $t1, 'c', CASE_C
		beq $t1, 'd', CASE_D
		
		j ERROR_INVALID_SYNTAX

CASE_C:
	sw $zero, ($a1) #config.isDecode = 0
	li $s1, 2 #cargamos codigo de clave
	
	j GAP_FORWARDS		

CASE_D:
	li $at, 1
	sw $at, ($a1) #config.isDecode != 0
	
	li $at, 1
	sw $at, 4($a1) #config.key 
	
	li $s1, 3 #cargamos codigo de cadena
	
	j GAP_FORWARDS
	
KEY: 
 move $a0, $s0
 
 jal atoi

 beq $v1, 1, ERROR_INVALID_CHARACTER_IN_KEY
 beq $v1, 2, ERROR_OVERFLOW_IN_KEY

 sw $v0, 4($s2)
 li $s1, 3 #cargamos codigo de cadena
 
MOVE_TO_STRING:
	addi $s0, $s0, 1
	lb $t1 0($s0)
	beq $t1, ' ', GAP_FORWARDS
	beq $t1, '\t', GAP_FORWARDS
	beq $t1, $0, ERROR_INVALID_SYNTAX

  j MOVE_TO_STRING

STRING:
	add $t3, $zero, $zero
	STRING_LOOP:
 		lb $t1, ($s0)
 
 		sb $t1, 8($s2)
 		beq $t1, $zero, NO_ERRORS
 		
 		addi $s0, $s0, 1
 		addi $s2, $s2, 1
 		addi $t3, $t3, 1
 
 		bgt $t3, 1000, ERROR_INVALID_SYNTAX
 
 		j STRING_LOOP

ERROR_INCORRECT_COMMAND:
		addi $v0, $zero, 1
		j END

ERROR_INVALID_SYNTAX:
		addi $v0, $zero, 2
		j END

ERROR_INVALID_CHARACTER_IN_KEY:
		addi $v0, $zero, 3
		j END

ERROR_OVERFLOW_IN_KEY:
		addi $v0, $zero, 4
		j END 

NO_ERRORS: 
		move $v0, $0

		END:
			lw $ra, 0($sp)
			lw $s0, 4($sp)
			lw $s1 8($sp)
			lw $s2, 12($sp)
			lw $a0, 16($sp)
			addi $sp, $sp, 20
			
			jr $ra

atoi:
  	### LEYENDA REGISTROS ###
		# $t0 -> Direccion del String recorrido
		# $t1 -> Almacena cada byte del String (caracteres)
		# $t2 -> Flag de signo puede ser 1 o -1, ya que al final el n mero se multiplicar  por ese valor 

    # a0 cadena
    # v0 resultado
    # v1 errores
  
    add $t0, $zero, $a0
    
    li $v0, 0 # Resultado
    li $v1, 0
    li $t9, 10

    START:
      lb $t1, 0($t0)
      addi $t0, $t0, 1
      beq $t1, $zero, END_ATOI
      beq $t1, 32, START # En caso de encontrarse un espacio sigue recorriendo
      beq	$t1, 45, NEGATIVE # En caso de encontrarse un - marcara el flag como -1
      li $t2, 1
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
        
      blt $t1, 48, END_ATOI
      bgt $t1, 57, END_ATOI
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
    END_ATOI:
			beq $v0, 0, COMPROBATE_ERROR_1
      beq $t1, ' ', EXIT_ATOI
      beq $t1, '\t', EXIT_ATOI
      beq $t1, $zero, EXIT_ATOI
 			j EXIT_ERROR_1
 
    EXIT_ATOI:
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
Encriptador:
li $v0, 0
jr $ra

Mi_Encoder:
li $v0, 0
jr $ra	
