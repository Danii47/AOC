.text

# Parámetros:
# $a0: Dirección de la cadena que contiene el comando.
# $a1: Dirección de la cadena de salida.
# 
# Retorno:
# $v0: Código de error.
# 
# Códigos de error:
# 0: Operación realizada correctamente.
# 1: Comando incorrecto (no es "enc").
# 2: Error de sintaxis.
# 3: Carácter incorrecto en clave.
# 4: Overflow en clave.
# 5: No hay cadena a descodificar.
# 6: Carácter ilegal en cadena a encriptar/desencriptar 
#    (espacios, caracteres de control o ASCII > 126).

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
	
	
	Parser:
		li $v0, 0
		jr $ra
	
	Encriptador:
		li $v0, 0
		jr $ra
	
	
		