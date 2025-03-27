.section .text


/* 
 * -------------------------------
 * ---- Funcion Add Round Key ----
 * -------------------------------
 */
.type addRoundKey, %function
.global addRoundKey
addRoundKey:                    // Parametros x0: matriz de estado, x1: llave
    STP x29, x30, [SP, #-16]!

    MOV x5, #16
    recorrido_matriz:
        LDRB w2, [x1], #1
        LDRB w3, [x0]

        EOR w3, w3, w2
        STRB w3, [x0], #1
        SUBS x5, x5, #1
        CBNZ x5, recorrido_matriz
    
    LDP x29, x30, [SP], #16
    RET
    .size addRoundKey, (. - addRoundKey)