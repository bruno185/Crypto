******************
*
*    CRYPTO      *
*
******************
*
*
MLI       equ $BF00
online    equ $C5
open      equ $C8
close     equ $CC
geteof    equ $D1
read      equ $CA
home      equ $FC58
cout      equ $FDED
ptr       equ $06
cr        equ $FD8E      ; print carriage return 
*
buffer    equ $5400
*
* * * * * * * * *
*     MACROS    *
* * * * * * * * *
*
          LMC OFF
          DO 0
m_inc     MAC            ; augmente un entier 16  bits
          inc .0         ; typiquement une adresse de pointeur
          bne ]m_incf
          inc .0+1
]m_incf   EOM
*
PRINT     MAC            ; affiche une string @ 0 terminal
          ldx #$00       ; pass{e en param}tre
]LOOP     lda .0,X
          beq ]FIN
          jsr cout
          inx
          bra ]LOOP
]FIN      EOM 
          FIN
*
* * * * * * * * * *
*  EN-TETE  PROG. *
* * * * * * * * * *
*
          ORG $4000
          jmp start
*
* * * * * * * * * *
*       DATA      *
* * * * * * * * * *
*
*
*** params OPEN ***
*
openp     hex 03         ; OPEN 
path      da fichier     ;  file name 
buff      hex 0050       ; file buffer = $5000
ref       hex 00         ; ref du fichier 
*
*
closep    hex 01         ; CLOSE 
closeref  hex 00
fichier   str "TOTO"     ; nom du fichier
          hex 00
*
geteofp   hex 02         ; GET_EOF
geteofr   hex 00
size      ds 3,0
*
readp     hex 04         ; READ
readref   hex 00         ; ref de fichier
readbuf   hex 0054       ; buffer
readreq   hex 1000       ; 256 octets demand{s 
readlen   hex 0000       ; nb octets lus  
*
*
nbread    hex 0000
eof       hex 00
compteur  hex 00
*
msg       asc "fichier ouvert : "
          hex 00
msg2      asc "fichier ferm{."
          hex 00
msg3      asc "taille du fichier : $"
          hex 00
msg4      asc "d{but de lecture..." 
          hex 00
msg41     asc "fin de lecture."
          hex 00
finfic    asc "fin de fichier atteinte."
          hex 00
nbolus    asc "nombre d'octet(s) lu(s) : $"
          hex 00
*
* * * * * * * *
*  PROGRAMME  *
* * * * * * * *
*
start     nop
          jsr home
*
* ouerture fichier 
*
          jsr MLI        ; Go OPEN !!
          dfb open 
          da openp
          cmp #$00       ; ok ?
          beq ]suite
          jmp break
]suite    lda ref 
          sta closeref   ; copie la ref du fichier pour call close
          sta geteofr    ; idem pour call get_eof
          sta readref    ; idem pour lecture
          jsr display    ; "fichier ouvert"
*
* get_eof 
*
          jsr MLI        ; go GET_EOF !! 
          dfb geteof
          da geteofp
          cmp #$00
          bne break
          jsr disp3 
*
* lecture du fichier
*
          jsr disp4      ; d{but lecture + return
          lda #$00
          sta nbread     ; compteur de read 
          sta eof        ; init. var. eof
*
doread    inc nbread     ; compteur de blocs lus (256 octets)
          jsr MLI        ; lit $100 octet
          dfb read
          da readp
*
          cmp #$4C       ; fin fichier  ?
          beq finread
*
          cmp #$00       ; erreur ?
          bne break      ; oui : break
          jmp lect
*
finread   inc eof 
          print finfic   ; fin atteinte
          jsr cr
          jmp finlect
lect      print nbolus   ; "nb oct. lus :"
          lda readlen+1
          jsr dmphex
          lda readlen
          jsr dmphex
          jsr cr
          jsr dispdata   ; affiche contenu buffer
          jsr cr
          jsr cr
          lda eof 
          beq doread
          jmp doclose
finlect   jsr disp41
*
*
* fermeture fichier 
*
doclose   jsr MLI        ; go CLOSE !!
          dfb close
          da closep
          cmp #$00       ; ok ?
          bne break
          jsr disp2
*
          rts            ; >>>  FIN <<<
break     brk
*
* * * * * * *
* AFFICHAGE *
* * * * * * *
*
display   nop            ; fichier ouvert
          print msg
          lda ref  
          jsr dmphex
          jsr cr
          rts
*
disp2     nop            ; close
          jsr cr
          print msg2
          jsr cr
          rts
*
disp3     nop            ; get_eof
          print msg3
          lda size+2 
          jsr dmphex
          lda size+1 
          jsr dmphex
          lda size 
          jsr dmphex 
          jsr cr
          rts
*
disp4     print msg4
          jsr cr
          rts
*
disp41    jsr cr
          print msg41 
          jsr cr
          rts
*
dispdata  nop            ; affiche contenu buffer
          lda readlen    ; verifie nb car. lus > 0
          ora readlen+1
          beq ]fin
          lda readlen    ; nb car. lus 
          sta compteur
          ldx #$00
]1        lda buffer,x
          dec compteur
          bmi ]fin
          phx            ; sauve x
          jsr dmphex
          plx            ; restore x 
          inx
          jmp ]1 
]fin      rts
*
* * * * * * * * *
*  BYTE TO HEXA *
* * * * * * * * *
*
dmphex    pha            ; sauve A
          AND #$0F
          TAX
          LDA TAB,X
          STA LO
          pla            ; r{cup}re A
          LDY #$04
loop4     LSR
          DEY
          BNE loop4
          TAX
          LDA TAB,X
          STA HI
          JSR OUT
          RTS
OUT       LDA HI
          ORA #$80
          JSR COUT
          LDA LO
          ORA #$80 
          JSR COUT
          RTS
TAB       ASC '0123456789ABCDEF'
lo        hex 00
hi        hex 00
*

