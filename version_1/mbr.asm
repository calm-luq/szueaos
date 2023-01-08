
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
;清屏，ah=0x06或者0x07
mov ah,0x06
mov al,0x00
mov bh,0x00
mov cx,0x0000
mov dx,0x184f
int 0x10
;文本模式下的es
mov ax,0xb800
mov es,ax
;使用文本内存显示
mov byte [es:10],'O'
mov byte [es:11],0x4c
mov byte [es:12],'S'
mov byte [es:13],0x4c
;使用bios中断显示
push ds
pop es
mov bp,BOOTMSG1
mov cx,5
mov dh,0
mov dl,0
mov bh,0
mov al,0
mov bl,0x4c
mov ah,0x13
int 0x10

mov bp,BOOTMSG2
mov cx,10
mov dh,1
mov dl,0
mov bh,0
mov al,0
mov bl,0x4c
mov ah,0x13
int 0x10
;等待键盘按键
mov ah,0
int 0x16
;滚行，屏幕下卷
mov ah,0x07
mov al,23
mov ch,3
mov cl,0
mov dh,24
mov dl,79
mov bh,0x77
int 0x10

;循环，暂停在此
infi:
jmp near infi
BOOTMSG1:db 'szuea'
BOOTMSG2:db 'booting...'

mov ah,0x07
mov al,0x01
mov bh,0x00
mov cx,0x0000
mov dx,0x184f
int 0x10
;填充0，直到510Bytes
times 510-($-$$) db 0

;魔数
db 0x55,0xaa