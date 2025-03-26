.section .text

/* 
 * -----------------------------------------
 * ---- Funcion Generadora De Subclaves ----
 * -----------------------------------------
 */

.type mixColumn, %function
.global mixColumn
mixColumn:
    STP x29, x30, [SP, #-16]!

    // Codigo Mix Columnas
    

    LDP x29, x30, [SP], #16
    RET
    .size mixColumn, (. - mixColumn)