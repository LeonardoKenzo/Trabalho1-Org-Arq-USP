	.data
	.align 2
first_wagon: #primeiro vagao locomotiva (12 bits)
	.word 1 #id - offset 0
	.byte 'L' #tipo (L = locomotiva, C = Combustivel, P = passageiro, M = Carga) - offset 4
	.space 3 #padding para alinhar o procimo campo
	.word 0 #ponteiro para o proximo vagao (0 = NULL) - offset 8
	
not_found: .asciz "\nVagao nao encontrado no trem.\n"
menu_msg:  .asciz "\n1 - Add inicio\n2 - Add final\n3 - Remover\n4 - Listar\n5 - Buscar\n6 - Sair\nOpcao: "
welcome:   .asciz "Bem-vindo ao jogo de trens!\n"

	.text
	.align 2
	.globl main
main:		
	la s0, first_wagon #endereco do primeiro vagao(s0)
	addi s1, zero, 1 #contador de vagoes do trem (s1)

	la a0, welcome # mensagem de boas-vindas
	addi a7, zero, 4
	ecall
	
menu_options: #loop para o usuario escolher os comandos

	la a0, menu_msg # imprime menu
	addi a7, zero, 4
	ecall

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
	add s2, zero, s0 #usa o registrador s2 como endereÃ§o do primeiro vagao
	
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
	add s2, zero, s0
find_last_wagon:
	beq t2, zero, last_wagon
	add t3, zero, s2
	lw s2, 8(t3) #ponteiro para o ultimo vagao
	addi t2, t2, -1 #decrementa o contador
	j find_last_wagon #loop para percorrer o trem
last_wagon: 
	sw t0, 8(s2) #o ultimo vagao aponta para o novo vagao
	
	j menu_options #volta para o menu de comandos
	
rem_wagon:
	addi a7, zero, 5 #le o ID do vagao que o usuario deseja remover
	ecall
	add t1, zero, a0          #t1 armazena o ID do vagão que vai ser removido

	lw t0, 0(s0)              #t0 = ID do primeiro vagao
	beq t1, t0, remove_not_found #nao pode remover o primeiro no (locomotiva)

	add t2, zero, s0          #representa o vagão anterior(primeiro vagao)
	lw t3, 8(s0)              #representa o vagão atual(segundo vagao)

remove_loop:
	beq t3, zero, remove_not_found #se chegou no fim da lista e nao encontrou
	lw t4, 0(t3) #carrega o ID do vagao atual
	beq t4, t1, remove_found 	#se encontrou o ID, remove
	add t2, zero, t3          #anterior = atual
	lw t3, 8(t3)              #atual = proximo
	j remove_loop

remove_found:
	lw t5, 8(t3)  #t5 = proximo do vagao atual
	sw t5, 8(t2) #faz o vagao anterior apontar para o proximo do atual
	j menu_options

remove_not_found:
	la a0, not_found #so printa que não foi encontrado
	addi a7, zero, 4
	ecall
	j menu_options

list_train:
	add t1, zero, s0 # t1 comeca apontando para o primeiro vagÃ£o
    
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
    
    	addi a0, zero, 10       # ASCII 10 Ã© o \n
    	addi a7, zero, 11
    	ecall
    
    	lw t1, 8(t1) # recebe o endereÃ§o do proximo vagao (offset 8)
    	j list_loop

search_wagon:
	addi a7, zero, 5
	ecall
	add t1, zero, a0 # Guaarda o ID que vamos procurar
	
	add t2, zero, s0 # Começar do primeiro vagao
	
search_loop:
	beq t2, zero, search_not_found # Pular para caso erro
	
	lw t3, 0(t2) # t3 recebe o ID do vagao atual
	beq t1, t3, search_found # Se o ID em t1 e t3 é igual, achamos
	
	lw t2, 8(t2) # t2 recebe o proximo vagao
	j search_loop
	
search_found:
	lw a0, 0(t2)
	addi a7, zero, 1
	ecall
	
	addi a0, zero, 32       # Espaço
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
	

	
	
	
	

	
