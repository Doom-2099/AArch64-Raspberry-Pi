/* 
    * File:   ContadorBinario.s
    * Author: Jorge Castañeda
    * Lista Enlazada Simple
*/

.section .rodata
    // constantes a utilizar
    .equ GPFSEL2,       0x3F200008
    .equ GPSET0,        0x3F20001C
    .equ GPCLR0,        0x3F200028


.section .bss

.section .text
.global _start


/* 
 *   Objetivo: Implementar un contador binario de 3 bits (0-7)
 *   Configurar tres pines GPIO como salidas
 *   Incrementar el contador cada segundo (Calcular Retardo)
 *   Posteriormente conectar las 3 entradas a un decodificador BCD 7447
 *   Conectar el decodificador a un display de 7 segmentos
 *   Se adjunta el diagrama de conexion de los componentes electronicos
 */

_start:
    // Paso 1: Configurar Direccion De Memoria De Los Pines GPIO
    // Pines a utilizar: GPIO 22,23,24
    // Registro De Configuracion: GPFSEL2 => 0x3F200008 = 0x3F000000 + 0x200000 + 0x08
    LDR x0, =GPFSEL2                    // Cargar Direccion Base De GPFSEL2
    LDR x1, [x0]                        // Cargar Valor Actual De GPFSEL2

    // Paso 2: Configurar Pines GPIO Como Salidas
    // Utilizar La Direccion Base De GPFSEL2 = 0b001 << (3*2), 0b001 << (4*2), 0b001 << (5*2)
    // Limpiar Bits con BIC y Establecer Bits con ORR
    BIC x1, x1, (#0b111 << (2*2))       // Limpiar Bits de GPIO 22
    BIC x1, x1, (#0b111 << (3*2))       // Limpiar Bits de GPIO 23
    BIC x1, x1, (#0b111 << (4*2))       // Limpiar Bits de GPIO 24

    ORR x1, x1, (#0b001 << (2*2))       // Establecer Funcion De Salida de GPIO 22
    ORR x1, x1, (#0b001 << (3*2))       // Establecer Funcion De Salida de GPIO 23
    ORR x1, x1, (#0b001 << (4*2))       // Establecer Funcion De Salida de GPIO 24


    // Paso 3: Inicializar Contador En 0
    // Usar Registro x9 como contador
    // Usar Registro x10, como valores desplazados
    MOV x9, #0
    MOV x10, #0


    // Paso 4: Iniciar Bucle Infinito
    // Usar Etiqueta Loop para el bucle infinito
    loop_contador:

        // Paso 5: Actualizar Pines GPIO
        // Actualizar los pines GPIO con el valor del contador
        // USAR los registros GPSEL0 Y GPCLR0 para actualizar el contador binario
        LDR x2, =GPCLR0
        STR x11, [x2]

        LSL x10, x9, #21
        LDR x2, =GPSET0
        STR x10, [x2]

        // Paso 6: Calcular Retardo
        // Hacer un retardo de un tiempo prudente previo a hacer el cambio
        


        // Paso 7: Incrementar Contador
        // Aplicar incremento condicional para mantener el contador
        LSL x11, x9, #21

        CMP x9, #7
        CSINC x9, #0, x9, EQ


        // Paso 8: Volver A Paso 5
        B loop_contador
    

