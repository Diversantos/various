Dim WSHShell, ask_link
set WSHShell = WScript.CreateObject("WScript.Shell")

'ask_link =  WSHShell.Popup ("������� ������ �� ������� ���� � ���������?", 0, "AddLink", vbYesNo + vbInformation + vbDefaultButton1)
'if ask_link = vbNo Then
'    WScript.Quit()
'end if
'������ �� ������� ����
CreateLink "AllUsersDesktop", "��������� ��������� Word", "C:\Program Files\Microsoft Office\Office", "winword.exe", 0
CreateLink "AllUsersDesktop", "����������� ������� Excel", "C:\Program Files\Microsoft Office\Office", "excel.exe", 0
CreateLink "AllUsersDesktop", "Public", "C:", "public", "%SystemRoot%\system32\SHELL32.dll, 9"
' ������ � ���������
CreateUrlLink "Russian Guns", "http://diversant.h1.ru"
CreateUrlLink "������� �������", "http://www.konfetki.ru"
CreateUrlLink "��� �����", "http://www.rotfront.ru"

function CreateLink(target_path, name_link, source_path, source_name, icon_number)
' ��������� ������ WSHShell (WScript.Shell)
' ������� �������� �������.
'
' target_path - ������ ���� �� ����� ���������� ��� 
'	Desktop - ������� ����, 
'	Favorites - ���������, 
'	Fonts - ������,
'	MyDocuments - ��� ���������, 
'	NetHood - ������� ���������, 
'	PrintHood - ��������, 
'	Programs - ������� ��������� �� ���� ����,
'	Recent - ������� ��������� �� ���� ����, 
'	SendTo - ������� ��������� �� ������������ ���� ������, 
'	StartMenu - ������� ����,
'	Startup - ������������ �� ������� ���������, 
'	Templates - �������
'	AllUsersDesktop, AllUsersStartMenu, AllUsersPrograms, AllUsersStartup - 
'	��� ������������ ������ � WinNT/2000/XP
' name_link - ��� ������
' source_path - ������ ���� �� ������������ �����
' source_name - ��� ������������ �����
' icon_number - ��� ����� ������ ��� ������ (����� ��� ������ ���� �� ����� � �������� ����� "C:\winnt.exe, 0")
'
    if isNumeric(icon_number) Then
           icon_path = (source_path & "\" & source_name & ", " & icon_number)
	Else
           icon_path = icon_number
    end if
    desktop_path = WSHShell.SpecialFolders(target_path)
    set MyShortcut = WSHShell.CreateShortcut (desktop_path + "\\" + name_link + ".lnk")
    MyShortcut.TargetPath = WSHShell.ExpandEnvironmentStrings(source_path + "\" + source_name)
    MyShortcut.WorkingDirectory = WSHShell.ExpandEnvironmentStrings(source_path)
'    MyShortcut.HotKey = ("CTRL+ALT+W")
    MyShortcut.WindowStyle = 4
    MyShortcut.IconLocation = WSHShell.ExpandEnvironmentStrings (icon_path)
    MyShortcut.Save()
end function

function CreateUrlLink(name_url, full_url)
' ��������� ������ WSHShell (WScript.Shell)
' ������� ��� �������� URL ������ � ���������.
'
' name_url - ��� ������
' full_url - ������ ���� � ��������� ������� (ftp://ftp.kernel.org)
'
    favorites_path = WSHShell.SpecialFolders("Favorites")
    set MyShortcut = WSHShell.CreateShortcut(favorites_path + "\\" + name_url + ".url")
    MyShortcut.TargetPath = WSHShell.ExpandEnvironmentStrings(full_url)
    MyShortcut.Save()
end function
