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
    dummy:          .space 4, 0
    numero:         .space 4, 0

    .align 3
    root:           .xword 0
    stack:          .xword 0

.section .text
.global main
.global insert_routine
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

    save_node:
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
        LDR x2, [x1]    // Cargar el valor del nodo en x2
        // hacer ciclo para recorrer los nodos

        CMP x19, x2
        BLE child_izq   // Si el valor es menor o igual al nodo, que se vaya al lado izquierdo
        B child_rig     // Si el valor es mayor, que se vaya al lado derecho

        child_izq:
            LDR x2, [x1, #8]            // Cargar el puntero izquierdo
            ADD x1, x1, #8              // Sumarle 8 bytes al offset

            CBNZ x2, root_not_null      // Si el nodo no esta vacio, regresar al ciclo para seguir bajando
            B save_node                 // Si el nodo esta vacio, guardar en la direccion con el offset aplicado

        child_rig:
            LDR x2, [x1, #16]           // Cargar el puntero derecho
            ADD x1, x1, #16             // Sumarle 16 bytes al offset

            CBNZ x2, root_not_null      // Si el nodo no esta vacio, regresar al ciclo para seguir bajando
            B save_node                 // Si el nodo esta vacio, guardar en la direccion con el offset aplicado
        
    malloc_handler_err:
        LDR x0, =malloc_err             // Notificar un error, si no se pudo reservar memoria en el heap
        BL printf

    LDP x29, x30, [SP], #16
    RET


// ! CORREGIR RECORRIDO DEL ARBOL EN ESTE PROCEDIMIENTO
print_tree:
    STP x29, x30, [SP, #-16]!

    LDR x0, =stack          // Cargar direccion donde ser almacenara el valor del stack
    MOV x11, SP             // Copiar el valor del puntero stack en el registro x11
    STR x11, [x0]           // Almacenar el puntero inicial de la pila para restaurarla hasta este punto

    ADR x0, msg_head_print
    BL printf

    LDR x0, =root       // Cargar la direccion de memoria de la variable root
    LDR x0, [x0]        // Cargar el puntero del primer nodo del arbol      
    MOV x10, #0         // Inicializar bandera para el ajuste de la pila

    // Recorrido inorden
    recorrido_izq:
        LDR x1, [x0, #8]
        CBZ x1, print_node
        STR x0, [SP, #-8]!
        MOV x0, x1
        B recorrido_izq

    recorrido_der:
        LDR x1, [x0, #16]
        CBZ x1, print_node

        LDR x1, =stack
        LDR x1, [x1]
        CMP SP, x1
        BEQ exit_print_tree

        LDR x0, [SP], #8
        MOV x1, x2
        B recorrido_izq

    // Validar alineacion de la pila para no cometer errores
    print_node:
        MOV x9, SP
        AND x9, x9, #0xF
        CBZ x9, aligned
        SUB SP, SP, #8
        MOV x10, #1

        aligned:
            // Imprimir el nodo en la terminal
            LDR x1, [x0]
            LDR x0, =format_node
            LDR x2, [x0, #8]
            LDR x3, [x0, #16]
            BL printf

            CBNZ x10, adj_sp
            B no_adj_sp

        adj_sp:
            ADD SP, SP, #8
            MOV x10, #0

        no_adj_sp:
            B recorrido_der

    exit_print_tree:
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
    BEQ insert_routine_op

    CMP x0, #2
    BEQ delete_routine_op

    CMP x0, #3
    BEQ search_routine_op

    CMP x0, #4
    BEQ print_routine_op

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
        STR wzr, [x0]

        B main

    delete_routine_op:
        B main

    search_routine_op:
        B main

    print_routine_op:
        LDR x0, =opcion
        STR wzr, [x0]

        BL print_tree
        B main

    exit_program:
        BL exit
