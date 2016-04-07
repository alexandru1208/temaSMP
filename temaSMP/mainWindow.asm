.386
.model flat,stdcall
option casemap:none
include d:\masm32\include\windows.inc
include d:\masm32\include\user32.inc
include d:\masm32\include\gdi32.inc 
include d:\masm32\include\kernel32.inc
includelib d:\masm32\lib\user32.lib
includelib d:\masm32\lib\kernel32.lib
includelib d:\masm32\lib\gdi32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD ;prototipul ferestrei

.const 
IDB_BACKGROUND  equ 1 
IDB_BEE equ 2

;declarare varriabile globale cu intitalizare
.DATA
	BitmapName  db "MyBitMap",0 
	MsgBoxCaption db "Bun Venit!",0
	MsgBoxText db "Aceasta este prima mea aplicatie in assembly :)!",0
	ClassName db "SimpleWinClass",0
	AppName db "Plimba gandacul",0

;declarare variabile gloable fara initializare
.DATA?
	hInstance HINSTANCE ?
	hBackgroundBitmap dd ? 
	hBeeBitmap dd ?

.CODE
start:
	invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK
	invoke GetModuleHandle, NULL ; obtinerea handlerului
	mov hInstance,eax
	invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT
	invoke ExitProcess, eax

	;metoda de creare a ferestrei
	WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD

		;declarare variabile locle
		LOCAL wc:WNDCLASSEX
		LOCAL msg:MSG
		LOCAL hwnd:HWND
		
		;setare caracteristici fereastra
		mov wc.cbSize,SIZEOF WNDCLASSEX
		mov wc.style, CS_HREDRAW or CS_VREDRAW
		mov wc.lpfnWndProc, OFFSET WndProc
		mov wc.cbClsExtra,NULL
		mov wc.cbWndExtra,NULL
		push hInstance
		pop wc.hInstance
		mov wc.hbrBackground,COLOR_WINDOW+1
		mov wc.lpszMenuName,NULL
		mov wc.lpszClassName,OFFSET ClassName
		invoke LoadIcon,NULL,IDI_APPLICATION
		mov wc.hIcon,eax
		mov wc.hIconSm,eax
		invoke LoadCursor,NULL,IDC_ARROW
		mov wc.hCursor,eax

		;instantiere fereastra
		invoke RegisterClassEx, addr wc
		invoke CreateWindowEx,NULL,\
		ADDR ClassName,\
		ADDR AppName,\
		WS_OVERLAPPED or WS_SYSMENU or WS_MINIMIZEBOX,\ ;nu se poate redimensiona
		100,80,1111,639,\ ;dimensiune fixa
		NULL,\
		NULL,\
		hInst,\
		NULL
		
		;afiseaza fereastra
		mov hwnd,eax
		invoke ShowWindow, hwnd,CmdShow
		invoke UpdateWindow, hwnd

		;bucla de mesaje
		.WHILE TRUE
			invoke GetMessage, ADDR msg,NULL,0,0
			.BREAK .IF (!eax)
			invoke TranslateMessage, ADDR msg
			invoke DispatchMessage, ADDR msg
		.ENDW
		mov eax,msg.wParam
		ret
	WinMain endp

	;metoda penru tratare mesajelor
	WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
		 LOCAL ps:PAINTSTRUCT 
		 LOCAL hdc:HDC 
		 LOCAL hMemDC:HDC 
		 LOCAL rect:RECT 
		 .IF uMsg==WM_CREATE 
			invoke LoadBitmap,hInstance,IDB_BACKGROUND 
			mov hBackgroundBitmap,eax 
			invoke LoadBitmap,hInstance,IDB_BEE
			mov hBeeBitmap,eax 
		 .ELSEIF uMsg==WM_PAINT 
			invoke BeginPaint,hWnd,addr ps 
			mov    hdc,eax 
			
			invoke CreateCompatibleDC,hdc 
			mov    hMemDC,eax 
			invoke SelectObject,hMemDC,hBackgroundBitmap 
			invoke GetClientRect,hWnd,addr rect 
			invoke BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY 
			invoke DeleteDC,hMemDC 
			
			invoke CreateCompatibleDC,hdc 
			mov    hMemDC,eax 
			invoke SelectObject,hMemDC,hBeeBitmap 
			invoke GetClientRect,hWnd,addr rect 
			invoke BitBlt,hdc,300,400,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY 
			invoke DeleteDC,hMemDC 

			invoke EndPaint,hWnd,addr ps 

		

		.ELSEIF uMsg==WM_DESTROY 
			invoke DeleteObject,hBackgroundBitmap 
			invoke DeleteObject,hBeeBitmap 
			invoke PostQuitMessage,NULL 
		.ELSEIF uMsg==WM_KEYDOWN
			
		.ELSE 
			invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
			 ret 
		.ENDIF 
		xor eax,eax
		ret
	WndProc endp

end start