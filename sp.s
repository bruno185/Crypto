* SET PREFIX
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
*
buffer    equ $5400
outbuf    equ $8000
*
fullpath  equ $280

********** Macros **********
print   MAC            ; affiche une string @ 0 terminal
        ldx #$00       ; pass{e en param}tre
boucle  lda ]1,X
        beq finm
        ora #$80
        jsr cout
        inx
        bra boucle
finm    EOM 
******* Fin macros *******
*
        org $4000
        jmp main
*
getpfp  hex 01          ;  Get prefix param.   
path    hex 0050        ;  prefix buffer $5000
*
setpfp  hex 01          ; Set prefix param.
newpf   da pfx 
*
pfx     ds 64,00        ; storage for prefix string
*
*
ok      asc "OK !"
        hex 8D00
ko      asc "Not OK :-("
        hex 8D00
begin   asc "DEBUT : "
        hex 8D00
spOK    asc "Set prefix OK"
        hex 8D00

* 
long    hex 00          ; length of fullpath
nbslash hex 00          ; / counter
long2   hex 00          ; new prefix length
*
*
main    nop
        print begin
        ldy #$00        ; get volume prefix from fullpath at $280
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
*
*
sp      jsr MLI         ; Set prefix !!
        dfb setprefix
        da setpfp
        bne break
        print spOK
*
*
gp      jsr MLI          ; Get prefix !!
        dfb getprefix 
        da getpfp
        cmp #$00         ; ok ?
        beq lopen
        jmp break
lopen   print ok
        print pfx+1
        rts
*
break   pha
        print ko
        pla
        brk
        rts