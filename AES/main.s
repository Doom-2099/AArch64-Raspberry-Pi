.section .rodata
    msg_txt:            .asciz "\nIngrese El Mensaje A Cifrar: "
    msg_key:            .asciz "\nIngrese La Clave Para El Cifrado: "
    format_str:         .asciz "%16s"
    key_err_msg:        .asciz "El Valor Ingresado Para La Llave Es Incorrecto"

.section .bss
    .global matState
    matState:       .space 16, 0

    .global key
    key:            .space 16, 0

    .global criptograma
    criptograma:    .space 16, 0


    buffer:         .space 17, 0

.section .text

/* 
 * Posicionar Cadena En Matriz de Estado
 */
.type   convertText, %function
convertText:    // x1 -> matriz
    STP x29, x30, [SP, #-16]!

    // Column Major => 4(J) + I
    LDR x0, =buffer

    MOV x9, #0
    i_row:

        MOV x10, #0
        j_col:
            LDRB w3, [x0], #1
            
            MOV x5, #4
            MUL x5, x5, x10
            ADD x5, x5, x9
            
            STRB w3, [x5]

            ADD x10, x10, #1
            CMP x10, #4
            BNE j_col

        ADD x9, x9, #1
        CMP x9, #4
        BNE i_row

    LDP x29, x30, [SP], #16
    RET
    .size convertText, (. - convertText)

/* 
 * Convertir Cadena A Bytes
 */
.type   convertKey, %function
convertKey:
    STP x29, x30, [SP, #-16]!

    LDR x0, =buffer

    loop_key:
        LDRB w1, [x0]
        CBZ w1, end_convert_key

        CMP w1, #48
        BLS error_key

        CMP w1, #58
        BLS convertNum

        CMP w1, #65
        BLS error_key

        CMP w1, #71
        BLS convertHex

        convertNum:
            SUB w1, w1, #48
            STRB w1, [x0], #1
            B loop_key

        convertHex:
            SUB w1, w1, #65
            STRB w1, [x0], #1
            B loop_key
    
    error_key:
        LDR x0, =key_err_msg
        BL printf 
    
    end_convert_key:
        LDP x29, x30, [SP], #16
        RET

    .size convertKey, (. - convertKey)

/* 
 * Funcion Que Da Inicio A La Encriptacion
 */
.type encript, %function
encript:
    STP x29, x30, [SP, #-16]!

    

    LDP x29, x30, [SP], #16
    RET
    .size encript, (. - encript)

/* 
 * Funcion Principal
 */
.type   main, %function
.global main
main:
    // Imprimir mensaje para pedir texto a cifrar 
    LDR x0, =msg_txt
    BL printf


    // Lectura Del Los Datos Ingresados Por El Usuario
    // (Unicamente Tomara 16 caracteres == 16 bytes == 128 bits)
    LDR x0, =format_str
    LDR x1, =buffer
    BL scanf


    // En Caso De Que Se Ingresen Mas Caracteres, Se Omitiran
    discard_1:
        BL getchar
        CMP x0, #10
        BNE discard_1


    // Imprimir La Cadena Ingresada
    LDR x0, =buffer
    BL printf


    // Posicionar elementos en la matriz en forma column-major
    LDR x1, =matState
    BL convertText


    // Imprimir mensaje para pedir clavde de 16 caracteres hexadecimales
    LDR x0, =msg_key
    BL printf


    // Lectura De La Llave Ingresada Por El Usuario
    // (Unicamente Tomara 16 caracteres == 16 bytes == 128 bits)
    LDR x0, =format_str
    LDR x1, =buffer
    BL scanf


    // En Caso De Que Se Ingresen Mas Caracteres, Se Omitiran
    discard_2:
        BL getchar
        CMP x0, #10
        BNE discard_2


    // Imprimir la key Ingresada
    LDR x0, =buffer
    BL printf


    // Conversion de la cadena "key" a valor numerico
    BL convertKey


    // Posicionar elementos en la matriz en forma column-major
    LDR x1, =key
    BL convertText


    // Realizar Encriptacion
    BL encript


    // Imprimir Cadena Encriptada
    LDR x0, =criptograma
    BL printf

    BL exit

    .size main, (. - main)

