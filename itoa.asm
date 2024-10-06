.data


.text

    ### LEYENDA REGISTROS ###
		# $t0 -> Número a convertir a String
		# $a1 -> Forma de interpretar el número
    # - 0: 32 bits complemento a 2 (int)
    # - 1: 32 bits binario natural (unsigned int)
    # - 2: 16 bits complemento a 2 (short)
    # - 3: 16 bits binario natural (unsigned short)
    # - 4: 8 bits complemento a 2 (char)
    # - 5: 8 bits binario natural (unsigned char)
		# $t1 -> Dirección de memoria donde se guardará el string


  itoa:
    move $t0, $a0
    move $t1, $a2
    li $t2, 10

    beq $a1, 0, CASE0
    beq $a1, 1, CASE1

    CASE0:

      bgez $t0, CASE0_POSITIVE
 
      li $t3, -1

      CASE0_POSITIVE:
        li $t3, 1
    

    
    CASE1:

    FOR:
      divu $t0, $t0, $t2
      mfhi $t3 # Resto
      addi $t3, $t3, 48 # Convertir a ASCII
      sb $t3, 0($t1) # Guardar en memoria
      addi $t1, $t1, 1 # Incrementar dirección de memoria
      bnez $t0, FOR # Si no es 0, seguir dividiendo