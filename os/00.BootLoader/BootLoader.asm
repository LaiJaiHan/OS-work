[ORG 0x00]         
[BITS 16]         

SECTION .text      

jmp 0x07C0:START   

TOTALSECTORCOUNT:  dw  0x02    

KERNEL32SECTORCOUNT: dw 0x02

START:
    mov ax, 0x07C0 
    mov ds, ax      
    mov ax, 0xB800  
    mov es, ax      

    
    mov ax, 0x0000  
    mov ss, ax     
    mov sp, 0xFFFE  
    mov bp, 0xFFFE  

   

    mov si,    0                   
        
.SCREENCLEARLOOP:                   
    mov byte [ es: si ], 0         

    mov byte [ es: si + 1 ], 0x0A   


    add si, 2                      

    cmp si, 80 * 25 * 2     

    jl .SCREENCLEARLOOP    
                           
  

    ;push MESSAGE1               
    ;push 0                     
    ;push 0                      
    ;call PRINTMESSAGE           
    ;add  sp, 6                 
    

	push RAMSIZEMESSAGE	
	push 1
	push 0
	call PRINTMESSAGE
	add sp, 6
	
	call GET_RAM
	lea ecx, [ram]
	push ecx
	push 1
	push 11
	call PRINTMESSAGE	
	add sp, 6



	push SIZEMESSAGE	
	push 1
	push 14
	call PRINTMESSAGE	
	add sp, 6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;call GET_DATE
    ;lea dx, [date]
    ;push dx
    ;push 1
    ;push 15
    ;call PRINTMESSAGE
    ;add sp, 6  
 
    ;mov ah, 09h
    ;int 21h
    ;mov ax, 4c00h
    ;int 21h
   

    ;push CURRENTDATA
    ;push 1
    ;push 0
    ;call PRINTMESSAGE
    ;add sp, 6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    push IMAGELOADINGMESSAGE
    push 0
    push 0 
    call PRINTMESSAGE
    add sp, 6
    
    ;
                         
    
RESETDISK:                          
    
    mov ax, 0
    mov dl, 0              
    int 0x13     
    ;
    jc  HANDLEDISKERROR
        
    
    mov si, 0x1000                 
                                    
    mov es, si                      
    mov bx, 0x0000                  

    mov di, word [ TOTALSECTORCOUNT ]

READDATA:                           
    

    cmp di, 0                
    je  READEND              
    sub di, 0x1             

   

    mov ah, 0x02                        
    mov al, 0x1                        
    mov ch, byte [ TRACKNUMBER ]        
    mov cl, byte [ SECTORNUMBER ]        
    mov dh, byte [ HEADNUMBER ]          
    mov dl, 0x00                         
    int 0x13                             
    jc HANDLEDISKERROR                   
    
   


    add si, 0x0020       
    mov es, si           
    
  
    mov al, byte [ SECTORNUMBER ]        
    add al, 0x01                        
    mov byte [ SECTORNUMBER ], al        
    cmp al, 19                           
    jl READDATA                         
    
    

    xor byte [ HEADNUMBER ], 0x01        
    mov byte [ SECTORNUMBER ], 0x01      
    
   

    cmp byte [ HEADNUMBER ], 0x00       
    jne READDATA                         
    
   
    add byte [ TRACKNUMBER ], 0x01       
    jmp READDATA                         

READEND:

    
    push LOADINGCOMPLETEMESSAGE      
    push 0                           
    push 20                          
    call PRINTMESSAGE                
    add  sp, 6                       

    
    jmp 0x1000:0x0000
    

HANDLEDISKERROR:
    push DISKERRORMESSAGE    
    push 1                   
    push 20                  
    call PRINTMESSAGE        
    
    jmp $                    


PRINTMESSAGE:
    push bp          
    mov bp, sp       
                     
    push es          
    push si          
    push di         
    push ax
    push cx
    push dx
   
    mov ax, 0xB800               
    mov es, ax                   
    
    mov ax, word [ bp + 6 ]      
    mov si, 160                  
    mul si                       
    mov di, ax                    
   
    mov ax, word [ bp + 4 ]      
    mov si, 2                    
    mul si                       
    add di, ax                   
                                 
    mov si, word [ bp + 8 ]      

.MESSAGELOOP:                
    mov cl, byte [ si ]      
                          
    cmp cl, 0                
    je .MESSAGEEND           
                             

    mov byte [ es: di ], cl  

    add si, 1                
    add di, 2                
                                                   
    jmp .MESSAGELOOP         

.MESSAGEEND:
    pop dx       
    pop cx       
    pop ax       
    pop di       
    pop si       
    pop es
    pop bp       
    ret          
    
GET_RAM:
	mov ax, 20h
	int 15h
	
	mov ecx, ram

	call put_ram
	inc eax
	ret

put_ram:
    push eax
    shr eax, 4
    and eax, 0fh
    add eax, '0'
    mov [ecx], eax
    inc ecx
    pop eax
    and eax, 0fh
    add eax, '0'
    mov [ecx], eax
    inc ecx
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GET_DATE:
;     mov ah,04h
;     int 1ah
;     mov bx, date
;     mov al,dh
;     call put_bcd2
;     inc bx
 
;     mov al,dl 
;     call put_bcd2
;     inc bx

    
;     mov al,ch
;     call put_bcd2
;     mov al,cl
;     call put_bcd2
;     ret
    

;put_bcd2:
;    push ax
;    shr ax, 4
;    and ax,0fh
;    add ax, '0'
;    mov [bx], al
;    inc bx
;    pop ax
;    and ax,0fh
;    add ax, '0'
;    mov [bx], al
;    inc bx
;    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;MESSAGE1:    db 'MINT64 OS Boot Loader Start~!!', 0  

RAMSIZEMESSAGE: db 'RAM Size : ', 0
;CURRENTDATA: db 'Current Data : ', 0
DISKERRORMESSAGE:       db  'DISK Error~!!', 0
IMAGELOADINGMESSAGE:    db  'OS Image Loading...', 0
LOADINGCOMPLETEMESSAGE: db  'Complete~!!', 0
SIZEMESSAGE: db 'MB', 0


SECTORNUMBER:           db  0x02     
HEADNUMBER:             db  0x00     
TRACKNUMBER:            db  0x00     

;date: db "00/00/0000", 0, 0,
ram: db 0
times 510 - ( $ - $$ )    db    0x00     
                                       

db 0x55              
db 0xAA  
