
* 
long    hex 0000
long2   hex 00
*
*
main    nop
        print begin
        lda #$81
        sta ptr
        lda #$02
        sta ptr+1
        ldy #$00
        lda #$280
        sta long
debloop lda (ptr),y
        cmp #$2F        ; "/"  ?
        bne s1          ; 
        inc long+1
        ldx long+1
        cpx #$02
        beq finloop
s1      sta pfx+1,y
        inc long2
        dec long
        beq finloop
        iny
        jmp debloop         
finloop nop
        lda long2 
        sta pfx
*
*