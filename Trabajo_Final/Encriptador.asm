Encriptador:
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $a0, 16($sp)
	sw $a1 20($sp)
	
	lb $t0, 8($a0)
	beq $t0, $0, EMPTY_STRING_ERROR

	move $s0, $a0
	move $s1, $a1
	
	lw $t0, 0($s0) # Cargo el valor conf_t.isDecode, si es 0 -> Encriptar | si no, desencriptar
	addi $s0, $s0, 4
	bne $t0, $0, IS_DECODE_TRUE
	
	IS_DECODE_FALSE:
		lw $a1, 0($s0) # En $a1 guardo la key de encriptacion
		
		addi $s0, $s0, 3
		
		STRING_FORWARDS: # Sumo todos los valores de los caracteres ASCII
		
			addi $s0, $s0, 1
			lb $t0, 0($s0)
			
			beq $t0, $0, GO_TO_ENCODING_STRING
			
			addu $a1, $a1, $t0 # Suma sin desbordamiento para evitar el overflow cuando la clave es grande
			
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
			
			addi $s0, $a0, 7
			
		ENCODING_STRING:
			addi $s0, $s0, 1
			lb $a0, 0($s0) # En $a0 la direccion del primer caracter
			
			beq $a0, $0, END_STRING_ENCODER
			
			blt $a0, 33, ILLEGAL_CHAR_ERROR
			bgt $a0, 126, ILLEGAL_CHAR_ERROR
			
			jal EncriptaChar
			
			sb $v0, 0($s1)
			
			addi $s1, $s1, 1
			addi $a1, $a1, 3
			
			j ENCODING_STRING
			
	
	IS_DECODE_TRUE:
		addi $s0, $s0, 4 # Me muevo a la direccion donde esta la cadena almacenada
		lb $a1, 0($s0)
		
		lb $t0, 1($s0)
		andi $a1, $a1, 0xBF
		beq $t0, $0, EMPTY_STRING_ERROR
		
		DECODING_STRING:
			addi $s0, $s0, 1
			
			lb $a0, 0($s0)
			
			beq $a0, $0, END_STRING_ENCODER
			
			blt $a0, 33, ILLEGAL_CHAR_ERROR
			bgt $a0, 126, ILLEGAL_CHAR_ERROR
			
			jal DesencriptaChar
			
			sb $v0, 0($s1)
			addi $s1, $s1, 1
			addi $a1, $a1, 3
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
		lw $a0, 16($sp)
		lw $a1 20($sp)
		addi $sp, $sp, 24
		
		jr $ra


Parser:
	li $v0, 0
	jr $ra
	
Mi_Encoder:
	li $v0, 0
	jr $ra