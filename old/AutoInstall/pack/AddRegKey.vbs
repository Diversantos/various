Dim WSHShell, ask_reg_key
set WSHShell = WScript.CreateObject("WScript.Shell")

'ask_reg_key =  WSHShell.Popup ("���������� ����� �������?", 0, "AddRegKey", vbYesNo + vbInformation + vbDefaultButton1)
'if ask_reg_key = vbNo Then
'    WScript.Quit()
'end if
' ��������� ��� Internet Explorer
WSHShell.RegWrite "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\Delete_Temp_Files_On_Exit", "yes"
WSHShell.RegWrite "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\UrlTemplate\5", "www.%s.ru"
'WSHShell.RegWrite "HKLM\SOFTWARE\Microsoft\Internet Explorer\Main\Start Page", "http://coropative.redoctober.ru"
' ���������� ����������� CD
WSHShell.RegWrite "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\CDRAutoRun", 0, "REG_DWORD"
WSHShell.RegWrite "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDriveTypeAutoRun", 0, "REG_DWORD"
WSHShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Services\CDRom\Autorun", 0, "REG_DWORD"
' ��������� NumLock
WSHShell.RegWrite "HKCU\Control Panel\Keyboard\InitialKeyboardIndicators", 2
WSHShell.RegWrite "HKEY_USERS\.DEFAULT\Control Panel\Keyboard\InitialKeyboardIndicators", 2
' ������ ��� ����� �������
WSHShell.RegWrite "HKCR\Piffile\IsShortcut", "-"
WSHShell.RegWrite "HKCR\Lnkfile\IsShortcut", "-"
WSHShell.RegWrite "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Link", 0, "REG_DWORD"
' ���������� ��������������� ���������� IP ������� 169.254.x.x
WSHShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\IPAutoconfigurationEnabled", 0, "REG_DWORD"
' ��������� Windows Update
'WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\WUServer", "http://10.0.0.1"
'WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\WUStatusServer", "http://10.0.0.1"
'WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\UseWUServer", 1, "REG_DWORD"
' ��������� ��������
WSHShell.RegWrite "HKEY_USERS\.DEFAULT\Control Panel\Desktop\ScreenSaveActive", "0"
WSHShell.RegWrite "HKEY_USERS\.DEFAULT\Control Panel\Desktop\ScreenSaveTimeOut", "0"
' ������ ������������ ���� ��� ������ � �����
'WSHShell.RegWrite "HKCR\*\shellex\ContextMenuHandlers\Copyto\@", "{C2FBB630-2971-11d1-A18C-00C04FD75D13}"
'WSHShell.RegWrite "HKCR\*\shellex\ContextMenuHandlers\Moveto\@", "{C2FBB631-2971-11d1-A18C-00C04FD75D13}"
' ��������� �������� ������ ��� I/O ��������
'WSHShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\IoPageLockLimit", 65536000, "REG_DWORD"
' ���������� �������� ������� ������������� 8.3 ��� MS-DOS
'WSHShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\NtfsDisable8dot3NameCreation", 1, "REG_DWORD"
' ���������� Null ������ (��������� ��������� ������ ������������� �������� ������� ������ � ����������� �������; 2 - ��������� NetBIOS ��� �����)
'WSHShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\RestrictAnonymous", 2, "REG_DWORD"
' ��������� ����������� Dial-Up
'WSHShell.RegWrite "HKLM\System\CurrentControlSet\Services\Rasman\Parameters\Logging", 1, "REG_DWORD"
' ���������� ���� ��� ADMIN$, C$, D$,...
'WSHShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters\AutoShareServer", 0, "REG_DWORD"
'WSHShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters\AutoShareWks", 0, "REG_DWORD"
' ������ ��� ���������� ���������
'WSHShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters\Hidden", 1, "REG_DWORD"


