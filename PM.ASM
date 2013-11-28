org 100h
bits 16

; DS: PSP seg preloaded by DOS
; 80h: command-line length
xor bx, bx
mov bl, [ds:80h]
test bl, bl
jnz GO
int 20h

wait_2s:
mov ah, 2Ch ; get system time
int 21h
xchg bh, dh ; store seconds
lop:
int 21h
sub dh, bh
cmp dh, 2
jle lop
ret

cls:
mov ax, 600h ; AH=06 scroll AL=00 all window
mov bh, 17h ; 00010111 gray on blue
xor cx, cx ; X0:Y0
mov dx, 2080h ; X1:Y1 (just to be sure...)
int 10h
mov ah, 2 ; set cursor
xor bx, bx
xor dx, dx ; X:Y
int 10h
ret

con_write:
push dx
call cls
pop dx
mov ah, 9 ; (DS:)DX preloaded with str$
int 21h
call wait_2s
ret

GO:
add bx, 7Fh ; point to last 2 bytes
xchg bx, di

; Compare w/ mem or register? What is it shorter/faster?
;mov bx, [ds:di]
cmp word [ds:di], '/C'
;cmp bx, '/C'
je COLD
cmp word [ds:di], '/W'
;cmp bx, '/W'
je WARM
cmp word [ds:di], '/O'
;cmp bx, '/O'
je POFF
jmp end

; COLD reboot
COLD:
mov dx, msg1
call con_write
push  word 40h
pop   ds
mov   word [0x72], 0
push  word 0xffff
push  word 0
retf

; WARM reboot (=no memory test)
WARM:
mov dx, msg2
call con_write
push  word 40h
pop   ds
mov   word [0x72], 0x1234
push  word 0xffff
push  word 0
retf

; Perform POWER OFF via BIOS APM
POFF:
mov dx, msg3
call con_write
mov ax, 5301h
xor bx, bx
int 15h		; enable Real Mode APM

mov ax, 530Fh
mov cx, 1
int 15h		; engage APM

mov ax, 5307h
inc bx
mov cx, 3
int 15h		; set POWER OFF

end:
int 20h

msg1 db 'COLD REBOOT$'
msg2 db 'WARM REBOOT$'
msg3 db 'POWER OFF$'
