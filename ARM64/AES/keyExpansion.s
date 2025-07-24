.section .text

/* 
 * -----------------------------------------
 * ---- Funcion Generadora De Subclaves ----
 * -----------------------------------------
 */
.type expansionKey, %function
.global expansionKey
expansionKey:
    STP X29, X30, [SP, -16]!

    LDR x0, =key
    MOV x1, #16
    MOV x10, #0
    MOV x11, #4
    MOV x12, #4
    loop_key_expansion:
        UDIV x2, x11, x12
        MSUB x2, x2, x12, x11
        CBZ x3, generate_first_word

        SUB x13, x11, #3
        SUB x14, x11, #1

        MUL x15, x12, x13
        LDR w2, [x0, x15]

        MUL x15, x12, x14
        LDR w3, [x0, x15]

        EOR w2, w2, w3
        MUL x15, x12, x11
        STR w2, [x0, x15]

        ADD x11, x11, #1
        CMP x11, #44
        BNE loop_key_expansion
        B end_key_expansion
        
    generate_first_word:
        MUL x15, x1, x10
        ADD x0, x1, x10
        ADD x10, x10, #1

        LDR w2, [x0, #12]
        ROR w2, w2, #24
        STR w2, [x0, #12]

        STP x0, x1, [SP, #-16]!

        ADD x0, x0, #12
        MOV x1, #4
        BL subBytes

        LDP x0, x1, [SP], #16

        UDIV x14, x11, x12
        SUB x14, x14, #1

        SUB x13, x11, #1
        MUL x15, x12, x13
        LDR w2, [x0, x15]

        MOV x5, =Rcon
        ADD x5, x5, x14, LSL #2
        LDR w3, [x5]
        EOR w2, w2, w3

        SUB x13, x11, #3
        MUL x15, x12, x13
        LDR w3, [x0, x15]
        EOR w2, w2, w3

        STR w2, [x0, x15]
        ADD x11, x11, #1
        CMP x11, #44
        BNE loop_key_expansion
    
    end_key_expansion:
        print 1, key_success, lenKeySuccess

        LDP X29, X30, [SP], 16
        RET
        .size expansionKey, (. - expansionKey)