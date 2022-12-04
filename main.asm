.model small
.stack 14h
.data
    matriz  db '5','3',2 dup(' '),'7',4 dup(' ')
            db '6',2 dup(' '),'1','9','5',3 dup(' ')
            db ' ','9','8',3 dup(' '),' ','6',' '
            db '8',3 dup(' '),'6',3 dup(' '),'3'
            db '4',2 dup(' '),'8',' ','3',2 dup(' '),'1'
            db '7',3 dup(' '),'2',3 dup(' '),'6'
            db ' ','6',4 dup(' '),'2','8',' '
            db 3 dup(' '),'4','1','9',2 dup(' '),'5'
            db 4 dup(' '),'8',2 dup(' '),'7','9'

    main_msg db 'Sudoku Assembly$'
    controle_msg db 'Controles:$'
    clique_msg db 'Para por valores$'
    clique2_msg db 'na tabela, clique$'
    clique3_msg db 'no espaco e digite$'
    clique4_msg db 'um valor entre 1 a 9$'
.code
    imp_espaco macro    ;Macro impressão de espaço
        PUSH AX
        PUSH DX
        MOV AH,2
        MOV DL,20h
        int 21h
        POP DX
        POP AX

    ENDM

    Imprime_msg macro var1   ;macro para codigo de impressão 
         
        PUSH AX
        PUSH DX
        MOV AH, 09h
        LEA DX,var1
        INT 21h
        POP DX
        POP AX

    ENDM


    imp_back macro    ;Macro impressão de backspace

        PUSH AX
        PUSH DX
        MOV AH,2
        MOV DL,8h
        int 21h
        POP DX
        POP AX

    ENDM

    reg_push macro      ;Macro push de registradores

        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

    ENDM

    reg_pop macro      ;Macro pop de registradores

        POP DX
        POP CX
        POP BX
        POP AX

    ENDM




.code
    main proc

        MOV AX,@data       ;Movendo data para ax
        MOV DS,AX
        MOV ES,AX

        MOV Ah,0
        MOV al,6            ;Ativando modo se vídeo CGA 640x200
        int 10h


        MOV AH,0BH
        MOV BH,0            ;Cor de fundo branco (bl = 7)
        MOV BL,7
        int 10h

        MOV AH,0BH
        MOV BH,1            ;Seleção de paleta
        MOV BL,0
        int 10h

        MOV AH,02
        MOV DH,1               ;Posicionando cursor no meio superior (linha 1,coluna 32)
        MOV DL,32
        MOV BH,0
        int 10h

        Imprime_msg main_msg       ;Imprimindo "sudoku assembly"

        MOV DH,7              ;Posicionando curso na esquerda (linha 7,coluna 1)
        MOV DL,1
        MOV BH,0
        int 10h

        Imprime_msg controle_msg

        ADD DH,2                    ;Para cada mensagem, mover o cursor para a próxima linha
        int 10h

        Imprime_msg clique_msg

        inc DH
        int 10h

        Imprime_msg clique2_msg

        inc DH
        int 10h

        Imprime_msg clique3_msg

        inc DH
        int 10h

        Imprime_msg clique4_msg




        MOV DH,5               ;Posição da matriz (primeira linha)
        MOV DL,26
        lea SI,matriz
        call imprimematriz     ;Procedimento de imprimir matriz


       call grade               ;Procedimento de imprimir grade do sudoku

        imp_back
        mov ax, 01h            ;Ativando cursor(mouse)
        int 33h

        XOR CX,CX
        XOR DX,DX


        CONTROLE:              ;Loop para controles com o mouse           
                mov  ax, 3h 
                int  33h 
                TEST bx,1
        JZ CONTROLE                  ;Pular se não houver clique no mouse
                                     ;Valor inicial da coluna 214(+24)->430,Valor inicial da linha 36(+16)->180
                CMP CX,214      
                JL CONTROLE
                CMP CX,430
                JG CONTROLE
                CMP DX,36             
                JL CONTROLE
                CMP DX,180
                JG CONTROLE          ;Verificando se o clique está dentro da coluna

                XOR AX,AX
                MOV AH,3
                MOV AL,24            ;Convertendo a posição do mouse em posição de char
                MOV BX,36
            
                LINHABOTAO:
                    ADD AH,2         ;Convertendo a posição da linha para char
                    ADD BX,16
                    CMP DX,BX
                    JNL LINHABOTAO

                XOR BX,BX
                MOV BX,214

                    COLUNABOTAO:
                        ADD AL,3
                        ADD BX,24       ;Convertendo a posição da coluna para char
                        CMP CX,BX      
                    JNL COLUNABOTAO

                    ADD AL,1
                    XOR BX,BX 
                    MOV DH,AH
                    MOV DL,AL

                    MOV AH,02           ;Movendo o cursor para posição convertida( o cursor se move por char)  
                    int 10h
                CALL coloca_valor       ;função de colocar valor na tabela 
            JMP CONTROLE



                
                

        FIM:            ;fim do programa

        mov ax, 3        ;clear screen
        int 10h

        XOR DX,DX
        PUSH DX
        
        LEA SI,matriz
        CALL imprimematriz
        
        MOV AH,4CH
        int 21h
    


    MOV AH,4ch
    int 21h

    main endp


    ;=== Procedimento de imprimir grade do sudoku ===
    
    grade proc
        reg_push


        MOV Ah,0CH             ;Definindo começo da grade 
        MOV BH,0
        MOV AL,1
        MOV DX,36
        MOV CX,214

        PROXPIXELINHAS:         ;Imprimindo as linhas das grade
            PIXELLINHAS:
                int 10h
                inc CX
                CMP CX,430      ;Imprime o pixel até a coluna 430
            JLE PIXELLINHAS         


            ADD DX,16           ;Vai para o próxima linha até (DX = 180)
            MOV CX,214
            CMP DX,180
        JLE PROXPIXELINHAS

        MOV DX,36             
        MOV CX,214

        PROXPIXELCOL:            ;Imprimindo as colunas da grade 
            PIXELCOL:
                int 10h
                inc DX
                CMP DX,180
            JLE PIXELCOL
            ADD CX,24
            MOV DX,36              ;Próxima coluna (até CX = 430)
            CMP CX,430
        JLE PROXPIXELCOL

            reg_pop
            ret

    grade endp

     ;=== Procedimento de imprimir matriz 9x9 ===
    ;Imprime uma matriz 9x9 dando 2 espacos para cada coluna e 1 espaco para cada linha 
    ;Entrada:
    ;SI: Endereço da matriz 
    ;DL: Coluna do cursor
    ;DH: linha do cursor
    ;BH: página

    imprimematriz proc

        reg_push                ;Push registradores
        CLD

        MOV AH,02               ;funcao de imprimir/posicionar cursor
        MOV CX,9                ;Contador de linha 


        IMPRIME_LOOP:

                
            int 10h             ;Posiciona o cursor(Linha DH,Coluna 39)
            ADD DH,2
            PUSH DX
    
            MOV BL,9            ;BL contador de coluna
            PROXLINHA:
                imp_espaco
                imp_espaco
                LODSB           ;Armazena dado da matriz em al       
                MOV DL,AL       ;Move dado da matriz em DL e imprime
                int 21h
                
                DEC BL
                CMP BL,0
            JNE PROXLINHA       ;Acaba quando todas as colunas da linha forem impressas
            POP DX
        LOOP IMPRIME_LOOP       ;Acaba quando todas as linhas da matriz forem impressas

        reg_pop

        ret


    imprimematriz endp


    
    ;=== Procedimento de colocar numero na matriz ===
    ;Coloca um valor de 1 a 9 na matriz de acordo com a posição em que o cursor está
    ;Entrada:
    ;BH = página


    coloca_valor proc

        reg_push

        MOV AH,03h         ;Pegando posição do cursor
        int 10h

        XOR AX,AX

        MOV AL,DH          ;Tranformando a linha  em coordenada da matriz
        SUB AL,5
        MOV CL,2
        DIV CL
        MOV CL,9
        MUL CL

        MOV BX,AX
        XOR AX,AX

        MOV AL,DH          ;Tranformando a linha  coluna na coordenada da matriz
        MOV AL,Dl           
        SUB AL,1Ch
        MOV CL,3
        DIV CL
        MOV SI,AX


        imp_espaco          ;Imprimindo espaço para apagar o numero
    
        MOV AH,02h
        MOV Dl,8h
        int 21h             ;Backspace para voltar
    NOTNUM:
        MOV AH,07           ;Lendo o input (sem echo)
        int 21h
        CMP Al,31h          ;Verificando se o input é válido (de 1 a 9)
        JL NOTNUM
        CMP AL,39h
        JG NOTNUM

        XOR CX,CX
        MOV CL,AL

        MOV AH,02           ;Imprimindo o input
        MOV Dl,AL
        int 21h

        
        
        MOV MATRIZ[bx][si],CL    ;Colocando o valor na matriz

        MOV AH,02
        MOV Dl,8h                ;Backspace
        int 21h

        reg_pop                 ;Recuperando valores iniciais
        

        ret 

    coloca_valor endp
        

    END MAIN




