.section .text


/* 
 * ----------------------------------------
 * ---- Funcion Reemplazar Bytes S-Box ----
 * ----------------------------------------
 */
.type subBytes, %function
.global subBytes
subBytes:
    STP x29, x30, [SP, #-16]!

    LDR x3, =Sbox                   // Cargar la direccion de la S-Box
    LDR x6, =matState               // Cargar la direccion de la matriz de estado
    MOV x7, #16                     // Inicializar el contador de recorrido de la matriz de estado

    recorrido_matriz:
        LDRB w0, [x6]               // Cargar el valor de la matriz de estado
        
        AND x1, x0, #0xF0           // Extraer los 4 bits mas significativos || Rows
        AND x2, x0, #0x0F           // Extraer los 4 bits menos significativos || Columns

        MOV x5, #4                  // Celdas Por Fila
        MUL x5, x5, x2              // Multiplicar cuantas filas hay que recorrer
        ADD x5, x5, x1              // Sumar las columnas a recorrer

        LDRB w4, [x3, x5]            // Cargar el valor de la S-Box
        STRB w4, [x6], #1            // Guardar el valor en la matriz de estado 
        SUBS x7, x7, #1              // Decrementar el contador de recorrido alterando las banderas
        CBNZ recorrido_matriz         // Si no se recorrieron todas las celdas, repetir el proceso

    LDP x29, x30, [SP], #16
    RET
    .size subBytes, (. - subBytes)