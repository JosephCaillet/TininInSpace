ST7/

;************************************************************************
; TITLE:                
; AUTHOR:               
; DESCRIPTION:          
;************************************************************************

	TITLE "time.ASM"
	
	MOTOROLA
	
	#include "ST7Lite2.INC"


;************************************************************************
;
;  ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************
	
	PUBLIC wait1ms
	PUBLIC wait2ms
	PUBLIC wait500ms
	PUBLIC wait
	
	PUBLIC waitTime

;************************************************************************
;
;  ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************
	BYTES
	segment byte 'ram0'

waitTime DS.B 1

;************************************************************************
;
;  ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************
	WORDS
	segment byte 'rom'

;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************


;;;;;;;;;;;;;;;;;;;;;;;;
; temporisation de 1ms ;
;;;;;;;;;;;;;;;;;;;;;;;;

wait1ms:
	;Nloop_1ms	EQU	98	; nombre de boucle pour tempo de 1ms = 98 x Fcpu en MHz
	; 98 si fcpu = 1MHz; 74 si fcpu = 0,76MHz; 
	PUSH	X			; 3 cycles
	; nombre de boucle = Nloop_1ms
	LD		X,#98		; 2 cycles      
tempo10cyc:
	; boucle 10 cycles
	NOP					; 2 cycles
	NOP					; 2 cycles
	DEC 	X			; 3 cycles X = X-1
	JRNE	tempo10cyc ; 3 cycles si X <> 0 alors continue tempo
	POP		X			; 4 cycles
	RET ;= 6 cycles



;;;;;;;;;;;;;;;;;;;;;;;;
; temporisation de 2ms ;
;;;;;;;;;;;;;;;;;;;;;;;;

wait2ms:
	;Nloop_2ms	EQU	198	; nombre de boucle pour tempo de 2ms = 198 x Fcpu en MHz
	; 198 si fcpu = 1MHz; 150 si fcpu = 0,76MHz; 
	PUSH	X			; 3 cycles
	; nombre de boucle = Nloop_2ms
	LD		X,#198; 	2 cycles      
tempo10cyc2:
	; boucle 10 cycles
	NOP					; 2 cycles
	NOP					; 2 cycles
	DEC 	X			; 3 cycles X = X-1
	JRNE	tempo10cyc2 ; 3 cycles si X <> 0 alors continue tempo
	POP		X			; 4 cycles
	RET ;= 6 cycles



;;;;;;;;;;;;;;;;;;;;;;;;;;
; temporisation de 500ms ;
;;;;;;;;;;;;;;;;;;;;;;;;;;
wait500ms:
	PUSH X
	LD X,250
boucle_250_wait500ms:
	CALL wait2ms
	DEC X
	JRNE boucle_250_wait500ms
	POP X
	RET
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; temporisation de waitTime ms ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wait:
	PUSH X
	LD X,waitTime
boucle_waitTime_wait500ms:
	CALL wait1ms
	DEC X
	JRNE boucle_waitTime_wait500ms
	POP X
	RET


;************************************************************************

	END

;************************************************************************
