
;初始化编译地址
org 0x7c00

;转跳到代码区
jmp START
nop

;自定义栈顶
Stack_Base equ 0x7c00

START:
;初始化段寄存器
;此处cs=0x0000,ip=0x7c00
mov ax,cs
mov ds,ax
mov ss,ax
mov sp,Stack_Base
;文本模式下的es
mov ax,0xb800
mov es,ax
;使用文本内存显示
mov byte [es:0x00],'O'
mov byte [es:0x01],0x4c
mov byte [es:0x02],'S'
mov byte [es:0x03],0x4c
mov byte [es:0x04],' '
mov byte [es:0x05],0x4c
;使用bios中断显示
push ds
pop es
mov bp,BOOTMSG
mov cx,10
mov dh,1
mov dl,0
mov bh,0
mov al,0
mov bl,0x4c
mov ah,0x13
int 0x10
BOOTMSG:db 'booting...'

;循环，暂停在此
infi:
jmp near infi

;填充0，直到510Bytes
times 510-($-$$) db 0

;魔数
db 0x55,0xaa