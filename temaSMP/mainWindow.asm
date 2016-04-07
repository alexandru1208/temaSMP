.386
.model flat,stdcall
option casemap:none
include d:\masm32\include\windows.inc
include d:\masm32\include\user32.inc
includelib d:\masm32\lib\user32.lib
include d:\masm32\include\kernel32.inc
includelib d:\masm32\lib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD ;prototipul ferestrei

;declarare varriabile globale cu intitalizare
.DATA
	ClassName db "SimpleWinClass",0
	AppName db "Our First Window",0

;declarare variabile gloable fara initializare
.DATA?
	hInstance HINSTANCE ?

.CODE
start:
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
		WS_OVERLAPPEDWINDOW,\
		CW_USEDEFAULT,\
		CW_USEDEFAULT,\
		CW_USEDEFAULT,\
		CW_USEDEFAULT,\
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
		.IF uMsg==WM_DESTROY
			invoke PostQuitMessage,NULL
		.ELSE
			invoke DefWindowProc,hWnd,uMsg,wParam,lParam
			ret
		.ENDIF
		xor eax,eax
		ret
	WndProc endp

end start