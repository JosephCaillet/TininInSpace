ST7/

;************************************************************************
; TITLE:                
; AUTHOR:               
; DESCRIPTION:          
;************************************************************************

	TITLE "screen_lib.ASM"
	
	MOTOROLA
	
	#include "ST7Lite2.INC"
	#include "time.INC"


;************************************************************************
;
;  ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************
	PUBLIC	initTFT
	
	
	
DELAY EQU $80


INITR_GREENTAB EQU $0
INITR_REDTAB   EQU $1
INITR_BLACKTAB   EQU $2
INITR_18GREENTAB    EQU INITR_GREENTAB
INITR_18REDTAB      EQU INITR_REDTAB
INITR_18BLACKTAB    EQU INITR_BLACKTAB
INITR_144GREENTAB   EQU $1
ST7735_TFTWIDTH  EQU 128		;// Width TFT display 
ST7735_TFTHEIGHT_18  EQU 160	;// Heigt TFT 1.8" display
ST7735_NOP     EQU  $00
ST7735_SWRESET EQU  $01
ST7735_RDDID   EQU  $04
ST7735_RDDST   EQU  $09

ST7735_SLPIN   EQU  $10
ST7735_SLPOUT  EQU  $11
ST7735_PTLON   EQU  $12
ST7735_NORON   EQU  $13

ST7735_INVOFF  EQU  $20
ST7735_INVON   EQU  $21
ST7735_DISPOFF EQU  $28
ST7735_DISPON  EQU  $29
ST7735_CASET   EQU  $2A
ST7735_RASET   EQU  $2B
ST7735_RAMWR   EQU  $2C
ST7735_RAMRD   EQU  $2E

ST7735_PTLAR   EQU  $30
ST7735_COLMOD  EQU  $3A
ST7735_MADCTL  EQU  $36

ST7735_FRMCTR1 EQU  $B1
ST7735_FRMCTR2 EQU  $B2
ST7735_FRMCTR3 EQU  $B3
ST7735_INVCTR  EQU  $B4
ST7735_DISSET5 EQU  $B6

ST7735_PWCTR1  EQU  $C0
ST7735_PWCTR2  EQU  $C1
ST7735_PWCTR3  EQU  $C2
ST7735_PWCTR4  EQU  $C3
ST7735_PWCTR5  EQU  $C4
ST7735_VMCTR1  EQU  $C5

ST7735_RDID1   EQU  $DA
ST7735_RDID2   EQU  $DB
ST7735_RDID3   EQU  $DC
ST7735_RDID4   EQU  $DD

ST7735_PWCTR6  EQU  $FC

ST7735_GMCTRP1 EQU  $E0
ST7735_GMCTRN1 EQU  $E1

	;EXTERN wait500ms
	;EXTERN wait

	EXTERN waitTime.B
;************************************************************************
;
;  ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************
	BYTES
	segment byte 'ram0'

var	DS.B	1	;fourre tout pour contrer limitation mode d'adressage

dataout	DS.B	1;p write*
temp	DS.B	1

;commandList
addr	DS.B	1; p
numCmd	DS.B	1
numArg	DS.B	1
ms	DS.B	1;

;setAdrWindow & drawpixel
x0win	DS.B	1;p
y0win	DS.B	1;p
x1win	DS.B	1;p
y1win	DS.B	1;p

;drawrect
colorMSB	DS.B	1;p
colorLSB	DS.B	1;p
width	DS.B 1;p
height	DS.B 1;p

;************************************************************************
;
;  ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************
	WORDS
	segment byte 'rom'
	

	
Rcmd1	DC.B   15,
	DC.B   ST7735_SWRESET,   DELAY,
	DC.B     150,
	DC.B   ST7735_SLPOUT ,   DELAY,
	DC.B     255,
	DC.B   ST7735_FRMCTR1, 3  ,
	DC.B     $01, $2C, $2D,
	DC.B   ST7735_FRMCTR2, 3  ,
	DC.B     $01, $2C, $2D,
	DC.B   ST7735_FRMCTR3, 6  ,
	DC.B     $01, $2C, $2D,
	DC.B     $01, $2C, $2D,
	DC.B   ST7735_INVCTR , 1  ,
	DC.B     $07,
	DC.B   ST7735_PWCTR1 , 3  ,
	DC.B     $A2,
	DC.B     $02,
	DC.B     $84,
	DC.B   ST7735_PWCTR2 , 1  ,
	DC.B     $C5,
	DC.B   ST7735_PWCTR3 , 2  ,
	DC.B     $0A,
	DC.B     $00,
	DC.B   ST7735_PWCTR4 , 2  ,
	DC.B     $8A,
	DC.B     $2A,
	DC.B   ST7735_PWCTR5 , 2  ,
	DC.B     $8A, $EE,
	DC.B   ST7735_VMCTR1 , 1  ,
	DC.B     $0E,
	DC.B   ST7735_INVOFF , 0  ,
	DC.B   ST7735_MADCTL , 1  ,
	DC.B     $C8,
	DC.B   ST7735_COLMOD , 1  ,
	DC.B     $05
	
	
Rcmd2red DC.B 2,
	DC.B    ST7735_CASET  , 4
	DC.B      $00, $00,
	DC.B      $00, $7F,
	DC.B    ST7735_RASET  , 4
	DC.B      $00, $00,
	DC.B      $00, $9F


Rcmd3 DC.B 4,       
	DC.B    ST7735_GMCTRP1, 16      ,
	DC.B      $02, $1c, $07, $12,
	DC.B      $37, $32, $29, $2d,
	DC.B      $29, $25, $2B, $39,
	DC.B      $00, $01, $03, $10,
	DC.B    ST7735_GMCTRN1, 16      ,
	DC.B      $03, $1d, $07, $06,
	DC.B      $2E, $2C, $29, $2D,
	DC.B      $2E, $2E, $37, $3F,
	DC.B      $00, $00, $02, $10,
	DC.B    ST7735_NORON  ,    DELAY,
	DC.B      10,                    
	DC.B    ST7735_DISPON ,    DELAY,
	DC.B      100
;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'et' bit à bit et complement a un ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MandComp MACRO dest mask
	;PUSH	X
	;PUSH	A
	LD	X,mask
	CPL	X
	LD	var,X
	LD	A,dest
	AND	A,var
	LD	dest,A
	;POP A
	;POP X
	MEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'or' bit à bit ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mor MACRO dest src
	;PUSH X
	;PUSH A
	LD	A,dest
	OR	A,src
	LD	dest,A
	;POP A
	;POP X
	MEND


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'and' bit à bit ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mand MACRO dest src
	;PUSH X
	;PUSH A
	LD	A,dest
	AND	A,src
	LD	dest,A
	;POP A
	;POP X
	MEND
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; envoi de donnees sur port spi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;p: dataout
;u: temp
writeSPI:
	PUSH A
	LD	A,dataout
	LD	SPIDR,A
boucle_wait_spi:
	LD	A,SPISR
	AND A,#128
	CP	A,#0
	JREQ boucle_wait_spi
	LD	A,SPISR
	LD	temp,A
	LD	A,SPIDR
	LD	temp,A
	POP A
	RET



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; envoi de cmd sur port spi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;p: dataout
writeCmd:
	PUSH	A 
	MandComp PBDR, #$04
	MandComp PBDR, #$20
	CALL writeSPI
	Mor PBDR, #$20
	POP A
	RET



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; envoi de data sur port spi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;p: dataout
writeData:
	PUSH	A 
	Mor PBDR, #$04
	MandComp PBDR, #$20
	CALL writeSPI
	Mor PBDR, #$20
	POP A
	RET



;;;;;;;;;;;;;;;;;;;;;;;;
; execute liste de cmd ;
;;;;;;;;;;;;;;;;;;;;;;;;

;partie faisant la lecture depuis la bonne source indiquee par Y
read_src:
	CP	Y,#1
	JREQ	read_from_rcmd1
	CP	Y,#2
	JREQ	read_from_rcmd2
	CP	Y,#3
	JREQ	read_from_rcmd3
read_from_rcmd1:
	LD	A,(Rcmd1,X)
	INC	X
	RET
read_from_rcmd2:
	LD	A,(Rcmd2red,X)
	INC	X
	RET
read_from_rcmd3:
	LD	A,(Rcmd3,X)
	INC	X
	RET

;plusieur point d'entree pour le meme sous programme, afin de choisir la bonne source
cmdList1:
	PUSH	Y
	PUSH	X
	PUSH	A
	
	LD Y,#1
	CLR	X
	LD	A,(Rcmd1,X)
	LD	numCmd,A
	INC	X
	JP while_num_cmd

cmdList2:
	PUSH	Y
	PUSH	X
	PUSH	A
	
	LD Y,#2
	CLR	X
	LD	A,(Rcmd2red,X)
	LD	numCmd,A
	INC	X
	JP while_num_cmd

cmdList3:
	PUSH	Y
	PUSH	X
	PUSH	A
	
	LD Y,#3
	CLR	X
	LD	A,(Rcmd3,X)
	LD	numCmd,A
	INC	X
	JP while_num_cmd

while_num_cmd:
	;for each cmd
	DEC	numCmd
	JREQ end_while_num_cmd
	
	CALL read_src	;write cmd
	LD	dataout,A
	CALL writeCmd
	
	CALL read_src	;numARg=
	LD	numArg,A
	
	;LD A,numArg	;ms =
	ADD	A,#DELAY
	LD	ms,A
	
	MandComp numArg, #DELAY	;numArg&=
	
while_num_arg:
	DEC	numArg
	JREQ	end_while_num_arg
	
	CALL read_src	;write cmd
	LD	dataout,A
	CALL writeData
	JP while_num_arg
end_while_num_arg:
	
	LD	A,ms
	CP	A,#0
	JREQ while_num_cmd
	
	CALL read_src
	LD	ms,A
	
	;LD A,ms
	CP	A,#255
	JRNE skip_ms_eq_255
	CALL wait500ms
	JP while_num_cmd
	
skip_ms_eq_255:
	LD	ms,A
	LD	A,waitTime
	CALL	wait
	JP while_num_cmd
	
end_while_num_cmd:
	POP	A
	POP	X
	POP	Y
	RET

;;;;;;;;;;;;;;;;;;;;;;;;
; initialisation ecran ;
;;;;;;;;;;;;;;;;;;;;;;;;
initTFT:
	PUSH A
	
	Mor	PBDR, #$10
	;MandComp	PBDR, $20
	Mand	PBDR, #$DF
	CALL wait500ms
	
	;MandComp	PBDR, $10
	Mand	PBDR, #$EF
	CALL wait500ms
	
	Mor PBDR, #$10
	CALL wait500ms
	
	Mor	PBDR, #$20
	
	CALL cmdList1
	
	CALL cmdList2
	
	CALL cmdList3
	
	LD	A,#ST7735_MADCTL
	LD	dataout,A
	CALL	writeCmd
	
	LD	A,$C0
	LD	dataout,A
	CALL	writeData
	
	;test
	LD	A,#$CF
	LD	colorMSB,A
	LD	A,#$AD
	LD	colorLSB,A
	;CALL	fillScreenTFT
	
	LD	A,#$45
	LD	colorMSB,A
	LD	A,#$FF
	LD	colorLSB,A
	LD	A,#30
	LD	x0win,A
	LD	A,#30
	LD	y0win,A
	LD	A,#30
	LD	width,A
	LD	A,#50
	LD	height,A
	;CALL	fillRectTFT
	
	LD	A,#$DD
	LD	colorMSB,A
	LD	A,#$BB
	LD	colorLSB,A
	LD	A,#30
	LD	x0win,A
	LD	A,#30
	LD	y0win,A
	CALL	drawPixel
	
	LD	A,#$CC
	LD	colorMSB,A
	LD	A,#$DB
	LD	colorLSB,A
	LD	A,#80
	LD	x0win,A
	LD	A,#70
	LD	y0win,A
	CALL	drawPixel
	;end test
	
	POP A
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; select a window to write pixel ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;x0win	DS.B	1;p
;y0win	DS.B	1;p
;x1win	DS.B	1;p
;y1win	DS.B	1;p
setAddrWindow:
	PUSH	A
	LD A,#ST7735_CASET
	LD dataout,A
	CALL writeCmd
	
	LD A,#$00
	LD dataout,A
	CALL writeData
	
	LD A,x0win
	LD dataout,A
	CALL writeData
	
	LD A,#$00
	LD dataout,A
	CALL writeData
	
	LD A,x1win
	LD dataout,A
	CALL writeData
	
	
	LD A,#ST7735_RASET
	LD dataout,A
	CALL writeCmd
	
	LD A,#$00
	LD dataout,A
	CALL writeData
	
	LD A,y0win
	LD dataout,A
	CALL writeData
	
	LD A,#$00
	LD dataout,A
	CALL writeData
	
	LD A,y1win
	LD dataout,A
	CALL writeData
	
	
	LD A,#ST7735_RAMWR
	LD dataout,A
	CALL writeCmd
	
	POP	A
	RET
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fill a rectangle with a color ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;x0win	DS.B	1;p
;y0win	DS.B	1;p
;x1win	DS.B	1;u
;y1win	DS.B	1;u
;colorMSB;p
;colorLSB;p
;width;p
;height;p
fillRectTFT:
	PUSH	A
	PUSH	X
	PUSH	Y
	
	LD	A,x0win
	ADD	A,width
	DEC A
	LD	x1win,A
	
	LD	A,y0win
	ADD	A,height
	DEC A
	LD	y1win,A
	
	CALL setAddrWindow
	
	Mor	PBDR, #$04
	Mand	PBDR, #$DF

fill_rect_for_y:
	LD	Y,height
	CP	Y,#0
	JRULE	end_fill_rect_for_y

fill_rect_for_x:
	LD	X,width
	CP	X,#0
	JRULE	end_fill_rect_for_x
	
	LD A,colorMSB
	LD dataout,A
	CALL writeSPI
	LD A,colorLSB
	LD dataout,A
	CALL writeSPI
	
	DEC X
	JP	fill_rect_for_x
	
end_fill_rect_for_x:
	DEC	Y
	JP	fill_rect_for_y
	
end_fill_rect_for_y:
	Mor PBDR, #$20
	
	POP	Y
	POP	X
	POP	A
	RET
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fill entire screen with a color ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;x0win	DS.B	1;u
;y0win	DS.B	1;u
;width	DS.B	1;u
;height	DS.B	1;u
;colorMSB;p
;colorLSB;p
fillScreenTFT:
	PUSH	A
	
	LD	A,#0
	LD	x0win,A
	LD	A,#0
	LD	y0win,A
	LD	A,#ST7735_TFTWIDTH
	LD	width,A
	LD	A,#ST7735_TFTHEIGHT_18
	LD	height,A
	CALL	fillRectTFT
	
	POP	A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; draw colored pixel on screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;x0win	DS.B	1;p
;y0win	DS.B	1;p
;colorMSB;p
;colorLSB;p
drawPixel:
	PUSH	A
	
	LD	A,x0win
	INC A
	LD	x1win,A
	
	LD	A,y0win
	INC A
	LD	y1win,A
	
	CALL setAddrWindow

	Mor	PBDR, #$04
	Mand	PBDR, #$DF
	
	LD A,colorMSB
	LD dataout,A
	CALL writeSPI
	LD A,colorLSB
	LD dataout,A
	CALL writeSPI
	
	Mor PBDR, #$20
	
	POP	A
	RET



;************************************************************************

	END

;************************************************************************
