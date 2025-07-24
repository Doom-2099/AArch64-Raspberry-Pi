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
    opcion:         .space 8, 0
    numero:         .space 4, 0

    .align 3
    root:           .xword 0
    stack:          .xword 0

.section .text

    .type insert_routine, %function
    .global insert_routine
insert_routine:
    STP x29, x30, [SP, #-16]!

    // params: x0 => numero a guardar
    MOV x19, x0                 // Copiar numero a reservar en registro x19

    MOV x0, #24                 // # de bytes a reservar
    BL malloc                   // Funcion para reservar bytes
    CBZ x0, malloc_handler_err  // Captura del error

    verificar_root:
        LDR x1, =root               // Direccion de memoria donde se almacena el root
        LDR x3, [x1]                // Cargar Direccion de memoria reservada para root

        CBZ x3, save_node           // Si el root == NULL, que inserte el primer nodo en root
        LDR x1, [x1]                // Caso contrario, cargar el valor de la memoria almacenada en root
        LDR x3, [x1]                // Cargar el valor del nodo root en x3
        B root_not_null             // Hacer el salto a "root_not_null"

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
        CMP x19, x3
        BLE child_izq                   // Si el valor es menor o igual al nodo, que se vaya al lado izquierdo
        B child_rig                     // Si el valor es mayor, que se vaya al lado derecho

        child_izq:
            LDR x2, [x1, #8]!            // Cargar el puntero izquierdo
            CBZ x2, save_node            // Si el valor del ptr izq es null, que guarde en ese espacio de memoria el nuevo nodo
            MOV x1, x2                   // Caso contrario, que el valor del nodo lo copie en x1
            LDR x3, [x2]                 // Cargar el valor del nodo en el registro x3
            B root_not_null              // Hacer el salto hacia el "root_not_null"

        child_rig:
            LDR x2, [x1, #16]!              // Cargar el puntero derecho
            CBZ x2, save_node               // Si el valor del ptr der es null, que guarde en ese espacio de memoria el nuevo nodo
            MOV x1, x2                      // Caso contrario, que el valor del nodo lo copie en x1
            LDR x3, [x2]                    // Cargar el valor del nodo en el registro x3
            B root_not_null                 // Hacer el salto hacia el "root_not_null"
        
    malloc_handler_err:
        LDR x0, =malloc_err                 // Notificar un error, si no se pudo reservar memoria en el heap
        BL printf                           

    LDP x29, x30, [SP], #16
    RET
    .size insert_routine, (. - insert_routine)


    .type print_tree, %function
    .global print_tree
print_tree:
    STP x29, x30, [SP, #-16]!

    LDR x0, =stack          // Cargar direccion donde ser almacenara el valor del stack
    MOV x11, SP             // Copiar el valor del puntero stack en el registro x11
    STR x11, [x0]           // Almacenar el puntero inicial de la pila para restaurarla hasta este punto

    ADR x0, msg_head_print      // Imprimir encabezado para la lista de nodos
    BL printf                   

    LDR x0, =root       // Cargar la direccion de memoria de la variable root
    LDR x0, [x0]        // Cargar el puntero del primer nodo del arbol      

    // Recorrido inorden
    recorrido_izq:
        LDR x1, [x0, #8]                // Cargar la direccion almacenada en el ptr izquierdo
        CBZ x1, print_node              // Si el valor del ptr izq es null, que imprima salte a imprimir el nodo actual
        MOV x20, #0                     // Relleno De Pila
        STP x0, x20, [SP, #-16]!        // Almacenar en la pila la direccion del nodo actiual Si el valor del ptr izq es diferente de null
        MOV x0, x1                      // Copiar el valor del ptr izq en el registro x0
        B recorrido_izq                 // Saltar a "recorrido_izq"

    recorrido_der:
        LDR x1, [x0, #16]               // Cargar la direccion almacenada en el ptr derecho
        CBZ x1, back_father             // En caso de que el puntero derecho sea null, saltar a "back_father"
        MOV x0, x1                      // Copiar la direccion del nodo de x1 a x0
        B recorrido_izq                 // Saltar a "recorrido_izq"
        
    back_father:
        LDR x1, =stack                  // Cargar la direccion de memoria de la variable stack
        LDR x1, [x1]                    // Cargar el valor inicial del stack almacenado
        CMP SP, x1                      // Si el apuntador de pila es igual al valor guardado, ya no hay nodos para sacar
        BEQ exit_print_tree             // Terminar funcion

        LDP x0, x20, [SP], #16          // Cargar la direccion del nodo padre en x0, desde la pila, x20 es padding

    print_node:
        MOV x15, x0                 // Copiar la direccion de memoria del nodo en el registro x15, para no perder la referencia

        // Configurando parametros para la impresion del nodo en la consol
        LDR x1, [x0]                // Cargar el valor del nodo en x1
        LDR x2, [x0, #8]            // Cargar el valor de memoria del ptr izq
        LDR x3, [x0, #16]           // Cargar el valor de memoria del ptr der
        LDR x0, =format_node        // Cargar la direccion del formato a imprimir por terminal
        BL printf

        MOV x0, x15                 // Recuperar el valor de la memoria de x15 a x0
        B recorrido_der             // Hacer el salto a "recorrido_der"

    exit_print_tree:
        LDP x29, x30, [SP], #16
        RET

    .size print_tree, (. - print_tree)


// Estructura Del Nodo: | 4 bytes (num) | 4 bytes (padding) | 8 bytes (puntero izquierdo) | 8 bytes (puntero derecho) | => 24 bytes
    .type main, %function
    .global main
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
        STR xzr, [x0]

        B main

    delete_routine_op:
        B main

    search_routine_op:
        B main

    print_routine_op:
        LDR x0, =opcion
        STR xzr, [x0]

        BL print_tree
        B main

    exit_program:
        BL exit

    .size main, (. - main)
