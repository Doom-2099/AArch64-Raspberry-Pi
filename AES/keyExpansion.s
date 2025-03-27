.section .text

/* 
 * -----------------------------------------
 * ---- Funcion Generadora De Subclaves ----
 * -----------------------------------------
 */
.type expansionKey, %function
.global expansionKey
expansionKey:
    STP X29, X30, [SP, -16]!

    LDR x0, =key
    LDR w1, [x0, #12]
    ROR w1, w1, #24
    STR w1, [x0, #12]

    LDR x0, =key
    ADD x0, x0, #172
    MOV x1, #4
    BL subBytes

    

    

    LDP X29, X30, [SP], 16
    RET
    .size expansionKey, (. - expansionKey)