	.data
	.align 2
wagon_1: #primeiro vagao locomotiva (12 bits)
	.word 1 #id
	.byte 'L' #tipo (L = locomotiva, C = Combustivel, P = passageiro, M = Carga)
	.space 3 #padding para alinhar o procimo campo
	.word 0 #ponteiro para o proximo vagao (0 = NULL)
	
	.text
	.align 2
	.globl main
main:	

new_wagon: #funcao que cria um novo vagao	
	addi a7, zero, 9 #alocar 12 bits de memoria para cada novo vagao (dinamico)
	addi a0, zero, 12
	ecall
	
	add t0, a0, zero #t0 agora tem o vagao 1
	
	

	