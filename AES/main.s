// CADENAS DE TEXTO
.section .data
    msg_txt:         .asciz "\nIngrese El Mensaje A Cifrar: " 
        lenMsgTxt = . - msg_txt

    msg_key:         .asciz "\nIngrese La Clave Para El Cifrado: "
        lenMsgKey = . - msg_key

    key_err_msg:     .asciz "El Valor Ingresado Para La Llave Es Incorrecto"
        lenKeyErr = . - key_err_msg
// -----------------------------------------------------------------------------------------------------------------

// IMPORT DE CONSTANTES
.include "constants.s"
// -----------------------------------------------------------------------------------------------------------------

// RESERVACION DE MEMORIA
.section .bss
    .global matState
    matState:       .space 16, 0         // Matriz de estado del texto en claro de 128 bits

    .global key
    key:            .space 176, 0         // Matriz de llave inicial de 128 bits

    .global criptograma
    criptograma:    .space 16, 0         // Buffer para almacenar el resultado de la encriptacion

    buffer:         .space 33, 0         // Buffer utilizado para almacenar la entrada del usuario por consola

    dummy:          .space 8, 0          // Buffer para descartar caracteres extra
// -----------------------------------------------------------------------------------------------------------------

// IMPORT DE MACROS
.include "macros.s"
// -----------------------------------------------------------------------------------------------------------------

// CODIGO FUENTE
.section .text

/* 
 * ---------------------------------------
 * --- Funcion Colocar Bytes En Matriz ---
 * ---------------------------------------
 */
.type   convertText, %function
.global convertText
convertText:                                    // Parametros x1: Matriz donde se almacenaran los bytes
    STP x29, x30, [SP, #-16]!

    LDR x0, =buffer                             // Cargar direccion del buffer para leer los bytes
    MOV x9, #0                                  // Contador de columnas
    i_col:
        MOV x10, #0                             // Contador de filas
        j_row:
            LDRB w3, [x0], #1                   // Cargar el bytes desde el buffer
                                                // Aplicar operacion de Column Major para obtener el index
            MOV x5, #4                          
            MUL x5, x5, x10                     // R <- Row Index * 4
            ADD x5, x5, x9                      // Index <- R + Column
            
            STRB w3, [x1, x5]                   // Almacenar el byte del registro 3 en la direccion x1 + x5

            ADD x10, x10, #1                    // Incrementar el contador de filas
            CMP x10, #4                         // Si se ha llegado a las 4 filas, terminar ciclo
            BNE j_row

        ADD x9, x9, #1                          // Incrementar el contador de columnas
        CMP x9, #4                              // Si se ha llegado a las 4 columnas, terminar el ciclo
        BNE i_col

    LDP x29, x30, [SP], #16
    RET
    .size convertText, (. - convertText)

/* 
 * ----------------------------------------
 * --- Funcion Convertir Cadena A Bytes ---
 * ----------------------------------------
 */
.type   convertKey, %function
.global convertKey
convertKey:
    STP x29, x30, [SP, #-16]!

    LDR x0, =buffer                         // Cargar la direccion del buffer con la llave en texto
    LDR x4, =buffer                         // Cargar la direccion de inicio del buffer para reemplazar los bytes
    MOV x3, #0                              // Contador de caracteres procesados

    loop_key:                               // Etiqueta del ciclo
        LDRB w1, [x0], #1                   // Cargar un byte del buffer
        CBZ w1, end_convert_key             // Si tiene un valor de cero, ya se proceso la cadena y se envia al final

        CMP w1, #48                         // Si el caracter es menor a 48 == "0", mostrar un error (x < 48)
        BLO error_key

        CMP w1, #57                         // Si el caracter es menor o igual a 57 == "9", convertir numero (x >= 48 && x <= 57)
        BLS convertNum

        CMP w1, #65                         // Si el caracter es menor a 65 == "A", mostrar un error (x > 57 && x < 65)
        BLO error_key

        CMP w1, #70                         // Si el caracter es menor o igual a 70 == "F", convertir hexadecimal (x >= 65 && x <= 70)
        BLS convertHex

        B error_key                         // Cualquier otra condicion, mostrar un error (x > 70)

        convertNum:                         
            SUB w1, w1, #48                 // Restar 48 == "0", para obtener el valor del digito
            TBNZ w3, #0, desp_bits          // Si el caracter es impar, hacer ajuste de bits
            MOV w2, w1                      // Caso contrario, copiar el numero al registro 2
            ADD w3, w3, #1                  // Aumentar el contador de caracteres
            B loop_key                      // Continuar con el ciclo

        convertHex:
            SUB w1, w1, #65                 // Restar 65 == "A", para obtener el valor del digito
            ADD w1, w1, #10                 // Sumar 10 unidades para cumplir con el rango de hexadecimales
            TBNZ w3, #0, desp_bits          // Si el caracter es impar, hacer ajuste de bits
            MOV w2, w1                      // Caso contrario, copiar el numero al registro 2
            ADD w3, w3, #1                  // Aumentar el contador de caracteres                    // Caso contrario, copiar el numero al registro 2
            B loop_key                      // Continuar con el ciclo

        desp_bits:
            LSL w2, w2, #4                  // Desplazar 4 bits a la izquierda 0000 xxxx -> xxxx 0000 
            ORR w1, w1, w2                  // Realizar operacion OR del numero en registro 1 con registro 2
                                            // r1 -> 0000 yyyy | r2 -> xxxx 0000 => xxxx yyyy
            BIC w2, w2, w2                  // Limpiar valor del registro 2
            STRB w1, [x4], #1               // Almacenar byte dentro del buffer
            ADD w3, w3, #1                  // Aumentar el contador de caracteres
            B loop_key                      // Continuar con el ciclo
            
    error_key:
        print 1, key_err_msg, lenKeyErr     // Funcion para imprimir en consola
    
    end_convert_key:
        STRB w1, [x4]                       // Almacenar el byte null para indicar el fin de la llave de bytes
        LDP x29, x30, [SP], #16
        RET

    .size convertKey, (. - convertKey)

/* 
 * ----------------------------
 * --- Funcion Encriptacion ---
 * ----------------------------
 */
.type   encript, %function
.global encript
encript:
    STP x29, x30, [SP, #-16]!

    MOV x0, =matState
    MOV x1, =key
    BL addRoundKey

    MOV x20, #9
    MOV x19, #1
    loop_rondas:
        LDR x0, =matState
        MOV x1, #16
        BL subBytes

        BL shiftRows

        // BL mixColumns

        LDR x0, =matState
        LDR x1, =key
        MOV x2, #16
        MUL x2, x2, x19
        ADD x1, x1, x2
        BL addRoundKey

        ADD x19, x19, #1
        SUB x20, x20, #1
        CBNZ x20, loop_rondas

    LDR x0, =matState
    MOV x1, #16
    BL subBytes

    BL shiftRows

    LDR x0, =matState
    LDR x1, =key
    ADD x1, x2, #160
    BL addRoundKey

    // print mensaje cifrado
    
    LDP x29, x30, [SP], #16
    RET
    .size encript, (. - encript)

/* 
 * -------------------------
 * --- Funcion Principal ---
 * -------------------------
 */
.type   _start, %function
.global _start
_start:
    print 1, msg_txt, lenMsgTxt // Imprimir mensaje en consola
    read 0, buffer, #16         // Si no es un salto de linea, continuar con el ciclo

    discard_1:
        read 0, dummy, #1
        bytesAvailable dummy
        LDR x2, =dummy
        LDR x2, [x2]
        CBNZ x2, discard_1

    print 1, buffer, #16        // Imprimir cadena leida en consola

    LDR x1, =matState           // Cargar direccion de la matriz de estado
    BL convertText              // Llamar a la funcion encargada de posicionar los bytes en la matriz de estado

    //print 1, matState, #16
    print 1, msg_key, lenMsgKey     // Imprimir mensaje en consola
    read 0, buffer, #32             // Funcion para leer desde la consola

    discard_2:
        read 0, dummy, #1
        bytesAvailable dummy
        LDR x2, =dummy
        LDR x2, [x2]
        CBNZ x2, discard_2

    print 1, buffer, #32        // Imprimir cadena leida en consola

    BL convertKey               // Funcion para convertir la cadena de la llave en bytes hexadecimales

    LDR x1, =key                // Cargar direccion de la matriz de la llave
    BL convertText              // Llamar a la funcion encargada de posicionar los bytes en la matriz de la llave 

    //print 1, key, #16

    BL encript                  // Funcion que inicia la encriptacion de los datos
    print 1, criptograma, #16   // Imprimir criptograma en consola

    MOV x0, #0                  // Finalizar con etado 0 (OK)
    MOV x8, #93                 // Terminar la ejecucion del programa
    SVC #0

    .size _start, (. - _start)

