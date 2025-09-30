
.text

Parser:

	addi $sp, $sp, -40
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	sw $a0, 36($sp)

	addi $s0, $a0, -1
	move $s1, $0 # Valor que indica lo que toca hacer
	move $s2, $a1
	li $s3, ' '
	li $s4, '\t'
	li $s5, 1
	li $s6, 2
	li $s7, 3
	GAP_FORWARDS:
	
		
		lb $t1, 1($s0)
		addi $s0, $s0, 1
		
		beq $t1, $s3, GAP_FORWARDS
		beq $t1, $s4, GAP_FORWARDS
		beq $t1, $zero, ERROR_INVALID_SYNTAX
		
		beq $s1, $s5, PARAM
		beq $s1, $s6, KEY
		beq $s1, $s7, STRING

	COMMAND:	

		addi $s0, $s0, 1
		bne $t1, 'e', ERROR_INCORRECT_COMMAND
		
		lb $t3, 0($s0)
		
		addi $s0, $s0, 1
		lb $t1, 0($s0)
		
		lb $t2, 1($s0)
		
		bne $t3, 'n', ERROR_INCORRECT_COMMAND
		bne $t1, 'c', ERROR_INCORRECT_COMMAND
		
		addi $s1, $zero, 1
		
		beq $t2, $s3, GAP_FORWARDS
		beq $t2, $s4, GAP_FORWARDS
		
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

		beq $t2, $s3, COMPROBATE_PARAM3
		beq $t2, $s4, COMPROBATE_PARAM3
		
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
	beq $t1, $s3, GAP_FORWARDS
	beq $t1, $s4, GAP_FORWARDS
	beq $t1, $0, ERROR_INVALID_SYNTAX

  j MOVE_TO_STRING

STRING:
 	lb $t1, ($s0)
 		
 	addi $s0, $s0, 1
 		
 	sb $t1, 8($s2)
 	beq $t1, $zero, NO_ERRORS
 		
 	addi $s2, $s2, 1
 
 	j STRING

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
			lw $s3, 16($sp)
			lw $s4, 20($sp)
			lw $s5, 24($sp)
			lw $s6, 28($sp)
			lw $s7, 32($sp)
			lw $a0, 36($sp)
			addi $sp, $sp, 40
			
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
		li $t8, 48
		li $t7, 57
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
        
      blt $t1, $t8, END_ATOI
      bgt $t1, $t7, END_ATOI
      mul $v0, $v0, $t9
      mfhi $t3
      bnez $t3, EXIT_ERROR_2
      blt $v0, $0, COMPROBATE_EXIT_ERROR_2
      sub $t1, $t1, $t8
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
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $a0, 20($sp)
	sw $a1 24($sp)
	
	lb $t0, 8($a0)
	
	move $s0, $a0
	
	beq $t0, $0, EMPTY_STRING_ERROR

	
	move $s1, $a1
	
	
	
	lw $t0, 0($s0) # Cargo el valor conf_t.isDecode, si es 0 -> Encriptar | si no, desencriptar
	addi $s0, $s0, 4
	li $s2, 33 # Menor que 33 es caracter ilegal
	li $s3, 126 # Mayor que 126 es caracter ilegal
	bne $t0, $0, IS_DECODE_TRUE
	
	IS_DECODE_FALSE:
		lw $a1, 0($s0) # En $a1 guardo la key de encriptacion
		
		addi $s0, $s0, 4
		
		STRING_FORWARDS: # Sumo todos los valores de los caracteres ASCII
		
			
			lb $t0, 0($s0)
			
			addi $s0, $s0, 1
			addu $a1, $a1, $t0 # Suma sin desbordamiento para evitar el overflow cuando la clave es grande
			
			beq $t0, $0, GO_TO_ENCODING_STRING
			
			j STRING_FORWARDS
		
		GO_TO_ENCODING_STRING:
		
			li $t0, 128
			div $a1, $t0
			mfhi $a1
			
			bge $a1, $0, REST_POSITIVE
			
			add $a1, $a1, $t0
			
		REST_POSITIVE:
			ori $a1, $a1, 0x40 # 1000000
			
			
			sb $a1, 0($s1)
			addi $s1, $s1, 1
			
			addi $s0, $a0, 8
			addi $a1, $a1, -3
			
		ENCODING_STRING:
			
			lb $a0, 0($s0) # En $a0 la direccion del primer caracter
			
			addi $s0, $s0, 1
			addi $a1, $a1, 3
			
			beq $a0, $0, END_STRING_ENCODER
			
			blt $a0, $s2, ILLEGAL_CHAR_ERROR
			bgt $a0, $s3, ILLEGAL_CHAR_ERROR
			
			jal EncriptaChar
			
			sb $v0, 0($s1)
			
			addi $s1, $s1, 1
			
			
			j ENCODING_STRING
			
	
	IS_DECODE_TRUE:
		addi $s0, $s0, 4 # Me muevo a la direccion donde esta la cadena almacenada
		lb $a1, 0($s0)
		
		lb $t0, 1($s0)
		
		addi $s0, $s0, 1
		
		andi $a1, $a1, 0xBF # Desactivo el bit 6
		addi $a1, $a1, -3
		
		beq $t0, $0, EMPTY_STRING_ERROR
		
		DECODING_STRING:
			
			
			lb $a0, 0($s0)
			addi $s0, $s0, 1
			addi $a1, $a1, 3
			beq $a0, $0, END_STRING_ENCODER
			
			blt $a0, $s2, ILLEGAL_CHAR_ERROR
			bgt $a0, $s3, ILLEGAL_CHAR_ERROR
			
			jal DesencriptaChar
			
			sb $v0, 0($s1)
			addi $s1, $s1, 1
			
			j DECODING_STRING
			
		
EMPTY_STRING_ERROR:
	li $v0, 1
	j EXIT
	
ILLEGAL_CHAR_ERROR:
	li $v0, 2
	j EXIT

END_STRING_ENCODER:
	sb $a0, 0($s1)
	li $v0, 0
	
	EXIT:
		
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1 8($sp)
		lw $s2 12($sp)
		lw $s3 16($sp)
		lw $a0, 20($sp)
		lw $a1 24($sp)
		addi $sp, $sp, 28
		
		jr $ra


	Mi_Encoder:
		addi $sp, $sp, -16
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $a0, 8($sp)
		sw $a1, 12($sp)
		
		move $s0, $a1 # Guardo en $s0 la direccion de la cadena de salida
		
		jal Parser
		
		bne $v0, $0, MI_ENCODER_EXIT
		
		move $a0, $a1 # El objeto de conf a $a0
		move $a1, $s0 # Recupero la direccion de la cadena de salida
	
		jal Encriptador
		
		beq $v0, 1, MI_ENCODER_EMPTY_STRING_ERROR
		beq $v0, 2, MI_ENCODER_ILLEGAL_CHAR_ERROR
	
		j MI_ENCODER_NO_ERRORS
	
	MI_ENCODER_EMPTY_STRING_ERROR:
		li $v0, 5
		j MI_ENCODER_EXIT
	
	MI_ENCODER_ILLEGAL_CHAR_ERROR:
		li $v0, 6
		j MI_ENCODER_EXIT
	
	MI_ENCODER_NO_ERRORS:
		move $v0, $0
		
		MI_ENCODER_EXIT:
			lw $ra, 0($sp)
			lw $s0, 4($sp)
			lw $a0, 8($sp)
			lw $a1, 12($sp)
			addi $sp, $sp, 16
			
			jr $ra
			
			
