MLI       equ $BF00
online    equ $C5
open      equ $C8
close     equ $CC
geteof    equ $D1
read      equ $CA
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
tohex     equ $F944             ;Prints current contents of X register in hexadecimal
*
buffer    equ $5400
outbuf    equ $8000

print     MAC            ; affiche une string @ 0 terminal
          ldx #$00       ; pass{e en param}tre
boucle   lda ]1,X
          beq finm
          jsr cout
          inx
          bra boucle
finm      EOM 

        org $4000
        jmp main
openp     hex 03         ; OPEN 
path      da filename       ;  file name adress
buff      hex 0050       ; file buffer = $5000
ref       hex 00         ; ref du fichier 

ok      asc "OK !"
        hex 00
ko      asc "Not OK, error : $"
        hex 00
filename hex 06
        asc 'PRODOS'
        hex 00
main    nop
openfile  jsr MLI        ; Go OPEN !!
          dfb open 
          da openp
          *cmp #$00       ; ok ?
          *beq suiteopen
          bcc suiteopen
break   pha
        print ko
        pla
        tax
        jsr tohex
        rts
suiteopen print ok
          rts


