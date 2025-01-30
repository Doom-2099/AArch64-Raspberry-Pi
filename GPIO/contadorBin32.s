/* 
    * File:   ContadorBinario32.s
    * Author: Jorge Castañeda
    * Contador Binario
*/

.section .rodata
    // constantes a utilizar
    .equ GPFSEL2,       0x20200008
    .equ GPSET0,        0x2020001C
    .equ GPCLR0,        0x20200028

.section .bss

.section .text
.global _start

_start:
    // Paso 1: Configurar Direccion De Memoria De Los Pines GPIO
    // Pines a utilizar: GPIO 22,23,24
    LDR r0, =GPFSEL2        // Cargar Direccion Base De GPFSEL2
    LDR r1, [r0]            // Cargar Valor Actual De GPFSEL2

    // Paso 2: Configurar Pines GPIO Como Salidas
    BIC r1, r1, #(0b111 << (2*2))   // Limpiar Bits de GPIO 22
    BIC r1, r1, #(0b111 << (3*2))   // Limpiar Bits de GPIO 23
    BIC r1, r1, #(0b111 << (4*2))   // Limpiar Bits de GPIO 24

    ORR r1, r1, #(0b001 << (2*2))   // Establecer Funcion De Salida de GPIO 22
    ORR r1, r1, #(0b001 << (3*2))   // Establecer Funcion De Salida de GPIO 23
    ORR r1, r1, #(0b001 << (4*2))   // Establecer Funcion De Salida de GPIO 24
    STR r1, [r0]

    // Paso 3: Inicializar Contador En 0
    MOV r9, #0
    MOV r10, #0

    // Paso 4: Iniciar Bucle Infinito
    loop_contador:
        // Paso 5: Actualizar Pines GPIO
        LDR r2, =GPCLR0
        STR r11, [r2]

        LSL r10, r9, #21
        LDR r2, =GPSET0
        STR r10, [r2]

        // Paso 6: Calcular Retardo
        MOV r4, #5000000 // Ajustar el tiempo de espera
        retardo:
            SUBS r4, r4, #1
            BNE retardo

        // Paso 7: Incrementar Contador
        LSL r11, r9, #21

        CMP r9, #7
        MOVEQ r9, #0
        ADDNE r9, r9, #1

        // Paso 8: Volver A Paso 4, Bucle Infinito
        B loop_contador
