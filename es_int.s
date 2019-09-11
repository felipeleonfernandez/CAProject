* Titulación: Grado en Ingeniería Informática. Plan 2009.
* Materia:    Arquitectura de computadores.
* Archivo:    es_int.s
*
* Autor 1: Iñigo Ramírez Tirado
* Autor 2: Felipe León Fernández
****************************************************************************************************************************


* Inicializa el SP y el PC
****************************************************************************************************************************
					
					ORG				$0
					DC.L			$8000						* Puntero pila inicial
					DC.L			INICIO  					* PC inicial

					ORG				$400


* Definición de equivalencias
****************************************************************************************************************************
* Todos los siguientes son registros de control y todos son de 8 bits (usar instrucciones .B)

MR1A    	EQU     $effc01   	* de modo A (escritura)
MR2A    	EQU     $effc01   	* de modo A (2º escritura)
SRA     	EQU     $effc03   	* de estado A (lectura)
CSRA    	EQU     $effc03   	* de seleccion de reloj A (escritura)
CRA     	EQU     $effc05     * de control A (escritura)
TBA     	EQU     $effc07     * buffer transmision A (escritura)
RBA     	EQU     $effc07     * buffer recepcion A (lectura)
ACR			EQU	 	$effc09	    * de control auxiliar  
IMR     	EQU     $effc0B     * de mascara de interrupcion A (escritura)
ISR     	EQU     $effc0B     * de estado de interrupcion A (lectura)

MR1B    	EQU     $effc11     * de modo B (escritura)
MR2B    	EQU     $effc11     * de modo B (2º escritura)
SRB	   		EQU     $effc13     * de estado B (lectura)
CSRB    	EQU     $effc13     * de seleccion de reloj B (escritura)
CRB     	EQU     $effc15     * de control B (escritura)
TBB     	EQU     $effc17     * buffer transmision B (escritura)
RBB     	EQU     $effc17     * buffer recepcion B (lectura)

IVR 		EQU	 	$effc19		* del vector de interrupción


**************************** VARIABLES *************************************************************************************

BIRA:				DS.B 			2001						* Reserva 2001B
PIBIRA:				DC.L 			0							* Puntero de inserción del buffer de recepción de A a 0
PEBIRA:				DC.L 			0							* Puntero de extracción del buffer de recepción de A a 0

BIRB:				DS.B 			2001						* Reserva 2001B
PIBIRB:				DC.L 			0							* Puntero de inserción del buffer de recepción de B a 0
PEBIRB:				DC.L  			0							* Puntero de extracción del buffer de recepción de B a 0

BITA:				DS.B 			2001						* Reserva 2001B
PIBITA: 			DC.L 			0							* Puntero de inserción del buffer de transmisión de A a 0
PEBITA: 			DC.L 			0							* Puntero de extracción del buffer de transmisión de A a 0

BITB:				DS.B 			2001						* Reserva 2001B
PIBITB:				DC.L 			0							* Puntero de inserción del buffer de transmisión de A a 0
PEBITB:				DC.L 			0							* Puntero de extracción del buffer de transmisión de A a 0

IMRCOPIA:       	DS.B 			1 						    * Copia para lectura de IMR

VPPRA:				DS.B 			1							* Variable que indica si hay al menos un 0x0d en BITA
VPPRB:				DS.B 			1 							* Variable que indica si hay al menos un 0x0d en BITB

FLAGA:				DS.B 			1							* Flag para determinar si hay que trasmitir un salto de 
																* línea por A
FLAGB:				DS.B 			1							* Flag para determinar si hay que trasmitir un salto de 
																* línea por B

**************************** FIN VARIABLES *********************************************************************************

**************************** INIT ******************************************************************************************

INIT:				MOVE.B          #%00010000,CRA				* Reinicia el puntero MR1A
					MOVE.B          #%00000011,MR1A     		* 8 bits por caracter
					MOVE.B          #%00000000,MR2A     		* Eco desactivado					
					MOVE.B          #%11001100,CSRA     		* Velocidad = 38400 b/s
					MOVE.B          #%00010101,CRA      		* Transmisión y recepción activados
					
					MOVE.B          #%00010000,CRB      		* Reinicia el puntero MR1B							
					MOVE.B			#%00000011,MR1B     		* 8 bits por caracter
					MOVE.B          #%00000000,MR2B     		* Eco desactivado
					MOVE.B          #%11001100,CSRB    			* Velocidad = 38400 b/s
					MOVE.B          #%00010101,CRB      		* Transmisión y recepción activados

					MOVE.B          #%00000000,ACR      		* Velocidad = 38400 b/s
					MOVE.B			#%01000000,IVR	    		* Establecer el vector de interrupción 40 (64 decimal)
					MOVE.B			#%00100010,IMR	    		* Habilitar las INT de recepción del puerto correspondiente
																* Las INT de transmisión solo se activarán cuando el buffer
																* de transmisión del puerto correspondiente contengan una
																* línea completa
					MOVE.B			#%00100010,IMRCOPIA 		* Copia para lectura de IMR
					MOVE.L 			#RTI,$100     			    * Actualizar la dir. de la RTI en la tabla de vectores de 
																* interrupción

					MOVE.L 			#BIRA,PIBIRA				* Inicializa el PIBIRA(escritura) a la dir. de comienzo del BIRA
					MOVE.L 			#BIRA,PEBIRA				* Inicializa el PEBIRA(lectura) a la dir. de comienzo del BIRA
					
					MOVE.L 			#BIRB,PIBIRB				* Inicializa el PIBIRB(escritura) a la dir. de comienzo del BIRB
					MOVE.L 			#BIRB,PEBIRB				* Inicializa el PEBIRB(lectura) a la dir. de comienzo del BIRB

					MOVE.L 			#BITA,PIBITA				* Inicializa el PIBITA(escritura) a la dir. de comienzo del BITA
					MOVE.L 			#BITA,PEBITA				* Inicializa el PEBITA(lectura) a la dir. de comienzo del BITA

					MOVE.L 			#BITB,PIBITB				* Inicializa el PIBITB(escritura) a la dir. de comienzo del BITB
					MOVE.L 			#BITB,PEBITB				* Inicializa el PEBITB(lectura) a la dir. de comienzo del BITB

					MOVE.B 			#0,VPPRA 					* VPPRA = 0
					MOVE.B 			#0,VPPRB 					* VPPRB = 0

					MOVE.B 			#0,FLAGA					* FLAGA = 0
					MOVE.B 			#0,FLAGB					* FLAGB = 0

					RTS

**************************** FIN INIT **************************************************************************************

**************************** LEECAR ****************************************************************************************

LEECAR:				MOVE.L 			D2,-(A7)					* Guardamos el registro de datos D2
					MOVE.L 			D3,-(A7)					* Guardamos el registro de datos D3
					MOVE.L 			D4,-(A7)					* Guardamos el registro de datos D4
					MOVE.L 			A0,-(A7)					* Guardamos el registro de dirección A0
					MOVE.L 			A1,-(A7)					* Guardamos el registro de dirección A1
					MOVE.L 			A2,-(A7)					* Guardamos el registro de dirección A2
					MOVE.L 			A3,-(A7)					* Guardamos el registro de dirección A3
					MOVE.L 			D0,D2 						* D2 = D0
					CMP.B 			#0,D2						* ¿D2 == 0?
					BEQ				LC_BIRA						* Salto condicional a LC_BIRA
					CMP.B 			#1,D2						* ¿D2 == 1?
					BEQ				LC_BIRB						* Salto condicional a LC_BIRB
					CMP.B 			#2,D2						* ¿D2 == 2?
					BEQ				LC_BITA						* Salto condicional a LC_BITA
					CMP.B 			#3,D2						* ¿D2 == 3?
					BEQ				LC_BITB						* Salto condicional a LC_BITB

LC_BIRA:			MOVE.L 			PIBIRA,A0					* A0 se usará como puntero de inserción de BIRA
					MOVE.L 			PEBIRA,A1					* A1 se usará como puntero de extracción de BIRA
					MOVE.L 			#BIRA,A2					* A2 = dir. inicial BIRA
					MOVE.L 			A2,A3						* A3 = dir. inicial BIRA
					ADDA.L 			#2000,A3					* A3 = dir. final BIRA
					BRA				LC_CCLL 					* Salto incondicional a LC_CCLL

LC_BIRB:			MOVE.L 			PIBIRB,A0					* A0 se usará como puntero de inserción de BIRB
					MOVE.L 			PEBIRB,A1					* A1 se usará como puntero de extracción de BIRB
					MOVE.L 			#BIRB,A2					* A2 = dir. inicial BIRB
					MOVE.L 			A2,A3						* A3 = dir. inicial BIRB	
					ADDA.L 			#2000,A3 					* A3 = dir. final BIRB 						
					BRA				LC_CCLL 					* Salto incondicional a LC_CCLL

LC_BITA:			MOVE.L 			PIBITA,A0					* A0 se usará como puntero de inserción de BITA
					MOVE.L 			PEBITA,A1					* A1 se usará como puntero de extracción de BITA
					MOVE.L 			#BITA,A2					* A2 = dir. inicial BITA
					MOVE.L 			A2,A3						* A3 = dir. inicial BITA	
					ADDA.L 			#2000,A3 					* A3 = dir. final BITA
					BRA				LC_CCLL 					* Salto incondicional a LC_CCLL

LC_BITB:			MOVE.L 			PIBITB,A0					* A0 se usará como puntero de inserción de BITB
					MOVE.L 			PEBITB,A1					* A1 se usará como puntero de extracción de BITB
					MOVE.L 			#BITB,A2					* A2 = dir. inicial BITB
					MOVE.L 			A2,A3						* A3 = dir. inicial BITB
					ADDA.L 			#2000,A3					* A3 = dir. final BITB
					
* Comprobación casos límite y lectura
LC_CCLL:			CMP.L 			A0,A1 						* ¿PI == PE? Sí -> Vacío
					BEQ 			LC_FCF 						* Salto incondicional a LC_FCF
					MOVE.B 			(A1),D0						* Se lee el carácter de la dir. del PE
					CMP.L 			A1,A3 						* ¿PE == dir. final BI? No -> Lectura normal
					BNE 			LC_LN						* Salto condicional a LC_LN
					MOVE.L 			A2,A1 						* A1 = dir. inicio BI
					BRA 			LC_CYA						* Salto incondicional a LC_CYA
LC_LN:				ADDA.L 			#1,A1 						* PE = PE++

LC_CYA:	 			CMP.B 			#0,D2						* ¿D2 == 0?
					BEQ				LC_ARA						* Salto condicional a LC_ARA
					CMP.B 			#1,D2						* ¿D2 == 1?
					BEQ				LC_ARB						* Salto condicional a LC_ARB
					CMP.B 			#2,D2						* ¿D2 == 2?
					BEQ				LC_ATA						* Salto condicional a LC_ATA
					CMP.B 			#3,D2						* ¿D2 == 3?
					BEQ				LC_ATB						* Salto condicional a LC_ATB

LC_ARA:				MOVE.L 			A1,PEBIRA					* Se actualiza el PEBIRA			
					BRA 			LC_FCL 						* Salto incondicional a LC_FCL

LC_ARB:				MOVE.L 			A1,PEBIRB 					* Se actualiza el PEBIRB			
					BRA 			LC_FCL 						* Salto incondicional a LC_FCL

LC_ATA:				MOVE.L 			A1,PEBITA 					* Se actualiza el PEBITA			
					BRA 			LC_FCL 						* Salto incondicional a LC_FCL

LC_ATB: 			MOVE.L 			A1,PEBITB					* Se actualiza el PEBITB			
					BRA 			LC_FCL 						* Salto incondicional a LC_FCL

* Fin con fallo y fin con lectura
LC_FCF: 			MOVE.L 			#-1,D0 						* D0 = -1
LC_FCL:				MOVE.L 			(A7)+,A3					* Recuperamos el registro de dirección A3
					MOVE.L 			(A7)+,A2					* Recuperamos el registro de dirección A2
					MOVE.L 			(A7)+,A1					* Recuperamos el registro de dirección A1
					MOVE.L 			(A7)+,A0					* Recuperamos el registro de dirección A0
					MOVE.L 			(A7)+,D4					* Guardamos el registro de datos D4
					MOVE.L 			(A7)+,D3					* Guardamos el registro de datos D3
					MOVE.L 			(A7)+,D2					* Guardamos el registro de datos D2
					RTS

**************************** FIN LEECAR ************************************************************************************

**************************** ESCCAR ****************************************************************************************

ESCCAR:				MOVE.L 			D2,-(A7)					* Guardamos el registro de datos D2
					MOVE.L 			D3,-(A7)					* Guardamos el registro de datos D3
					MOVE.L 			D4,-(A7)					* Guardamos el registro de datos D4
					MOVE.L 			A0,-(A7)					* Guardamos el registro de dirección A0
					MOVE.L 			A1,-(A7)					* Guardamos el registro de dirección A1
					MOVE.L 			A2,-(A7)					* Guardamos el registro de dirección A2
					MOVE.L 			A3,-(A7)					* Guardamos el registro de dirección A3
					MOVE.L 			A4,-(A7)					* Guardamos el registro de dirección A4
					MOVE.L 			D0,D2 						* D2 = D0
					CMP.B 			#0,D2						* ¿D2 == 0?
					BEQ				EC_BIRA						* Salto condicional a EC_BIRA
					CMP.B 			#1,D2						* ¿D2 == 1?
					BEQ				EC_BIRB						* Salto condicional a EC_BIRB
					CMP.B 			#2,D2						* ¿D2 == 2?
					BEQ				EC_BITA						* Salto condicional a EC_BITA
					CMP.B 			#3,D2						* ¿D2 == 3?
					BEQ				EC_BITB						* Salto condicional a EC_BITB

EC_BIRA:			MOVE.L 			PIBIRA,A0					* A0 se usará como puntero de inserción de BIRA
					MOVE.L 			PEBIRA,A1					* A1 se usará como puntero de extracción de BIRA
					MOVE.L 			#BIRA,A2					* A2 = dir. inicial BIRA
					MOVE.L 			A2,A3 						* A5 = dir. inicial BIRA
					ADDA.L 			#2000,A3 					* A5 = dir. final BIRA
					BRA				EC_CCLE 					* Salto incondicional a EC_CCLE

EC_BIRB:			MOVE.L 			PIBIRB,A0					* A0 se usará como puntero de inserción de BIRB
					MOVE.L 			PEBIRB,A1					* A1 se usará como puntero de extracción de BIRB
					MOVE.L 			#BIRB,A2					* A2 = dir. inicial BIRB
					MOVE.L 			A2,A3						* A3 = dir. inicial BIRB
					ADDA.L 			#2000,A3 					* A3 = dir. final BIRB
					BRA				EC_CCLE 					* Salto incondicional a EC_CCLE

EC_BITA:			MOVE.L 			PIBITA,A0					* A0 se usará como puntero de inserción de BITA
					MOVE.L 			PEBITA,A1					* A1 se usará como puntero de extracción de BITA
					MOVE.L 			#BITA,A2					* A2 = dir. inicial BITA
					MOVE.L 			A2,A3						* A3 = dir. inicial BITA
					ADDA.L 			#2000,A3 					* A3 = dir. final BITA
					BRA				EC_CCLE						* Salto incondicional a EC_CCLE

EC_BITB:			MOVE.L 			PIBITB,A0					* A0 se usará como puntero de inserción de BITB
					MOVE.L 			PEBITB,A1					* A1 se usará como puntero de extracción de BITB
					MOVE.L 			#BITB,A2					* A2 = dir. inicial BITB
					MOVE.L 			A2,A3						* A3 = dir. inicial BITB
					ADDA.L 			#2000,A3 					* A3 = dir. final BITB

* Comprobación casos límite y escritura
EC_CCLE:			MOVE.L    		A1,A4						* A4 = PE
					SUBA.L 			A0,A4						* A4 = PE - PI
					CMP.L 			#1,A4						* ¿(PE - PI) == 1? Sí -> Lleno
					BEQ 			EC_FCF						* Salto condicional a EC_FCF
					CMP.L 			A0,A3 						* ¿PI == dir. final BI? No -> Escritura normal
					BNE 			EC_EN						* Salto incondicional a EC_EN
					CMP.L 			A1,A2 						* ¿PE == dir. inicial BI? Sí -> Lleno
					BEQ 			EC_FCF 						* Salto incondicional a EC_FCF
					MOVE.B 			D1,(A0) 					* Se inserta el carácter en la dir. del PI
					MOVE.L 			A2,A0 						* PI = dir. inicial BI
					MOVE.B 			#0,(A0) 					* Se inserta un 0 en la nueva dir. del PI
					BRA 			EC_CYA 						* Salto incondicional a EC_CYA
EC_EN:				MOVE.B 			D1,(A0) 					* Se inserta el caracter en PI
					ADDA.L 			#1,A0 						* PI = PI++
					MOVE.B 			#0,(A0) 					* Se inserta 0 en la nueva pos. del PI

EC_CYA:	 			CMP.B 			#0,D2						* ¿D2 == 0?
					BEQ				EC_ARA						* Salto condicional a EC_ARA
					CMP.B 			#1,D2						* ¿D2 == 1?
					BEQ				EC_ARB						* Salto condicional a EC_ARB
					CMP.B 			#2,D2						* ¿D2 == 2?
					BEQ				EC_ATA						* Salto condicional a EC_ATA
					CMP.B 			#3,D2						* ¿D2 == 3?
					BEQ				EC_ATB						* Salto condicional a EC_ATB

EC_ARA:				MOVE.L 			A0,PIBIRA 					* Se actualiza el PIBIRA			
					BRA 			EC_FCE 						* Salto incondicional a EC_FCE

EC_ARB:				MOVE.L 			A0,PIBIRB 					* Se actualiza el PIBIRB			
					BRA 			EC_FCE 						* Salto incondicional a EC_FCE

EC_ATA:				MOVE.L 			A0,PIBITA 					* Se actualiza el PIBITA			
					BRA 			EC_FCE 						* Salto incondicional a EC_FCE

EC_ATB: 			MOVE.L 			A0,PIBITB					* Se actualiza el PIBITB			
					BRA 			EC_FCE 						* Salto incondicional a EC_FCE

* Fin con fallo o fin con escritura, y restauración de valores de los registros
EC_FCF: 			MOVE.L 			#-1,D0 						* D0 = -1
					BRA 			EC_RVR						* Salto incondicional a EC_RVR

EC_FCE: 			MOVE.L 			#0,D0 						* D0 = 0

EC_RVR:				MOVE.L 			(A7)+,A4					* Recuperamos el registro de dirección A4
					MOVE.L 			(A7)+,A3					* Recuperamos el registro de dirección A3
					MOVE.L 			(A7)+,A2					* Recuperamos el registro de dirección A2
					MOVE.L 			(A7)+,A1					* Recuperamos el registro de dirección A1
					MOVE.L 			(A7)+,A0					* Recuperamos el registro de dirección A0
					MOVE.L 			(A7)+,D4					* Guardamos el registro de datos D4
					MOVE.L 			(A7)+,D3					* Guardamos el registro de datos D3
					MOVE.L 			(A7)+,D2					* Guardamos el registro de datos D2
					RTS

**************************** FIN ESCCAR ************************************************************************************

**************************** LINEA *****************************************************************************************

LINEA:				MOVE.L 			D1,-(A7)					* Guardamos el registro de datos D1
					MOVE.L 			D2,-(A7)					* Guardamos el registro de datos D2
					MOVE.L 			D3,-(A7)					* Guardamos el registro de datos D3
					MOVE.L 			D4,-(A7)					* Guardamos el registro de datos D4
					MOVE.L 			A0,-(A7)					* Guardamos el registro de dirección A0
					MOVE.L 			A1,-(A7)					* Guardamos el registro de dirección A1
					MOVE.L 			A2,-(A7)					* Guardamos el registro de dirección A2
					MOVE.L 			A3,-(A7)					* Guardamos el registro de dirección A3
					MOVE.L 			D0,D2 						* D2 = D0
					MOVE.L 			#0,D1 						* D1 = 0 (contador)
					CMP.B 			#0,D2						* ¿D2 == 0?
					BEQ				LI_BIRA						* Salto condicional a LI_BIRA
					CMP.B 			#1,D2						* ¿D2 == 1?
					BEQ				LI_BIRB						* Salto condicional a LI_BIRB
					CMP.B 			#2,D2						* ¿D2 == 2?
					BEQ				LI_BITA						* Salto condicional a LI_BITA
					CMP.B 			#3,D2						* ¿D2 == 3?
					BEQ				LI_BITB						* Salto condicional a LI_BITB

LI_BIRA:			MOVE.L 			PEBIRA,A0					* A0 se usará como copia puntero de extracción de BIRA
					MOVE.L 			PIBIRA,A3					* A3 se usará como copia puntero de inserción de BIRA
					MOVE.L 			#BIRA,A1					* A1 = dir. inicial BIRA
					MOVE.L 			A1,A2						* A2 = dir. inicial BIRA	
					ADDA.L 			#2000,A2 					* A2 = dir. final BIRA
					BRA				LI_CONT 					* Salto incondicional a LI_CONT

LI_BIRB:			MOVE.L 			PEBIRB,A0					* A0 se usará como copia puntero de extracción de BIRB
					MOVE.L 			PIBIRB,A3					* A3 se usará como copia puntero de inserción de BIRB
					MOVE.L 			#BIRB,A1					* A1 = dir. incondicional BIRB
					MOVE.L 			A1,A2						* A2 = dir. incondicional BIRB	
					ADDA.L 			#2000,A2 					* A2 = dir. final BIRB					
					BRA				LI_CONT 					* Salto incondicional a LI_CONT

LI_BITA:			MOVE.L 			PEBITA,A0					* A0 se usará como copia puntero de extracción de BITA
					MOVE.L 			PIBITA,A3					* A3 se usará como copia puntero de inserción de BITA
					MOVE.L 			#BITA,A1					* A1 = dir. inicial BITA
					MOVE.L 			A1,A2						* A2 = dir. inicial BITA	
					ADDA.L 			#2000,A2 					* A2 = dir. final BITA
					BRA				LI_CONT 					* Salto incondicional a LI_CONT

LI_BITB:			MOVE.L 			PEBITB,A0					* A0 se usará como copia puntero de extracción de BITB
					MOVE.L 			PIBITB,A3					* A3 se usará como copia puntero de inserción de BITB
					MOVE.L 			#BITB,A1					* A1 = dir. inicial BITB
					MOVE.L 			A1,A2						* A2 = dir. inicial BITB	
					ADDA.L 			#2000,A2 					* A2 = dir. final BITB

* Contar caracteres línea
LI_CONT: 			CMP.L 			A0,A3 						* ¿PE == PI? Sí -> Vacío
					BEQ 			LI_FCF 						* Salto condicional a LI_FCF
LI_CONTB:			MOVE.B 			(A0),D4 					* D4 = Mem(A0)
					ADD.L 			#1,D1 						* Contador = Contador++
					CMP.L 			#2001,D1 					* ¿Se han leído 2001 posiciones?
					BEQ 			LI_FCF 						* Salto condicional a LI_FCF
					CMP.B 			#13,D4 						* ¿El caracter leído es el retorno de carro?
					BEQ 			LI_FCC 						* Salto condicional a LI_FCC
					CMP.L 			A0,A3 						* ¿PI == PE?
					BEQ 			LI_FCF 						* Salto condicional a LI_FCF
					CMP.L 			A0,A2 						* ¿Copia del PE == dir. final BI?
					BEQ 			LI_CPEF 					* Salto condicional a LI_CPEF
					ADDA.L 			#1,A0 						* Copia del PE = Copia del PE++
					BRA 			LI_CONTB 					* Salto incondicional a LI_CONTB
LI_CPEF:			MOVE.L 			A1,A0						* Copia del PE = dir. inicial BI
					BRA 			LI_CONTB 					* Salto incondicional a LI_CONTB	

* Fin con fallo o fin con cuenta, y restaurar valores de los registros
LI_FCF:				MOVE.L 			#0,D0 						* D0 = 0
					BRA 			LI_RVR 						* Salto incondicional LI_RVR			
LI_FCC:				MOVE.L 			D1,D0 						* D0 = D1
LI_RVR:				MOVE.L 			(A7)+,A3					* Recuperamos el registro de dirección A3
					MOVE.L 			(A7)+,A2					* Recuperamos el registro de dirección A2
					MOVE.L 			(A7)+,A1					* Recuperamos el registro de dirección A1
					MOVE.L 			(A7)+,A0					* Recuperamos el registro de dirección A0
					MOVE.L 			(A7)+,D4					* Guardamos el registro de datos D4
					MOVE.L 			(A7)+,D3					* Guardamos el registro de datos D3
					MOVE.L 			(A7)+,D2					* Guardamos el registro de datos D2
					MOVE.L 			(A7)+,D1					* Guardamos el registro de datos D2
					RTS

**************************** FIN LINEA *************************************************************************************		

**************************** SCAN ******************************************************************************************

SCAN:				LINK 			A6,#-24 					* Creación del marco de pila reservando 24 bytes
					MOVE.L 			A0,-4(A6) 					* Se guarda el valor del registro A0
					MOVE.L 			D1,-8(A6) 					* Se guarda el valor del registro D1
					MOVE.L 			D2,-12(A6) 					* Se guarda el valor del registro D2
					MOVE.L 			D3,-16(A6) 					* Se guarda el valor del registro D3
					MOVE.L 			D4,-20(A6) 					* Se guarda el valor del registro D4
					MOVE.L 			D5,-24(A6) 					* Se guarda el valor del registro D5
					MOVE.L 			#0,A0						* A0 = 0
					MOVE.L 			#0,D1 						* D1 = 0
					MOVE.L 			#0,D2 						* D2 = 0
					MOVE.L 			#0,D3 						* D3 = 0
					MOVE.L 			#0,D4 						* D4 = 0
					MOVE.L 			#0,D5 						* D5 = 0
					MOVE.L 			8(A6),A0 					* A0 = dir. buffer externo (BE)
					MOVE.W 			12(A6),D1					* D1 = descriptor dispositivo
					MOVE.W 			14(A6),D2 					* D2 = tamaño máx. caracteres que se pueden leer del BI
					MOVE.L 			#0,D3 						* D3 = 0 (contador)
					CMP.W 			#0,D2 						* ¿Tamaño máx. == 0?
					BEQ 			SC_FC0 						* Salto condicional a SC_FC0
					CMP.W 			#0,D1 						* ¿D1 == 0?
					BEQ 			SC_PA 						* Salto condicional a SC_PA
					CMP.W 			#1,D1 						* ¿D1 == 1?
					BEQ 			SC_PB 						* Salto condicional a SC_PB
					JMP 			SC_FCF 						* Salto incondicional a SC_FCF

SC_PA:				MOVE.L 			#0,D0 						* D0 = 0 (BIRA)
					MOVE.L 			#0,D4 						* D4 = 0 (BIRA)
					BSR 			LINEA 						* Salto incondicional a LINEA
					MOVE.L 			D0,D5 						* D5 = D0 (tamaño línea)
					CMP.W 			D2,D0 						* ¿D0 (caracteres en BIRA) > D2 (tamaño máx.)?
					BHI 			SC_FC0 						* Salto condicional a SC_FC0
					CMP.W 			#0,D0 						* ¿D0 (caracteres en BIRA) == 0?
					BEQ 			SC_FC0 						* Salto condicional a SC_FC0
					BRA 			SC_BCP 						* Salto incondicional a SC_BCB

SC_PB:				MOVE.L 			#1,D0 						* D0 = 1 (BIRB)
					MOVE.L 			#1,D4						* D4 = 1 (BIRB)
					BSR 			LINEA 						* Salto incondicional a LINEA
					MOVE.L 			D0,D5 						* D5 = D0 (tamaño línea)
					CMP.W 			D2,D0 						* ¿D0 (caracteres en BIRB) > D2 (tamaño máx.)?
					BHI 			SC_FC0 						* Salto condicional a SC_FC0
					CMP.W 			#0,D0 						* ¿D0 (caracteres en BIRB) == 0?
					BEQ 			SC_FC0 						* Salto condicional a SC_FC0

SC_BCP: 			CMP.L 			D3,D5 						* ¿D3 (contador) == D5 (tamaño línea)?
					BEQ 			SC_FCE 						* Salto condicional a SC_FCE
					MOVE.L 			D4,D0 						* D0 = D4 (BIR)
					BSR 			LEECAR 						* Salto incondicional a LEECAR
					MOVE.B 			D0,(A0)  					* Mem(A0) = D0
					ADD.L 			#1,D3 						* Contador = Contador++
					ADDA.L 			#1,A0 						* Dir. BE = Dir. BE++
					BRA 			SC_BCP 						* Salto incondicional a SC_BCP

* Fin con 0, fin con fallo o fin con escaneo, y restaurar valores de los registros
SC_FC0: 			MOVE.L 			#0,D0 						* D0 = 0 						
					BRA 			SC_RVR 						* Salto incondicional a SC_RVR
SC_FCF: 			MOVE.L 			#-1,D0 						* D0 = -1
					BRA 			SC_RVR 						* Salto incondicional a SC_RVR
SC_FCE:				MOVE.L 			D3,D0 						* D0 = D3 (contador) 			
SC_RVR:				MOVE.L 			-4(A6),A0 					* Se restaura el valor previo del registro A0
					MOVE.L 			-8(A6),D1 					* Se restaura el valor previo del registro D1
					MOVE.L 			-12(A6),D2 					* Se restaura el valor previo del registro D2
					MOVE.L 			-16(A6),D3					* Se restaura el valor previo del registro D3
					MOVE.L 			-20(A6),D4 					* Se restaura el valor previo del registro D4
					MOVE.L 			-24(A6),D5 					* Se restaura el valor previo del registro D5
					UNLK 			A6
					RTS

**************************** FIN SCAN **************************************************************************************

**************************** PRINT *****************************************************************************************

PRINT:				LINK 			A6,#-24 					* Creación del marco de pila reservando 24 bytes
					MOVE.L 			A0,-4(A6) 					* Se guarda el valor del registro A0
					MOVE.L 			D1,-8(A6) 					* Se guarda el valor del registro D1
					MOVE.L 			D2,-12(A6) 					* Se guarda el valor del registro D2
					MOVE.L 			D3,-16(A6) 					* Se guarda el valor del registro D3
					MOVE.L 			D6,-20(A6) 					* Se guarda el valor del registro D6
					MOVE.L 			D7,-24(A6) 					* Se guarda el valor del registro D7
					MOVE.L 			#0,A0						* A0 = 0
					MOVE.L 			#0,D1 						* D1 = 0
					MOVE.L 			#0,D2 						* D2 = 0
					MOVE.L 			#0,D3 						* D3 = 0
					MOVE.L 			#0,D6 						* D6 = 0
					MOVE.L 			#0,D7 						* D7 = 0
					MOVE.L 			8(A6),A0 					* A0 = dir. buffer externo (BE)
					MOVE.W 			12(A6),D1					* D1 = descriptor dispositivo
					MOVE.W 			14(A6),D2 					* D2 = tamaño máx. caracteres que se pueden leer del BE
					MOVE.L 			#0,D6  						* D6(contadorA) = 0
					MOVE.L 			#0,D7 						* D7(contadorB) = 0
					CMP.W 			#0,D2 						* ¿Tamaño == 0?
					BEQ 			PR_FC0 						* Salto condicional a PR_FC0
					CMP.B 			#0,D1 						* ¿D1 == 0?
					BEQ 			PR_PA 						* Salto condicional a PR_BA
					CMP.B 			#1,D1 						* ¿D1 == 1?
					BEQ 			PR_PB 						* Salto condicional a PR_BB
					BRA 			PR_FCF 						* Salto incondicional a PR_FCF

PR_PA:				CMP.W 			D6,D2 						* ¿Tamaño == ContadorA?
					BEQ 			PR_CVA 						* Salto condicional a PA_CVA
					MOVE.L 			#2,D0 						* D0 = 2 (10)(BITA)
		 			MOVE.B 			(A0),D1 					* D1 = mem(A0) (carácter)
					ADDA.L 			#1,A0 						* Dir. BE = Dir. BE++
					BSR 			ESCCAR 						* Salto incondicional a ESCCAR
					CMP.L 			#-1,D0 						* ¿D0 == -1?
					BEQ 			PR_RVRCA 					* Salto condicional a PR_RVRCA
					ADD.L 			#1,D6						* ContadorA = ContadorA++
					CMP.B 			#13,D1 						* ¿D1(caracter) == 13(retorno de carro)?
					BNE 			PR_PA 						* Salto condicional a PR_PA
					MOVE.B 			#1,VPPRA 					* Variable de carro = 1
					BRA 			PR_PA 						* Salto incondicional a PR_PA	 			
PR_CVA: 			CMP.B 			#1,VPPRA 					* ¿VPPRA == 1? 			
					BEQ 			PR_ITBIA 					* Salto condicional a PR_ITBIA
					BRA 			PR_RVRCA 					* Salto incondicional a PR_RVRCA
PR_ITBIA: 			MOVE.B 			#0,VPPRA 					* VPPRA = 0
					MOVE.W 			#$2700,SR   				* Se deshabilitan todas las interrupciones
					BSET.B 			#0,IMRCOPIA 				* Habilitadas las interrupciones en la línea A
					MOVE.B 			IMRCOPIA,IMR 			 	* Actualización IMR (IMRCOPIA -> IMR)
					MOVE.W 			#$2000,SR   				* Se habilitan todas las interrupciones 			
					BRA 			PR_RVRCA					* Salto incondicional a PR_RVRCA

PR_PB:				CMP.W 			D7,D2 						* ¿Tamaño == ContadorB?
					BEQ 			PR_CVB 						* Salto condicional a PR_CVB
					MOVE.L 			#3,D0 						* D0 = 3 (11)(BITB)
		 			MOVE.B 			(A0),D1 					* D1 = mem(A0) (carácter)
					ADDA.L 			#1,A0 						* Dir. BE = Dir. BE++
					BSR 			ESCCAR 						* Salto incondicional a ESCCAR
					CMP.L 			#-1,D0 						* ¿D0 == -1?
					BEQ 			PR_RVRCB 					* Salto condicional a PR_RVRCB
					ADD.L 			#1,D7						* ContadorB = Contador++
					CMP.B 			#13,D1 						* ¿D1(carácter) == 13(retorno de carro)?
					BNE 			PR_PB 						* Salto condicional a PR_PB
					MOVE.B 			#1,VPPRB 					* VPPRB = 1
					BRA 			PR_PB 						* Salto incondicional a PR_PB
PR_CVB: 			CMP.B 			#1,VPPRB 					* ¿VPPRB == 1? 
					BEQ 			PR_ITBIB 					* Salto condicional a PR_ITBIB
					BRA 			PR_RVRCB 					* Salto incondicional a PR_RVRCB
PR_ITBIB: 			MOVE.B 			#0,VPPRB 					* VPPRB = 0
					MOVE.W 			#$2700,SR   				* Se deshabilitan todas las interrupciones
					BSET.B			#4,IMRCOPIA 				* Habilitadas las interrupciones en la línea B
					MOVE.B 			IMRCOPIA,IMR 			 	* Actualización IMR (IMRCOPIA -> IMR)
					MOVE.W 			#$2000,SR   				* Se habilitan todas las interrupciones
					BRA 			PR_RVRCB					* Salto incondicional a PR_RVRCB

* Fin con 0 o fin con fallo, devolver contador A o B y restaurar valores de los registros
PR_FC0: 			MOVE.L 			#0,D0 						* D0 = 0
					BRA 			PR_RVR 						* Salto incondicional a PR_RVR
PR_FCF: 			MOVE.L 			#-1,D0 						* D0 = -1
					BRA 			PR_RVR 						* Salto incondicional a PR_RVR
PR_RVRCA:			MOVE.L 			D6,D0 						* D0 = ContadorA
					BRA 			PR_RVR 						* Salto incondicional a PR_RVR
PR_RVRCB:			MOVE.L 			D7,D0 						* D0 = ContadorB				
PR_RVR:				MOVE.L 			-4(A6),A0 					* Se restaura el valor previo del registro A0
					MOVE.L 			-8(A6),D1 					* Se restaura el valor previo del registro D1
					MOVE.L 			-12(A6),D2 					* Se restaura el valor previo del registro D2
					MOVE.L 			-16(A6),D3 					* Se restaura el valor previo del registro D3
					MOVE.L 			-20(A6),D6 					* Se restaura el valor previo del registro D6
					MOVE.L 			-24(A6),D7 					* Se restaura el valor previo del registro D7
					UNLK 			A6 							* Destrucción del marco de pila de 24 bytes
					RTS

**************************** FIN PRINT *************************************************************************************		

**************************** RTI *******************************************************************************************

RTI:				LINK 			A6,#-56						* Creación del marco de pila reservando 52 bytes
					MOVE.L 			A0,-4(A6) 					* Se guarda el valor del registro A0
					MOVE.L 			A1,-8(A6) 					* Se guarda el valor del registro A1
					MOVE.L 			A2,-12(A6) 					* Se guarda el valor del registro A2
					MOVE.L 			A3,-16(A6) 					* Se guarda el valor del registro A3
					MOVE.L 			A4,-20(A6) 					* Se guarda el valor del registro A4
					MOVE.L 			A5,-24(A6) 					* Se guarda el valor del registro A5
					MOVE.L 			D0,-28(A6) 					* Se guarda el valor del registro D0
					MOVE.L 			D1,-32(A6) 					* Se guarda el valor del registro D1
					MOVE.L 			D2,-36(A6) 					* Se guarda el valor del registro D2
					MOVE.L 			D3,-40(A6) 					* Se guarda el valor del registro D3
					MOVE.L 			D4,-44(A6) 					* Se guarda el valor del registro D4
					MOVE.L 			D5,-48(A6) 					* Se guarda el valor del registro D5
					MOVE.L 			D6,-52(A6) 					* Se guarda el valor del registro D6
					MOVE.L 			D7,-56(A6) 					* Se guarda el valor del registro D7
					MOVE.L 			#0,A0 						* A0 = 0
					MOVE.L 			#0,D1 						* D1 = 0
					MOVE.L 			#0,D2 						* D2 = 0
					MOVE.L 			#0,D3 						* D3 = 0
					MOVE.L 			#0,D4 						* D4 = 0
					MOVE.L 			#0,D5 						* D5 = 0
RTI_INI:			MOVE.B 			IMRCOPIA,D1 				* D1 = IMRCOPIA
					MOVE.B 			ISR,D2 						* D2 = ISR

					BTST 			#0,D1 						* ¿Bit 0(TxRDYA IMR) == 0?
					BEQ 			RTI_CB1						* Salto condicional a RTI_CB1
					BTST 			#0,D2 						* ¿Bit 0(TxRDYA ISR) == 0?
					BEQ 			RTI_CB1 					* Salto condicional a RTI_CB1
					BRA 			RTI_TA 						* Salto incondicional a RTI_TA
RTI_CB1: 			BTST 			#1,D1 						* ¿Bit 1(RxRDYA IMR) == 0?
					BEQ 			RTI_CB4						* Salto condicional a RTI_CB4
					BTST 			#1,D2 						* ¿Bit 1(RxRDYA ISR) == 0?
					BEQ 			RTI_CB4 					* Salto condicional a RTI_CB4
					BRA 			RTI_RA 						* Salto incondicional a RTI_RA
RTI_CB4: 			BTST 			#4,D1 						* ¿Bit 4(TxRDYB IMR) == 0?
					BEQ 			RTI_CB5						* Salto condicional a RTI_CB5
					BTST 			#4,D2 						* ¿Bit 4(TxRDYB ISR) == 0?
					BEQ 			RTI_CB5 					* Salto condicional a RTI_CB5
					BRA 			RTI_TB 						* Salto incondicional a RTI_TB
RTI_CB5: 			BTST 			#5,D1 						* ¿Bit 5(RxRDYB IMR) == 0?
					BEQ 			RTI_RVR						* Salto condicional a RTI_RVR
					BTST 			#5,D2 						* ¿Bit 5(RxRDYB ISR) == 0?
					BEQ 			RTI_RVR 					* Salto condicional a RTI_RVR
					BRA 			RTI_RB 						* Salto incondicional a RTI_RB

* Transmisión por A
RTI_TA:				CMP.B 			#1,FLAGA					* ¿FLAGA == 1? Sí -> Retorno de carro
					BEQ				RTI_FAA						* Salto condicional a RTI_FAA
					MOVE.L 			#2,D0 						* D0 = 2
					BSR 			LEECAR 						* Salto incondicional a LEECAR
					CMP 			#-1,D0 						* ¿D0 == -1?
					BNE 			RTI_CTA 					* Salto condicional a RTI_CTA
RTI_DITA:			BCLR.B 			#0,IMRCOPIA					* Bit 0(TxRDYA IMR) de D2 = 0
					MOVE.B 			IMRCOPIA,IMR 				* Actualización del IMR
					BRA 			RTI_INI 					* Salto incondicional a RTI_INI
RTI_CTA: 			MOVE.B 			D0,TBA 						* TBA = D0(carácter leído)
					CMP 			#13,D0 						* ¿D0 == 13? Sí -> Activar flag A
					BEQ 			RTI_AFA 					* Salto condicional a RTI_AFA
					BRA 			RTI_INI 					* Salto incondicional a RTI_INI
RTI_FAA: 			MOVE.B 			#10,TBA 					* TBA = 10(salto de línea)
					MOVE.B 			#0,FLAGA					* FLAGA = 0
					MOVE.B 			#2,D0 						* D0 = 2
					BSR 			LINEA 						* Salto incondicional a LINEA
					CMP 			#0,D0 						* ¿D0 == 0?
					BEQ 			RTI_DITA					* Salto condicional a RTI_DITA
					BRA 			RTI_INI						* Salto incondicional a RTI_INI
RTI_AFA:			MOVE.B 			#1,FLAGA					* FLAGA = 1
					BRA 			RTI_INI						* Salto incondicional a RTI_INI

RTI_RA:				MOVE.L 			#0,D0 						* D0 = 0
					MOVE.B 			RBA,D1 						* D1 = RBA(caracter a escribir)
					BSR 			ESCCAR 						* Salto incondicional a ESCCAR
					BRA 			RTI_INI 					* Salto incondicional a RTI_INI

* Transmisión por B
RTI_TB:				CMP.B 			#1,FLAGB					* ¿FLAGB == 1?
					BEQ				RTI_FBA						* Salto condicional a RTI_FBA
					MOVE.L 			#3,D0 						* D0 = 3
					BSR 			LEECAR 						* Salto incondicional a LEECAR
					CMP 			#-1,D0 						* ¿D0 == -1?
					BNE 			RTI_CTB 					* Salto condicional a RTI_CTB
RTI_DITB:			BCLR.B 			#4,IMRCOPIA					* Bit 4(TxRDYB IMR) de D2 = 0
					MOVE.B 			IMRCOPIA,IMR 				* Actualización del IMR
					BRA 			RTI_INI 					* Salto incondicional a RTI_INI
RTI_CTB: 			MOVE.B 			D0,TBB 						* TBB = D0(carácter leído)
					CMP 			#13,D0 						* ¿D0 == 13? Sí -> Activar flag B
					BEQ 			RTI_AFB 					* Salto condicional a RTI_AFB
					BRA 			RTI_INI 					* Salto incondicional a RTI_INI
RTI_FBA: 			MOVE.B 			#10,TBB 					* TBA = 10(salto de línea)
					MOVE.B 			#0,FLAGB					* FLAGB = 0
					MOVE.B 			#3,D0 						* D0 = 2
					BSR 			LINEA 						* Salto incondicional a LINEA
					CMP 			#0,D0 						* ¿D0 == 0?
					BEQ 			RTI_DITB					* Salto condicional a RTI_DITB
					BRA 			RTI_INI						* Salto incondicional a RTI_INI
RTI_AFB:			MOVE.B 			#1,FLAGB					* FLAGB = 1
					BRA 			RTI_INI						* Salto incondicional a RTI_INI

RTI_RB:				MOVE.L 			#1,D0 						* D0 = 1
					MOVE.B 			RBB,D1 						* D1 = RBB(caracter a escribir)
					BSR 			ESCCAR 						* Salto incondicional a ESCCAR
					BRA 			RTI_INI 					* Salto incondicional a RTI_INI

* Restaurar valores de los registros
RTI_RVR:			MOVE.L 			-4(A6),A0 					* Se restaura el valor previo del registro A0
					MOVE.L 			-8(A6),A1 					* Se restaura el valor previo del registro A1
					MOVE.L 			-12(A6),A2 					* Se restaura el valor previo del registro A2
					MOVE.L 			-16(A6),A3 					* Se restaura el valor previo del registro A3
					MOVE.L 			-20(A6),A4 					* Se restaura el valor previo del registro A4
					MOVE.L 			-24(A6),A5 					* Se restaura el valor previo del registro A5
					MOVE.L 			-28(A6),D0 					* Se restaura el valor previo del registro D1
					MOVE.L 			-32(A6),D1 					* Se restaura el valor previo del registro D1
					MOVE.L 			-36(A6),D2 					* Se restaura el valor previo del registro D2
					MOVE.L 			-40(A6),D3 					* Se restaura el valor previo del registro D3
					MOVE.L 			-44(A6),D4 					* Se restaura el valor previo del registro D4
					MOVE.L 			-48(A6),D5 					* Se restaura el valor previo del registro D5
					MOVE.L 			-52(A6),D6 					* Se restaura el valor previo del registro D6
					MOVE.L 			-56(A6),D7 					* Se restaura el valor previo del registro D7
					UNLK 			A6
					RTE

**************************** FIN RTI ***************************************************************************************

**************************** PROGRAMA PRINCIPAL ****************************************************************************

PPAL:				

BUFFER: 			DS.B 			2100  						* Buffer para lectura y escritura de caracteres
CONTL:  			DC.W    		0     						* Contador de líneas
CONTC: 				DC.W    		0     						* Contador de caracteres
DIRLEC: 			DC.L    		0     						* Dirección de lectura para SCAN
DIRESC: 			DC.L    		0    						* Dirección de escritura para PRINT
TAME:   			DC.W    		0     						* Tamaño de escritura para PRINT
DESA:   			EQU     		0     						* Descriptor línea A
DESB:   			EQU     		1     						* Descriptor línea B
NLIN:   			EQU     		4    						* Número de líneas a leer
TAML:   			EQU     		11   						* Tamaño de línea para SCAN
TAMB:  				EQU     		10    						* Tamaño de bloque para PRINT

INICIO: 			* Manejadores de excepciones
					MOVE.L   		#BUS_ERROR,8   				* Bus error handler
					MOVE.L   		#ADDRESS_ER,12 				* Address error handler
					MOVE.L   		#ILLEGAL_IN,16 				* Illegal instruction handler
					MOVE.L   		#PRIV_VIOLT,32 				* Privilege violation handler

					BSR            	INIT    					* Inicia el controlador
					MOVE.W 			#$2000,SR 					* Permite interrupciones
*					JMP 			PR45						* Prueba a la que se quiere saltar

*PLL:				MOVE.L 			#0,D5
*PLLBUC:				CMP.L 			#2000,D5
*					BEQ 			PLLFIN
*					MOVE.L 			#0,D0
*					MOVE.B 			#5,D1
*					BSR 			ESCCAR
*					ADD.L 			#1,D5
*					JMP 			PLLBUC
*PLLFIN:				MOVE.L 			#0,D0
*					BSR 			LEECAR
*					MOVE.L 			#0,D0
*					BSR 			LEECAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#3,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#13,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					BSR 			LINEA
*					JMP 			FIN


*PLVEL:				MOVE.L 			#0,D5
*PLVELBUC:			CMP.L 			#2000,D5
*					BEQ 			PLVELSIG
*					MOVE.L 			#0,D0
*					MOVE.B 			#5,D1
*					BSR 			ESCCAR
*					ADD.L 			#1,D5
*					ADD.L 			#1,D6
*					JMP 			PLVELBUC
*PLVELSIG:			MOVE.L 			#0,D5
*PLVELBC2:			CMP.L 			#1000,D5
*					BEQ 			PLVELULT
*					MOVE.L 			#0,D0
*					BSR 			LEECAR
*					ADD.L 			#1,D5
*					SUB.L 			#1,D6
*					JMP 			PLVELBC2
*PLVELULT: 			MOVE.L 			#0,D5
*PLVELBC3:			CMP.L 			#1000,D5
*					BEQ 			PLVELFIN
*					MOVE.L 			#0,D0
*					MOVE.B 			#4,D1
*					BSR 			ESCCAR
*					ADD.L 			#1,D5
*					ADD.L 			#1,D6
*					JMP 			PLVELBC3
*PLVELFIN: 			JMP 			FIN

	
*PLE:				MOVE.L 			#2,D0
*					MOVE.B 			#5,D1
*					BSR 			ESCCAR
*					MOVE.L 			#2,D0
*					BSR 			LEECAR
*					JMP				FIN

*PES:				MOVE.W 			#0,D5
*					MOVE.W 			#0,D6
*PES_BUC:			CMP.W 			#2000,D5
*					BEQ 			PES_FIN
*					MOVE.L 			#2,D0
*					MOVE.B 			#5,D1
*					BSR 			ESCCAR
*					ADD.L 			#1,D5
*					ADD.L 			#1,D6					
*					JMP 			PES_BUC
*PES_FIN:			MOVE.L 			#2,D0
*					MOVE.B 			#3,D1
*					BSR 			ESCCAR
*					JMP				FIN


PR48:				MOVE.L   		#BUFFER,DIRESC 				* Dirección de lectura = comienzo del buffer
					MOVE.L 			#BUFFER,A5
					MOVE.L 			#0,D5

PR48_BUC:			MOVE.B  		#$31,(A5)+					
					MOVE.W   		#1,-(A7)   					* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto A
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT
					SUBA 			#1,A5
					ADD.L 			#1,D5
					CMP.L 			#10,D5
					BNE 			PR48_BUC

					MOVE.B  		#$D,(A5)+						
					MOVE.W   		#1,-(A7)   					* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto A
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT
					
					JMP 			FIN


PR47:				MOVE.L   		#BUFFER,DIRESC 				* Dirección de lectura = comienzo del buffer
					MOVE.L 			#BUFFER,A5

					MOVE.B  		#$31,(A5)+
					MOVE.B 			#$D,(A5)+
					MOVE.B  		#$31,(A5)+
					MOVE.B 			#$D,(A5)+
					MOVE.B  		#$31,(A5)+
					MOVE.B  		#$31,(A5)+
					MOVE.B  		#$31,(A5)+
					MOVE.B  		#$31,(A5)+
					MOVE.B  		#$31,(A5)+
					MOVE.B  		#$31,(A5)+
					MOVE.B  		#$31,(A5)+
					MOVE.B  		#$31,(A5)+
					MOVE.B  		#$31,(A5)+
					MOVE.B  		#$31,(A5)+
					
					MOVE.W   		#14,-(A7)   				* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto B
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT

					JMP 			FIN


PR46:				MOVE.L   		#BUFFER,DIRESC 				* Dirección de lectura = comienzo del buffer
					MOVE.L 			#BUFFER,A5
					MOVE.L 			#0,D5

					MOVE.B  		#$31,(A5)+
					MOVE.B 			#$D,(A5)+
					MOVE.B  		#$31,(A5)+

					MOVE.W   		#3,-(A7)   					* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto A
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT

					JMP 			FIN


PR45:				MOVE.L   		#BUFFER,DIRESC 				* Dirección de lectura = comienzo del buffer
					MOVE.L 			#BUFFER,A5
					MOVE.L 			#0,D5

PR45_BUC:			MOVE.B  		#$31,(A5)+
					MOVE.B  		#$32,(A5)+
					MOVE.B  		#$33,(A5)+
					MOVE.B  		#$34,(A5)+
					MOVE.B  		#$35,(A5)+
					MOVE.B  		#$36,(A5)+
					MOVE.B  		#$37,(A5)+
					MOVE.B  		#$38,(A5)+
					MOVE.B  		#$39,(A5)+
					MOVE.B 			#$30,(A5)+
					ADD.L 			#1,D5
					CMP.L 			#100,D5
					BNE 			PR45_BUC
					MOVE.B  		#$D,(A5)+

					MOVE.W   		#1001,-(A7)   				* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto A
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT
					
					MOVE.W   		#1001,-(A7)   				* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto A
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT

					MOVE.W   		#1001,-(A7)   				* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto A
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT

					JMP 			FIN


PR44:				MOVE.L   		#BUFFER,DIRESC 				* Dirección de lectura = comienzo del buffer
					MOVE.L 			#BUFFER,A5
					MOVE.L 			#0,D5

PR44_BUC:			MOVE.B  		#$31,(A5)+
					MOVE.B  		#$32,(A5)+
					MOVE.B  		#$33,(A5)+
					MOVE.B  		#$34,(A5)+
					MOVE.B  		#$35,(A5)+
					MOVE.B  		#$36,(A5)+
					MOVE.B  		#$37,(A5)+
					MOVE.B  		#$38,(A5)+
					MOVE.B  		#$39,(A5)+
					MOVE.B 			#$30,(A5)+
					ADD.L 			#1,D5
					CMP.L 			#10,D5
					BNE 			PR44_BUC
					MOVE.B  		#$D,(A5)+
		   			
		   			MOVE.W   		#101,-(A7)   				* Tamaño de escritura
					MOVE.W   		#1,-(A7)   					* Puerto B
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT
					
					MOVE.W   		#101,-(A7)   				* Tamaño de escritura
					MOVE.W   		#1,-(A7)   					* Puerto B
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT

					MOVE.W   		#101,-(A7)   				* Tamaño de escritura
					MOVE.W   		#1,-(A7)   					* Puerto B
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT

					MOVE.W   		#101,-(A7)   				* Tamaño de escritura
					MOVE.W   		#1,-(A7)   					* Puerto B
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT

					JMP 			FIN


PR43:				MOVE.L   		#BUFFER,DIRESC 				* Dirección de lectura = comienzo del buffer
					MOVE.L 			#BUFFER,A5

					MOVE.B  		#$31,(A5)+
					MOVE.B  		#$32,(A5)+
					MOVE.B  		#$33,(A5)+
					MOVE.B  		#$34,(A5)+
					MOVE.B  		#$35,(A5)+
					MOVE.B  		#$36,(A5)+
					MOVE.B  		#$37,(A5)+
					MOVE.B  		#$38,(A5)+
					MOVE.B  		#$39,(A5)+
					MOVE.B 			#$30,(A5)+
					MOVE.B  		#$D,(A5)+
		   			
		   			MOVE.W   		#11,-(A7)   				* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto A
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT
					
					MOVE.W   		#11,-(A7)   				* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto A
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT

					MOVE.W   		#11,-(A7)   				* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto A
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT

					MOVE.W   		#11,-(A7)   				* Tamaño de escritura
					MOVE.W   		#0,-(A7)   					* Puerto A
					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
					BSR      		PRINT

					JMP 			FIN



*EBE:				MOVE.L 			#BUFFER,A5  				
*					MOVE.B  		#$31,(A5)+
*					
*					MOVE.L   		#BUFFER,DIRESC 				* Dirección de lectura = comienzo del buffer
*		   			MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*					ADD.L 			#1,DIRESC
*		   			
*					MOVE.B  		#$32,(A5)+
*					MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*					ADD.L 			#1,DIRESC
*		   			
*					MOVE.B  		#$33,(A5)+
*					
*		   			MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*					ADD.L 			#1,DIRESC
*
*					MOVE.B  		#$34,(A5)+
*					
*					MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*					ADD.L 			#1,DIRESC
*
*					MOVE.B  		#$35,(A5)+
*					
*					MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*					ADD.L 			#1,DIRESC
*
*					MOVE.B  		#$36,(A5)+
*					
*					MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*					ADD.L 			#1,DIRESC
*
*					MOVE.B  		#$37,(A5)+
*					
*					MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*					ADD.L 			#1,DIRESC
*
*					MOVE.B  		#$38,(A5)+
*					
*					MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*					ADD.L 			#1,DIRESC
*
*					MOVE.B  		#$39,(A5)+
*					
*					MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*					ADD.L 			#1,DIRESC
*
*					MOVE.B  		#$D,(A5)+
*					
*					MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*
*					BSR 			FIN
*
*					MOVE.B  		#$31,(A5)+
*					MOVE.B  		#$32,(A5)+
*					MOVE.B  		#$33,(A5)+
*					MOVE.B  		#$34,(A5)+
*					MOVE.B  		#$35,(A5)+
*					MOVE.B  		#$36,(A5)+
*					MOVE.B  		#$37,(A5)+
*					MOVE.B  		#$38,(A5)+
*					MOVE.B  		#$39,(A5)+
*					MOVE.B  		#$D,(A5)+
*					MOVE.B  		#$30,(A5)+
*					MOVE.B  		#$31,(A5)+
*					MOVE.B  		#$32,(A5)+
*					MOVE.B  		#$33,(A5)+
*					MOVE.B  		#$34,(A5)+
*					MOVE.B  		#$35,(A5)+
*					MOVE.B  		#$36,(A5)+
*					MOVE.B  		#$37,(A5)+
*					MOVE.B  		#$38,(A5)+
*					MOVE.B  		#$39,(A5)+
*					MOVE.B  		#$D,(A5)+
*					MOVE.B  		#$30,(A5)+
*					MOVE.B  		#$31,(A5)+
*					MOVE.B  		#$32,(A5)+
*					MOVE.B  		#$33,(A5)+
*					MOVE.B  		#$34,(A5)+
*					MOVE.B  		#$35,(A5)+
*					MOVE.B  		#$36,(A5)+
*					MOVE.B  		#$37,(A5)+
*					MOVE.B  		#$38,(A5)+
*					MOVE.B  		#$39,(A5)+
*					MOVE.B  		#$D,(A5)+
*					MOVE.B  		#$30,(A5)+
*					MOVE.B  		#$31,(A5)+
*					MOVE.B  		#$32,(A5)+
*					MOVE.B  		#$33,(A5)+
*					MOVE.B  		#$34,(A5)+
*					MOVE.B  		#$35,(A5)+
*					MOVE.B  		#$36,(A5)+
*					MOVE.B  		#$37,(A5)+
*					MOVE.B  		#$38,(A5)+
*					MOVE.B  		#$39,(A5)+
*					MOVE.B  		#$D,(A5)+
*
*PPRINT:				MOVE.L   		#BUFFER,DIRESC 				* Dirección de lectura = comienzo del buffer
*		   			MOVE.W   		#1,-(A7)   	  				* Tamaño de escritura
*					MOVE.W   		#0,-(A7)   					* Puerto A
*					MOVE.L   		DIRESC,-(A7)   				* Dirección de lectura
*					BSR      		PRINT
*					BSR 			FIN

*BUCPR:				MOVE.W 			#0,CONTC 					* Inicializa contador de caracteres
*					MOVE.W 			#NLIN,CONTL 				* Inicializa contador de líneas
*					MOVE.L 			#BUFFER,DIRLEC 				* Dirección de lectura = comienzo del buffer
*OTRAL:				MOVE.W 			#TAML,-(A7) 				* Tamaño máximo de la línea
*					MOVE.W 			#DESB,-(A7) 				* Puerto A
*					MOVE.L 			DIRLEC,-(A7) 				* Dirección de lectura
*ESPL:				BSR 			SCAN
*					CMP.L 			#0,D0
*					BEQ 			ESPL 						* Si no se ha leído una línea se intenta de nuevo
*					ADD.L 			#8,A7 						* Restablece la pila
*					ADD.L 			D0,DIRLEC 					* Calcula la nueva dirección de lectura
*					ADD.W 			D0,CONTC 					* Actualiza el número de caracteres leídos
*					SUB.W 			#1,CONTL 					* Actualiza el número de líneas leídas. Si no
*					BNE 			OTRAL 						* se han leído todas las líneas se vuelve a leer
*					MOVE.L 			#BUFFER,DIRLEC 				* Dirección de lectura = comienzo del buffer
*OTRAE:				MOVE.W 			#TAMB,TAME 					* Tamaño de escritura = Tamaño de bloque
*ESPE:				MOVE.W 			TAME,-(A7) 					* Tamaño de escritura
*					MOVE.W 			#DESB,-(A7) 				* Puerto B
*					MOVE.L 			DIRLEC,-(A7) 				* Dirección de lectura
*					BSR 			PRINT
*					ADD.L 			#8,A7 						* Restablece la pila
*					ADD.L 			D0,DIRLEC 					* Calcula la nueva dirección del buffer
*					SUB.W 			D0,CONTC 					* Actualiza el contador de caracteres
*					BEQ 			SALIR 						* Si no quedan caracteres se acaba
*					SUB.W 			D0,TAME 					* Actualiza el tamaño de escritura
*					BNE 			ESPE 						* Si no se ha escrito todo el bloque se insiste
*					CMP.W 			#TAMB,CONTC 				* Si el número de caracteres que quedan es menor que él
*
*  					BHI 			OTRAE 						* Siguiente bloque
* 					MOVE.W 			CONTC,TAME
*					BRA 			ESPE 						* Siguiente bloque
*
*SALIR: 			BRA 			FIN

* Subrutina de escritura de BI (modificar D0 para buffer y D1 para caracter, además de la cantidad a escribir).
*EBI: 				MOVE.W 			#0,D5
*EBI_BUC:			CMP.W 			#4,D5
*					BEQ 			PPRINT
*					MOVE.L 			#0,D0
*					MOVE.B 			#$30,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#$31,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#$32,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#$33,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#$34,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#$35,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#$36,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#$37,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#$38,D1
*					BSR 			ESCCAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#$39,D1
*					BSR 			ESCCAR					
*					MOVE.L 			#0,D0
*					MOVE.B 			#$D,D1
*					BSR 			ESCCAR
*					ADD.W 			#1,D5
*					JMP 			EBI_BUC
*EBI_SIG:			MOVE.L 			#0,D0
*					MOVE.B 			#$D,D1
*					BSR 			ESCCAR
*					JMP 			PSCAN
*
* Prueba de SCAN
* Devolverá en D0 el número de caracteres leídos según se modifique la subrutina EBIA y escribirá en el buffer
* que se le pasa como parámetro de salida los caracteres que se pongan en esta subrutina
*PSCAN:  			MOVE.W   		#0,CONTC       				* Inicializa contador de caracteres
*					MOVE.W		   	#NLIN,CONTL    				* Inicializa contador de lineas
*					MOVE.L   		#BUFFER,DIRLEC 				* Dirección de lectura = comienzo del buffer					
*		  			MOVE.W   		#20,-(A7)    				* Tamaño máximo de la línea
*					MOVE.W   		#2,-(A7)    				* Puerto A
*					MOVE.L   		DIRLEC,-(A7)   				* Dirección de lectura
*		   			BSR      		SCAN
*					BSR 			FIN

*PLL:				MOVE.L 			#0,D5
*PLLBUC:				CMP.L 			#2000,D5
*					BEQ 			PLLFIN
*					MOVE.L 			#0,D0
*					MOVE.B 			#5,D1
*					BSR 			ESCCAR
*					ADD.L 			#1,D5
*					JMP 			PLLBUC
*PLLFIN:				MOVE.L 			#0,D0
*					BSR 			LEECAR
*					MOVE.L 			#0,D0
*					MOVE.B 			#4,D1
*					BSR 			ESCCAR
*					JMP 			FIN


* Prueba de llenado de buffer:
* Debe devolver en D0 un -1, ya que se hacen 2001 escrituras y 0 lecturas
*PLL:				MOVE.W 			#0,D5
*PLLBUC:				CMP.W 			#2000,D5
*					BEQ 			PLL_SIG
*					MOVE.L 			#2,D0
*					MOVE.B 			#9,D1
*					BSR 			ESCCAR
*					ADD.W 			#1,D6
*					ADD.W 			#1,D5
*					JMP 			PLLBUC
*PLL_SIG:			MOVE.L 			#2,D0
*					MOVE.B 			#4,D1
*					BSR 			ESCCAR
*					JMP 			FIN

* Prueba de vaciado de buffer:
* Debe devolver en D0 un -1, ya que se hacen 2 escrituras y 3 lecturas
*PV:					MOVE.L 			#2,D0
*					MOVE.B 			#9,D1
*					BSR 			ESCCAR
*					MOVE.L 			#2,D0
*					MOVE.B 			#4,D1
*					BSR 			ESCCAR
*					MOVE.L 			#2,D0
*					BSR 			LEECAR
*					MOVE.L 			#2,D0
*					BSR 			LEECAR
*					MOVE.L 			#2,D0
*					BSR 			LEECAR
*					JMP 			FIN

* Prueba de llenado de buffer y vaciado de buffer:
*PLV:				MOVE.W 			#0,D5
*PLVBUC:				CMP.W 			#1999,D5
*					BEQ 			PLV_SIG
*					MOVE.L 			#1,D0
*					MOVE.B 			#9,D1
*					BSR 			ESCCAR
*					ADD.W 			#1,D6
*					ADD.W 			#1,D5
*					JMP 			PLVBUC
*PLV_SIG:			MOVE.L 			#1,D0
*					MOVE.B 			#4,D1
*					BSR 			ESCCAR
*					MOVE.W 			#0,D5
*PLVBUC2:			CMP.W 			#1999,D5
*					BEQ 			PLV_FIN
*					MOVE.L 			#1,D0
*					BSR 			LEECAR
*					ADD.W 			#1,D5
*					JMP 			PLVBUC2
*PLV_FIN:			MOVE.L 			#1,D0
*					BSR 			LEECAR
*					ADD.W 			#1,D5
*					JMP				FIN


* Prueba de llenado de buffer y cuenta:
* Debe devolver en D0 un 2000
*PLI:				MOVE.W 			#0,D5
*PLIBUC:				CMP.W 			#1999,D5
*					BEQ 			PLI_SIG
*					MOVE.L 			#2,D0
*					MOVE.B 			#9,D1
*					BSR 			ESCCAR
*					ADD.W 			#1,D5
*					JMP 			PLIBUC
*PLI_SIG:			MOVE.L 			#2,D0
*					MOVE.B 			#13,D1
*					BSR 			ESCCAR
*					MOVE.L 			#2,D0
*					BSR 			LINEA
*					JMP 			FIN

* Prueba de escritura de 1000 caracteres, lectura de 500 y cuenta:
* Debe devolver en D0 un 500
*PLI2:				MOVE.W 			#0,D5
*PLI2BUC:			CMP.W 			#999,D5
*					BEQ 			PLI2_SIG
*					MOVE.L 			#2,D0
*					MOVE.B 			#9,D1
*					BSR 			ESCCAR
*					ADD.W 			#1,D5
*					JMP 			PLI2BUC
*PLI2_SIG:			MOVE.L 			#2,D0
*					MOVE.B 			#13,D1
*					BSR 			ESCCAR
*					MOVE.W 			#0,D5
*PLI2BUC2:			CMP.W 			#500,D5
*					BEQ 			PLI2FIN
*					MOVE.L 			#2,D0
*					BSR 			LEECAR
*					ADD.W 			#1,D5
*					JMP 			PLI2BUC2
*PLI2FIN:			MOVE.L 			#2,D0
*					BSR 			LINEA
*					JMP				FIN

* Prueba de llenado de buffer, lectura de 1000 caracteres, escritura de 500 y cuenta:
* Debe devolver en D0 un 1500
*PLI3:				MOVE.W 			#0,D5
*PLI3BUC:			CMP.W 			#2000,D5
*					BEQ 			PLI3SIG
*					MOVE.L 			#2,D0
*					MOVE.B 			#9,D1
*					BSR 			ESCCAR
*					ADD.W 			#1,D5
*					JMP 			PLI3BUC
*PLI3SIG:			MOVE.W 			#0,D5
*PLI3BUC2:			CMP.W 			#1000,D5
*					BEQ 			PLI3SIG2
*					MOVE.L 			#2,D0
*					BSR 			LEECAR
*					ADD.W 			#1,D5
*					JMP 			PLI3BUC2
*PLI3SIG2:			MOVE.L 			#0,D5
*PLI3BUC3:			CMP.W 			#499,D5
*					BEQ 			PLI3FIN
*					MOVE.L 			#2,D0
*					MOVE.B 			#9,D1
*					BSR 			ESCCAR
*					ADD.W 			#1,D5
*					JMP 			PLI3BUC3
*PLI3FIN:			MOVE.L 			#2,D0
*					MOVE.B 			#13,D1
*					BSR 			ESCCAR
*					MOVE.L 			#2,D0
*					BSR 			LINEA
*					JMP				FIN

*PS1CT0:				MOVE.W 			#0,-(A7)
*					MOVE.W 			#1,-(A7)
*					MOVE.L 			#DIRLEC,-(A7)
*					BSR 			SCAN
*					JMP 			FIN

FIN:   				BREAK										* Fin ejecución de programa

BUS_ERROR:  		BREAK 										* Bus error handler
					NOP
ADDRESS_ER: 		BREAK 										* Address error handler
					NOP
ILLEGAL_IN: 		BREAK 										* Illegal instruction handler
					NOP
PRIV_VIOLT: 		BREAK 										* Privilege violation handler
					NOP

**************************** FIN PROGRAMA PRINCIPAL ************************************************************************
