.data
	# itoaString: .space 100

.text
	# main:
	
		# li $a0, -2147483648
		# li $a1, 0
		# la $a2, itoaString
		
		# jal itoa
		
		# li $v0, 10
		# syscall
		
		itoa:
			# // --- LEYENDA REGISTROS --- \\ #
			# $t0 -> Número a convertir
			# $t1 -> Dirección del String destino
			# $t2 -> Flag de signo, si es mayor que 0 es negativo el número
			# $a1 -> Forma de interpretar
			
			move $t0, $a0
			move $t1, $a2
			li $t2, 0
			li $t3, 45 # Signo menos
			li $t4, 10 # Valor por el que se dividirá el número
			li $t9, 0
			
			
			
		
			
			
			beq $a1, $zero, SIGN_32
			li $t5, 2
			li $t6, 3
			beq $a1, $t5, SIGN_16
			beq $a1, $t6, TRUNK_16
			li $t7, 4
			li $t8, 5
			beq $a1, $t7, SIGN_8
			beq $a1, $t8, TRUNK_8
			
			START_DIVISION_LOOP:
				move $t5, $t1 # Guardo en $t4 el puntero a donde inicia el bucle
			
			DIVISION_LOOP:
				divu $t0, $t0, $t4
				mfhi $t6 # En t5 se guarda el número de más a la izquierda
				addi $t6, $t6, 48 # El entero 48 es 0 en ASCII, por lo que se transforma de INT a ASCII
				sb $t6, 0($t1)
				addi $t1, $t1, 1
				bne $t0, $zero, DIVISION_LOOP # Si el cociente de dividir el número entre 10 es 0, significa que se acabo el número
				
				sb $t9, 0($t1)
				addi $t1, $t1, -1
				
			END_INT_LOOP:
				# Ahora, al tenerlo guardado al revés, hace falta dar la vuelta el número
				# Para ello, está almacenado en $t5 el puntero inicial de la cadena y en $t1 el puntero final
				# Se pueden alternar primer valor con ultimo, segundo con penultimo y así sucesivamente
				addi $t5, $t5, 1
				addi $t1, $t1, -1
				slt $at , $t5, $t1 # Si el puntero del inicio de la cadena es menor que el del final, sigue dando la vuelta a los números
				
				lb $t7, -1($t5) # Primer número del String
				lb $t8, 1($t1) # Último número del String
				sb $t7, 1($t1) # El primer número se guarda en el final del String
				sb $t8, -1($t5) # El último número se guarda al inicio del String
				
				bne $at, $zero , END_INT_LOOP
				
				jr $ra


			SIGN_32:
				li $at , -2147483648
				andi $t2, $t0, 0x80000000 # Número con todo ceros excepto el bit 16 en 1, para comprobar el signo
				beq $t0, $at, ADD_SIGN_32 # El caso de -2147483648 es un caso especial y no se le hace el CA2 ya que si no hace overflow
				
				beq $t2, $zero, START_DIVISION_LOOP
				
				# En caso de ser negativo, se hace el CA2
				addi $t0, $t0, -1
				nor $t0, $t0, $zero
				ADD_SIGN_32:
					sb $t3, 0($t1)
					addi $t1, $t1, 1
					j START_DIVISION_LOOP
			
			SIGN_16:
				andi $t2, $t0, 0x8000 # Número con todo ceros excepto el bit 16 en 1, para comprobar el signo
				beq $t2, $zero, TRUNK_16
				
				# En caso de ser negativo, se hace el CA2
				addi $t0, $t0, -1
				nor $t0, $t0, $zero
				
				# Añade el signo en el String
				sb $t3, 0($t1)
				addi $t1, $t1, 1
			
				TRUNK_16:
					andi $t0, $t0, 0xFFFF # Se trunca el número a 16 bits
					j START_DIVISION_LOOP
					
			
			SIGN_8:
				andi $t2, $t0, 0x80 # Número con todo ceros excepto el bit 8 en 1, para comprobar el signo
				beq $t2, $zero, TRUNK_8
				
				# En caso de ser negativo, se hace el CA2

				addi $t0, $t0, -1
				nor $t0, $t0, $zero
				
				# Añade el signo en el String
				sb $t3, 0($t1)
				addi $t1, $t1, 1
				
				TRUNK_8:
					andi $t0, $t0, 0xFF # Se trunca el número a 8 bits
					j START_DIVISION_LOOP
				
				
