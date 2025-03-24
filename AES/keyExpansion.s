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

    // Codigo expansion de claves

    LDP X29, X30, [SP], 16
    RET
    .size expansionKey, (. - expansionKey)