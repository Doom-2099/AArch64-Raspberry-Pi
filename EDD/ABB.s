/* 
    * File:   ABB.s
    * Author: Jorge Castañeda
    * Arbol Binario De Busqueda
*/

.section .rodata
    format:         .asciz "%d"

    format_num:     .asciz "%d"

    menu:           .asciz "\n-> ARBOL BINARIO DE BUSQUEDA\n1. Insertar\n2. Eliminar\n3. Buscar\n4. Mostrar\n5. Salir\n>> Ingrese Una Opcion: "

    error_menu:     .asciz "\nError: Opcion Invalida -- Intentelo Nuevamente\n"

    msg_insert:     .asciz "Ingrese El Numero A Insertar: "

    msg_head_print: .asciz "\nValor | ptr Izquierdo | ptr Derecho\n"

    format_node:     .asciz "%llu | %llu | %llu \n"

    insert_success: .asciz "Insercion Realizada Con Exito\n"

    empty_tree_msg: .asciz "\nEl Arbol Esta Vacio\n\n"

    malloc_err:     .asciz "Error: malloc failed\n"

    salto:          .asciz  "\n"

.section .bss
    .align 2
    opcion:         .space 4, 0
    numero:         .space 4, 0

    .align 3
    root:           .xword 0

.section .text
.global main
.global insert_routine
.global search_routine
.global print_tree

insert_routine:
    STP x29, x30, [SP, #-16]!

    // params: x0 => numero a guardar
    MOV x19, x0                 // Copiar numero a reservar en registro x19

    MOV x0, #24                 // # de bytes a reservar
    BL malloc                   // Funcion para reservar bytes
    CBZ x0, malloc_handler_err  // Captura del error

    LDR x1, =root               // Direccion de memoria donde se almacena el root
    LDR x1, [x1]                // Cargar Direccion de memoria reservada para root

    CBNZ x1, root_not_null      // Si el root == NULL, que inserte el primer nodo en root

    LDR x1, =root           // Cargar la direccion de root
    STR x0, [x1]            // almacenar la direccion del nodo en root

    STR x19, [x0]           // almacenar el numero a guardar en el espacio en memoria
    STR xzr, [x0, #8]       // Puntero izquierdo (NULL)
    STR xzr, [x0, #16]      // Puntero derecho (NULL)

    ADR x0, insert_success  // msg de aviso que todo salio bien
    BL printf               // Funcion para imprimir en pantalla

    LDP x29, x30, [SP], #16
    RET

    root_not_null:
        // Aplicar recursividad en forma de un ciclo

    malloc_handler_err:
        LDR x0, =malloc_err
        BL printf

    LDP x29, x30, [SP], #16
    RET


// Estructura Del Nodo: | 4 bytes (num) | 4 bytes (padding) | 8 bytes (puntero izquierdo) | 8 bytes (puntero derecho) | => 24 bytes
main:
    LDR x0, =menu
    BL printf

    LDR x0, =format
    LDR x1, =opcion
    BL scanf
    BL getchar

    // Seleccion Del Menu
    LDR x0, =opcion
    LDR x0, [x0]

    CMP x0, #1
    BEQ insert_routine

    CMP x0, #2
    BEQ delete_routine

    CMP x0, #3
    BEQ search_routine

    CMP x0, #4
    BEQ print_tree

    CMP x0, #5
    BEQ exit_program

    LDR x0, =error_menu
    BL printf

    B main

    insert_routine_op:
        ADR x0, msg_insert
        BL printf

        //Captura Del Numero
        LDR x0, =format_num
        LDR x1, =numero
        BL scanf

        LDR x0, =numero
        LDR x0, [x0]

        BL insert_routine

        LDR x0, =opcion
        MOV x1, 3

        clear_option:
            STRB wzr, [x0]
            SUB x1, x1, #1
            CBNZ x1, clear_option

            B main

    delete_routine_op:
        B main

    search_routine_op:
        B main

    print_routine_op:
        BL print_tree
        B main

    exit_program:
        BL exit
