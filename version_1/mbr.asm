

org 0x7c00

;文本模式下的es
mov ax,0xb800
mov es,ax

mov byte [es:0x00],'O'
mov byte [es:0x01],0x4c
mov byte [es:0x02],'S'
mov byte [es:0x03],0x4c


;
infi:
jmp near infi

;填充0，直到510Bytes
times 510-($-$$) db 0

;魔数
db 0x55,0xaa