	.data
	.align 2
first_wagon: #primeiro vagao locomotiva (12 bits)
	.word 1 #id - offset 0
	.byte 'L' #tipo (L = locomotiva, C = Combustivel, P = passageiro, M = Carga) - offset 4
	.space 3 #padding para alinhar o procimo campo
	.word 0 #ponteiro para o proximo vagao (0 = NULL) - offset 8
	
not_found: .asciz "\nVagao nao encontrado no trem.\n"

	.text
	.align 2
	.globl main
main:		
	la s0, first_wagon #endereco do primeiro vagao(s0)
	addi s1, zero, 1 #contador de vagoes do trem (s1)
	
menu_options: #loop para o usuario escolher os comandos
	addi a7, zero, 5 #le o input para selecionar o comando
	ecall
	add t1, zero, a0 #comando selecionado(t1)
	
	#switch de comandos
	addi t0, zero, 1
	beq t1, t0, add_start
	addi t0, zero, 2
	beq t1, t0, add_final
	addi t0, zero, 3
	beq t1, t0, rem_wagon
	addi t0, zero, 4
	beq t1, t0, list_train
	addi t0, zero, 5
	beq t1, t0, search_wagon
	addi t0, zero, 6
	beq t1, t0, exit
	
	j menu_options #se nao colocou a opcao de sair(6), volta ao menu de comandos
	
add_start:
	add s2, zero, s0 #usa o registrador s2 como endereço do primeiro vagao
	
	addi a7, zero, 9 #alocar 12 bits de memoria para cada novo vagao (dinamico)
	addi a0, zero, 12
	ecall
	
	add t0, zero, a0 #t0 agora tem o novo vagao sem valores nos campos

	addi s1, s1, 1 #incremente o contador de vagoes do trem
	sw s1, 0(t0) #guarda o id do novo vagao
	
	addi a7, zero, 12 #le o tipo do novo vagao
	ecall
	add t1, zero, a0 
	sb t1, 4(t0) #guarda o tipo do novo vagao
	
	sw s2, 8(t0) #guarda o endereco do proximo vagao
	add s0, zero, t0 #endereco do novo primeiro vagao
	
	j menu_options #volta para o menu de comandos
	
add_final:
	addi a7, zero, 9 #alocar 12 bits de memoria para cada novo vagao (dinamico)
	addi a0, zero, 12
	ecall
	
	add t0, zero, a0 #t0 agora tem o novo vagao sem valores nos campos

	addi s1, s1, 1 #incremente o contador de vagoes do trem
	sw s1, 0(t0) #guarda o id do novo vagao
	
	addi a7, zero, 12 #le o tipo do novo vagao
	ecall
	add t1, zero, a0 
	sb t1, 4(t0) #guarda o tipo do novo vagao
	
	sw zero, 8(t0) #coloca NULL noo ponteiro do vagao
	
	#percorrer todo o trem ate o ultimo vagao
	addi t2, s1, -1 
	add s2, zero, s0 #coloca o ponteiro do primeiro vagao da lista em s2
find_last_wagon:
	beq t2, zero, last_wagon #se o contador chega ao fim, indica que e o ultimo vagao
	add t3, zero, s2
	lw s2, 8(t3) #ponteiro para o ultimo vagao
	addi t2, t2, -1 #decrementa o contador
	j find_last_wagon #loop para percorrer o trem
last_wagon: 
	sw t0, 8(s2) #o ultimo vagao aponta para o novo vagao
	
	j menu_options #volta para o menu de comandos
	
rem_wagon:

list_train:
	add t1, zero, s0 # t1 comeca apontando para o primeiro vagão
    
list_loop:
    	beq t1, zero, menu_options # se t1 for NULL, o trem acabou e voltamos ao menus
    
    	lw a0, 0(t1) # carrega o ID (offset 0)
    	addi a7, zero, 1 # 1 imprime int
    	ecall
    
    	addi a0, zero, 32 #ASCII para espaco
    	addi a7, zero, 11 # 11 imprime char
    	ecall
    
    	lbu a0, 4(t1) # carrega o caractere (offset 4)
    	addi a7, zero, 11 # 11 imprime char
    	ecall
    
    	addi a0, zero, 10       # ASCII 10 é o \n
    	addi a7, zero, 11
    	ecall
    
    	lw t1, 8(t1) # recebe o endereço do proximo vagao (offset 8)
    	j list_loop

search_wagon:
	add1 a7, zero, 5
	ecall
	add t1, zero, a0 # Guaarda o ID que vamos procurar
	
	add t2, zero, s0 # Come�ar do primeiro vagao
	
search_loop:
	beq t2, zero, search_not_found # Pular para caso erro
	
	lw t3, 0(t2) # t3 recebe o ID do vagao atual
	beq t1, t3, search_found # Se o ID em t1 e t3 � igual, achamos
	
	lw t2, 8(t2) # t3 recebe o proximo vagao
	j search_loop
	
search_found:
	lw a0, 0(t2)
	addi a7, zero, 1
	ecall
	
	addi a0, zero, 32       # Espa�o
    	addi a7, zero, 11
    	ecall
	
	lbu a0, 4(t0)           # Tipo
    	addi a7, zero, 11
    	ecall
    	
    	addi a0, zero, 10       # Nova linha
    	addi a7, zero, 11
    	ecall
    	j menu_options
    
search_not_found:
	la a0, not_found
	addi a7, zero, 4        # Syscall 4: Imprimir String
    	ecall
    	j menu_options
	
exit:
	# encerra o programa
	addi a7, zero, 10
	ecall
	

	
	
	
	

	
