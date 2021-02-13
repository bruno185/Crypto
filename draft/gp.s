* * * * * * * * * * * * * *
*           GP            *
* * * * * * * * * * * * * *

* Algo :
* - Get_prefix
* - if prefix not null = > all is right, exit.
* - if prefix null (length =0) : extract vol. from $280
* - Set_prfix with it
*
*
MLI       equ $BF00
online    equ $C5
open      equ $C8
close     equ $CC
geteof    equ $D1
read      equ $CA
getprefix equ $C7
setprefix equ $C6
home      equ $FC58
text      equ $FB2F
col80off  equ $C00C
cout      equ $FDED
ptr       equ $06
cv        equ $25
ch        equ $24 
cr        equ $FD8E      ; print carriage return 
vtab      equ $FC22
wndlft    equ $20
wndwdth   equ $21
wndtop    equ $22
wndbtm    equ $23 
prompt    equ $33
getln     equ $FD6A
tohex     equ $F944             ; Prints current contents of X register in hexadecimal
*
buffer    equ $5000
outbuf    equ $8000

fullpath  equ $280

********** Macros **********
print   MAC            ; dispaly string with 0 at the end
        ldx #$00       
boucle  lda ]1,X
        beq finm
        ora #$80       ; normal
        jsr cout
        inx
        bra boucle
finm    EOM 
*
prnstr  MAC            ; display a sting with length in first byte
        ldx #$00
        ldx ]1         ; get length
        ldy #$00
loopstr lda ]1+1,y
        beq finstr
        ora #$80       ; normal
        jsr cout
        iny
        dex
        bne loopstr
finstr  EOM 
*
******* Fin macros *******
*
*
******* Variables *******
        org $4000
        jmp main
*
getpfp  hex 01         ; get_prefix param. 
        da buffer      ; prefix buffer at $5000
*
setpfp  hex 01          ; set_prefix param.
newpf   da pfx 
*
pfx     ds 64,00        ; storage for prefix string
*
ok      asc "Get prefix OK."
        hex 8D00
ko      asc "Get prefix not OK."
        hex 8D00
begin   asc "DEBUT : "
        hex 8D00
gpempty asc "Prefix vide."
        hex 8D00
path280 asc "Path en $280 : "
        hex 00
extpf   asc "Path extrait : "
        hex 00
spOK    asc "Set prefix OK"
        hex 8D00
spKO    asc "Set prefix not OK."
        hex 8D00
*
*
long    hex 00          ; length of fullpath
nbslash hex 00          ; / counter
long2   hex 00          ; new prefix length
*
*
*
******* START *******
* 
main    nop
        print begin
gp      jsr MLI        ; Go get prefix !!
        dfb getprefix 
        da getpfp
        cmp #$00       ; ok ?
        beq suitesp
        jmp break
suitesp print ok
        lda buffer
        beq empty
        prnstr buffer
        jmp fingp
empty   print gpempty
        jsr do280       ; extract, 
fingp   rts
break   pha
        print ko
        pla
        tax
        jsr tohex
        rts
*
do280   nop             ; Display string at $280
        ldx fullpath
        beq exit
        print path280
        ldy #$00
myloop  lda fullpath+1,y
        ora #$80
        jsr cout
        iny
        dex
        bne myloop
        lda #$8D
        jsr cout
        jsr extract
exit    rts
*
*
extract nop
        ldy #$00        ; get volume prefix from string at $280
        lda fullpath    ;
        sta long        ; fullpath length
debloop lda fullpath+1,y
        cmp #$2F        ; "/"  ?
        bne s1          ; 
        inc nbslash
        ldx nbslash
        cpx #$02        ; 2 / ?
        beq finloop     ; yes : end
s1      sta pfx+1,y     ; strore in prefix
        inc long2       ; increase prefix length
        dec long        ; decrease max size (= fullpath size)
        beq finloop     ; max size reached : end
        iny             ; next byte
        jmp debloop     ; loop    
finloop nop
        lda long2       ; prefix length 
        sta pfx         ; at the begining of the prefix
        print extpf
        prnstr pfx
        jsr sp
        rts

sp      lda #$8D
        jsr cout
        jsr MLI         ; Set prefix !!
        dfb setprefix
        da setpfp
        bne doko
        print spOK
        rts
doko    print spKO
        rts
