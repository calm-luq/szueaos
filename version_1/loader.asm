org 0x900

mov bp,LOADER_MSG_1
mov cx,7
mov dh,2
mov dl,0
mov bh,0
mov al,0
mov bl,0x4c
mov ah,0x13
int 0x10

mov bp,LOADER_MSG_2
mov cx,10
mov dh,3
mov dl,0
mov bh,0
mov al,0
mov bl,0x4c
mov ah,0x13
int 0x10

;暂停在此
jmp $

;信息
LOADER_MSG_1: db 'boot ok'
LOADER_MSG_2: db 'loading...'
