
LOADER_ADDR equ 0x900

section core vstart=LOADER_ADDR

jmp LOADER_START

;信息
LOADER_MSG_1: db 'boot ok'
LOADER_MSG_2: db 'loading...'

DESK_NULL:	dd 0x00000000,0x00000000
DESK_CODE:	dd 0x0000ffff,00000000_1_1_0_0_1111_1_00_1_1000_00000000b
DESK_DATA:	dd 0x0000ffff,00000000_1_1_0_0_1111_1_00_1_0010_00000000b
DESK_VIDEO:	dd 0x80000007,00000000_1_1_0_0_0000_1_00_1_0010_00001011b

SELECTOR_NULL equ 0x0<<3
SELECTOR_CODE equ 0x1<<3
SELECTOR_DATA equ 0x2<<3
SELECTOR_VIDEO equ 0x3<<3

GDT_PTR: 	dw (DESK_CODE-DESK_NULL) * 4;偏移长度，所以也可以写成(DESK_DATA-DECK_CODE) * 4
			dd	DESK_NULL
LOADER_START:
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

;开启a20
in al,0x92
or al,00000010b
out 0x92,al

;加载gdt
lgdt [GDT_PTR]

;开启pe0
mov eax,cr0
or eax,0x1
mov cr0,eax

;刷新流水线
jmp dword SELECTOR_CODE:PROTECT_MODE_START

;转换编码
[bits 32]

PROTECT_MODE_START:
mov ax,SELECTOR_DATA
mov ds,ax
mov es,ax
mov ss,ax
mov esp,LOADER_ADDR

mov ax,SELECTOR_VIDEO
mov gs,ax

mov byte [gs:640],'l'
mov byte [gs:641],0x4c
mov byte [gs:642],'o'
mov byte [gs:643],0x4c
mov byte [gs:644],'a'
mov byte [gs:645],0x4c
mov byte [gs:646],'d'
mov byte [gs:647],0x4c
mov byte [gs:648],''
mov byte [gs:649],0x4c
mov byte [gs:650],'o'
mov byte [gs:651],0x4c
mov byte [gs:652],'k'
mov byte [gs:653],0x4c



;暂停在此
jmp $

