/* 
    * File:   ListaEnlazada.s
    * Author: Jorge Castañeda
    * Lista Enlazada Simple
*/

.section .rodata
// Seccion De Cadenas De Texto
    format:         .asciz "%d"

    format_num:     .asciz "%d"

    menu:           .asciz "\n-> LISTA ENLAZADA\n1. Insertar\n2. Eliminar\n3. Mostrar\n4. Salir\n>> Ingrese Una Opcion: "

    error_menu:     .asciz "\nError: Opcion Invalida -- Intentelo Nuevamente\n"

    msg_insert:     .asciz "Ingrese El Numero A Insertar: "

    msg_head_print: .asciz "\nValor | ptr Siguiente\n"

    format_node:     .asciz "%llu | %llu \n"

    insert_success: .asciz "Insercion Realizada Con Exito\n"

    empty_list_msg: .asciz "\nLa Lista Esta Vacia\n\n"

    malloc_err:     .asciz "Error: malloc failed\n"

    salto:          .asciz  "\n"

.section .bss
    // Seccion De Variables No Inicializadas
    .align 2
    opcion:         .space 4, 0
    dummy:          .space 4, 0
    numero:         .space 4, 0

    .align 3
    head:           .xword 0

.section .text
.global main
.global insert_routine  
.global print_list

// Estructura De Datos Para El Nodo: | 4 bytes (num) | 4 bytes (padding) | 8 bytes (puntero) | => 16 bytes
insert_routine:
    STP x29, x30, [SP, #-16]!          // Guardar Registros x29 y x30

    // params: x0 => numero a guardar
    MOV x19, x0                // Guardar Valor En x19 

    MOV x0, #16                 // # Bytes A Reservar
    BL malloc                   // Reservar Memoria
    CBZ x0, malloc_handler_err  // Si x0 == NULL, Ir A malloc_handler_err

    LDR x1, =head               // Cargar La Direccion de Head
    LDR x1, [x1]                // Cargar El Valor Del Primer Nodo

    CBNZ x1, root_not_null        // Si Head No Es NULL, Ir A root_not_null

    LDR x1, =head               // Cargar La Direccion de Head
    STR x0, [x1]                // Guardar El Puntero En Variable head     
    
    STR x19, [x0]                // Guardar El Numero En Variable head
    STR xzr, [x0, #8]           // Puntero Siguiente (NULL) */

    ADR x0, insert_success
    BL printf

    LDP x29, x30, [SP], #16     // Restaurar Registros x29 y x30
    RET
    
    root_not_null:
        LDR x2, =head           // x1 = aux | x2 = aux.siguiente
        LDR x2, [x2]

        loop_lista:
            LDR x3, [x2, #8]              // Cargar el puntero al siguiente nodo
            CBZ x3, end_loop              // Si x3 es NULL, salir del bucle
            MOV x2, x3
            B loop_lista                  // Repetir el bucle
        
        end_loop:
            STR x19, [x0]               // Almacenar el valor en el nuevo nodo indexado por x0
            STR xzr, [x0, #8]           // Inicializar el ptr siguiente con el valor null

            STR x0, [x2, #8]                // Guardar el valor del nuevo nodo en aux.siguiente

            ADR x0, insert_success
            BL printf

            LDP x29, x30, [SP], #16     // Restaurar Registros x29 y x30
            RET

    malloc_handler_err:
        ADR x0, malloc_err
        BL printf

        LDP x29, x30, [SP], #16     // Restaurar Registros x29 y x30
        RET

print_list:
    STP x29, x30, [SP, #-16]!    // Guardar Registros x29 y x30

    ADR x0, msg_head_print
    BL printf

    LDR x1, =head               // Cargar La Direccion de Head
    LDR x1, [x1]                // Carga La Direccion Almacenada En Head
    CBZ x1, print_list_end      // Si Head Es NULL, Ir A print_list_end

    MOV x19, x1                 // Copiar direccion del primer nodo a x19

    loop_print:
        ADR x0, format_node     // Cargar direccion del formato
        LDR x1, [x19]
        LDR x2, [x19, #8]           // Cargar valor del nodo en x1
        BL printf
        
        LDR x3, [x19, #8]
        CBZ x3, end_print_routine  // Si x3 es NULL, salir del bucle
        MOV x19, x3
        B loop_print

    print_list_end:
        ADR x0, empty_list_msg
        BL printf

    end_print_routine:
        LDP x29, x30, [SP], #16     // Restaurar Registros x29 y x30
        RET


main:
    LDR x0, =menu
    BL printf

    // Captura Del Caracter
    LDR x0, =format
    LDR x1, =opcion
    BL scanf
    BL getchar

    // Seleccion Del Menu
    LDR x0, =opcion
    LDR x0, [x0]
    
    CMP x0, #1
    BEQ insert_routine_op

    CMP x0, #2
    BEQ delete_routine_op

    CMP x0, #3
    BEQ print_routine_op

    CMP x0, #4
    BEQ terminate

    LDR x0, =error_menu
    BL printf

    B main

    insert_routine_op:
        ADR x0, msg_insert
        BL printf

        // Captura Del Numero
        LDR x0, =format_num
        LDR x1, =numero
        BL scanf

        LDR x0, =numero
        LDR x0, [x0]

        BL insert_routine

        LDR x0, =opcion
        STR wzr, [x0]

        B main

    delete_routine_op:
        B main

    print_routine_op:
        LDR x0, =opcion
        STR wzr, [x0]

        BL print_list
        B main

    terminate:
        BL exit
