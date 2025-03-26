.section .text

/* 
 * -----------------------------------
 * ---- Funcion Rotacion De Bytes ----
 * -----------------------------------
 */
.type shiftRow, %function
.global shiftRow
shiftRow:
    STP X29, X30, [SP, -16]!

    LDR x0, =matState

    MOV x2, #8                      // Numero de bits que se rotaran
    MOV x3, #3                      // Numero de veces que se ejecutara el loop
    MOV x4, #32                     // Longitud del registro a rotar

    loop_shiftRow:
        ADD x0, x0, #4              // Se cambia de fila, desplazandose 4 bytes 
        LDR w1, [x0]                // Se carga la fila al registro w1
        ROR w1, w1, x2              // Se hace la rotacion hacia la derecha de los bits
        STR w1, [x0]                // Se almacena el valor rotado de la fila
        ADD x2, x2, #8              // Se aumenta el numero de bits a rotar
        SUB x3, x3, #1              // Se disminuye el numero de veces que se ejecutara el loop
        CBNZ loop_shiftRow          // Se verifica si se ha terminado de rotar todas las filas

    LDP X29, X30, [SP], 16
    RET
    .size shiftRow, (. - shiftRow)