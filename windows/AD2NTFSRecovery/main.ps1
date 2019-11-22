
# Maximum name lenght of group is 64 bytes!

#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
Import-Module activedirectory

$OrganizationalUnitDN = 'OU=NewGroups,dc=test,DC=ru'
$ADController = "localhost"
$WorkingShareFull = "c:\share"
$Levels = 3
$LevelsChar = "\*"


function add-adgroup ($groupname) {
    try {
        New-ADGroup -GroupCategory "Security" -GroupScope "DomainLocal" -Name "$groupname" -Path "$OrganizationalUnitDN" -SamAccountName "$groupname" -Server "$ADController" -ErrorAction Stop
#===>>        return "Group $groupname created."
    }
    catch {
        return "Catcher: " + "$groupname " + $_
    }
}

function add-admember ($groupname, $member) {
    try {
	if ($member -like "*\*") { 
		$member = ($member.Value).Split("\",2) 
		if ($member[0] -eq (Get-ADDomain).NetBIOSName -and $groupname -ne $member[1]) {
			Add-AdGroupMember -Identity $groupname -Members $member[1]
#===>>			return "Member $member added to group $groupname."
		}
	} elseif ($groupname -ne $member) {
		Add-AdGroupMember -Identity $groupname -Members $member
#===>>		return "Member $member added to group $groupname."
	} else {
		return "Member $member can not added to istself or member not in working domain."
	}
    }
	catch {
		return "Catcher: " + "$member " + $_
	}
}

<# Extended Permissions
+-------------+------------------------------+------------------------------+
|    Value    |             Name             |            Alias             |
+-------------+------------------------------+------------------------------+
| -2147483648 | GENERIC_READ                 | GENERIC_READ                 |
|           1 | ReadData                     | ListDirectory                |
|           1 | ReadData                     | ReadData                     |
|           2 | CreateFiles                  | CreateFiles                  |
|           2 | CreateFiles                  | WriteData                    |
|           4 | AppendData                   | AppendData                   |
|           4 | AppendData                   | CreateDirectories            |
|           8 | ReadExtendedAttributes       | ReadExtendedAttributes       |
|          16 | WriteExtendedAttributes      | WriteExtendedAttributes      |
|          32 | ExecuteFile                  | ExecuteFile                  |
|          32 | ExecuteFile                  | Traverse                     |
|          64 | DeleteSubdirectoriesAndFiles | DeleteSubdirectoriesAndFiles |
|         128 | ReadAttributes               | ReadAttributes               |
|         256 | WriteAttributes              | WriteAttributes              |
|         278 | Write                        | Write                        |
|       65536 | Delete                       | Delete                       |
|      131072 | ReadPermissions              | ReadPermissions              |
|      131209 | Read                         | Read                         |
|      131241 | ReadAndExecute               | ReadAndExecute               |
|      197055 | Modify                       | Modify                       |
|      262144 | ChangePermissions            | ChangePermissions            |
|      524288 | TakeOwnership                | TakeOwnership                |
|     1048576 | Synchronize                  | Synchronize                  |
|     2032127 | FullControl                  | FullControl                  |
|   268435456 | GENERIC_ALL                  | GENERIC_ALL                  |
|   536870912 | GENERIC_EXECUTE              | GENERIC_EXECUTE              |
|  1073741824 | GENERIC_WRITE                | GENERIC_WRITE                |
+-------------+------------------------------+------------------------------+
ContainerInherit (CI) - ��������� ����������
ObjectInherit (OI) - ��������� �������
InheritOnly (IO) - ������ ������������
NoPropagateInherit (NP) - �� �������������� ������������
None - ������������ ������ �� ��� ������� ������

This folder only - ��� ������. �� ��������� ��� ���������� ����� ����������� ������ �� ������ ������.
This folder, subfolders and Files - CI, OI, None
This folder and subfolders - CI, None
This folder and files - OI, None
Subfolders and Files only - CI, OI, IO
Subfolders only - CI, IO
Files only - OI, IO

[system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit"
[system.security.accesscontrol.PropagationFlags]"InheritOnly"

#>
function add-group2fs ($path, $object, $permissions, $inherit) {
#Permissions: 	FullControl, ReadAndExecute, Modify
	if (!$inherit) { $inherit = "ContainerInherit, ObjectInherit" }
	try {
		$principal = (Get-ADGroup $object).Name
#		$FileSystemAccessRights = [System.Security.AccessControl.FileSystemRights]"FullControl"
#		$InheritanceFlags = [system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit"
#		$PropagationFlags = [system.security.accesscontrol.PropagationFlags]"InheritOnly"
#		$OwnerPrincipal = [System.Security.Principal.NTAccount]�Administrators�
#		$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($principal, $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, "Allow")
		$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($principal, "$permissions", $inherit, "None", "Allow")
		$acl = Get-Acl $path #(Get-Item $path).GetAccessControl('Access')
		$acl.SetAccessRule($AccessRule)
		$acl | Set-Acl $path

#		return "Member $principal added to folder $path with $permissions permissions."
	}
	catch {
		return "Catcher: " + $_
	}
}

function translit([string]$inString)
{
    #Dependency table
    $translit = @{
    [char]'�' = "a"
    [char]'�' = "A"
    [char]'�' = "b"
    [char]'�' = "B"
    [char]'�' = "v"
    [char]'�' = "V"
    [char]'�' = "g"
    [char]'�' = "G"
    [char]'�' = "d"
    [char]'�' = "D"
    [char]'�' = "e"
    [char]'�' = "E"
    [char]'�' = "yo"
    [char]'�' = "Yo"
    [char]'�' = "zh"
    [char]'�' = "Zh"
    [char]'�' = "z"
    [char]'�' = "Z"
    [char]'�' = "i"
    [char]'�' = "I"
    [char]'�' = "j"
    [char]'�' = "J"
    [char]'�' = "k"
    [char]'�' = "K"
    [char]'�' = "l"
    [char]'�' = "L"
    [char]'�' = "m"
    [char]'�' = "M"
    [char]'�' = "n"
    [char]'�' = "N"
    [char]'�' = "o"
    [char]'�' = "O"
    [char]'�' = "p"
    [char]'�' = "P"
    [char]'�' = "r"
    [char]'�' = "R"
    [char]'�' = "s"
    [char]'�' = "S"
    [char]'�' = "t"
    [char]'�' = "T"
    [char]'�' = "u"
    [char]'�' = "U"
    [char]'�' = "f"
    [char]'�' = "F"
    [char]'�' = "h"
    [char]'�' = "H"
    [char]'�' = "c"
    [char]'�' = "C"
    [char]'�' = "ch"
    [char]'�' = "Ch"
    [char]'�' = "sh"
    [char]'�' = "Sh"
    [char]'�' = "sch"
    [char]'�' = "Sch"
    [char]'�' = ""
    [char]'�' = ""
    [char]'�' = "y"
    [char]'�' = "Y"
    [char]'�' = ""
    [char]'�' = ""
    [char]'�' = "e"
    [char]'�' = "E"
    [char]'�' = "yu"
    [char]'�' = "Yu"
    [char]'�' = "ya"
    [char]'�' = "Ya"
    [char]'/' = "_"
    [char]'\' = "_"
    [char]'[' = "_"
    [char]']' = "_"
    [char]';' = "_"
    [char]':' = "_"
    [char]'|' = "_"
    [char]'=' = "_"
    [char]',' = "_"
    [char]'+' = "_"
    [char]'*' = "_"
    [char]'?' = "_"
    [char]'<' = "_"
    [char]'>' = "_"
    [char]'"' = "_"
    [char]'%' = "_"
    [char]' ' = "_"
    }
#    [string]$inString = Read-Host "Debug, enter string"
    $translitText =""
    foreach ($CHR in $inCHR = $inString.ToCharArray())
        {
        if ($translit[$CHR] -cne $Null) 
            { $translitText += $translit[$CHR] }
        else
            { $translitText += $CHR }
        }
    return $translitText
}

# Turn off inheritance and clear all inherite objects
function inhitoff($path) {
    try {
        $acl = Get-Acl $path
        $acl.SetAccessRuleProtection($True, $false)
        $acl | Set-Acl $path
#===>>        return "Turn Off inheritance on folder $path."
    }
    catch {
        return "Catcher: " + $_
    }
}

# Turn on inheritance
function inhiton($path) {
    try {
	   $acl = Get-Acl $path
	   $acl.SetAccessRuleProtection($false, $false)
	   $acl | Set-Acl $path
#===>>        return "Turn On inheritance on folder $path."
    }
    catch {
        return "Catcher: " + $_
    }
}

# Remove all permissions Except inherited
function removePerm($path) {
	$acl = (Get-Acl $path)
	$accessToRemove = $acl.Access | ?{ $_.IsInherited -eq $false }
	if ($accessToRemove) {
		foreach ($item in $accessToRemove) {
		    $acl.RemoveAccessRuleAll($item)
		}
		Set-Acl -AclObject $acl $path
	}
}


# Get permissions from ntfs, create AD group, add members to AD group
function retrAndSetPerm($path, $pathroot) {
	$nameforad = translit(($path -replace ((Split-Path $pathroot) -replace "\\","\\"), "") -replace "^\\", "")
	$pathupper = translit(((Split-Path $path) -replace ((Split-Path $pathroot) -replace "\\","\\"), "") -replace "^\\", "")

	# Turn On Inheritance
	#inhiton $path
	write-host "inhiton $path"

	# Create groups
	#add-adgroup "$($nameforad)_FC"
	#add-adgroup "$($nameforad)_RW"
	#add-adgroup "$($nameforad)_RO"
	#add-adgroup "$($nameforad)_TR"

	write-host "add-adgroup $($nameforad) _FC"
	write-host "add-adgroup $($nameforad) _RW"
	write-host "add-adgroup $($nameforad) _RO"
	write-host "add-adgroup $($nameforad) _TR"

	if ($pathupper) {
		add-admember "$($pathupper)_TR" "$($nameforad)_FC" 
		add-admember "$($pathupper)_TR" "$($nameforad)_RW" 
		add-admember "$($pathupper)_TR" "$($nameforad)_RO" 
		add-admember "$($pathupper)_TR" "$($nameforad)_TR" 
	}

        # Fill created groups
	foreach ($item in ((Get-Acl $path).Access | ?{ $_.IsInherited -eq $false }) ) {
            if ($item.FileSystemRights -like "*FullControl*") {
                add-admember "$($nameforad)_FC" $item.IdentityReference
    		} elseif ($item.FileSystemRights -like "*Modify*") {
        		add-admember "$($nameforad)_RW" $item.IdentityReference
    		} elseif ($item.FileSystemRights -like "*ReadAndExecute*") {
        		add-admember "$($nameforad)_RO" $item.IdentityReference
    		} else {
        		write-host "Object $($item.IdentityReference) did not added to $path because permissions is $($item.FileSystemRights)" 
        	}	
	}

	# Remove all permissions Except inherited
	removePerm $path
	
	# Add created groups to ntfs
	add-group2fs "$path" "$($nameforad)_FC" "FullControl"
	add-group2fs "$path" "$($nameforad)_RW" "Modify"
	add-group2fs "$path" "$($nameforad)_RO" "ReadAndExecute"
	add-group2fs "$path" "$($nameforad)_TR" "33" "None"

}


#######################################################
### Main Program

clear 

for ($i=0; $i -le $Levels; $i++) {
	if ($i -eq 0) {
		$FullName = get-item $WorkingShareFull | %{ $_.FullName}
	} else {
		$FullName = get-childitem ($WorkingShareFull + $LevelsChar * $i) | ?{$_.PSIsContainer} | %{ $_.FullName}
	}
#===>>	write-host "Directory:" $FullName
	foreach ($FullNameItem in $FullName) {
		retrAndSetPerm $FullNameItem $WorkingShareFull
	}
}






<#
#add-adgroup "$(translit($WorkingShare))_TR"
#add-group2fs $WorkingShareFull "$(translit($WorkingShare))_TR" "33" "ContainerInherit"





translit ("eewefg�����������������42�2345234�(*)*?(-=-_=+;:[]{}\/*&7^?/.,")
add-adgroup "testttt"
add-admember "testttt" "Vasiliy"
add-group2fs "$WorkingShare" "LocalGroup" "ReadAndExecute"
inhitoff "$WorkingShare"
inhiton "$WorkingShare"
retrAndSetPerm $WorkingShareFull $WorkingShareFull
removePerm $path


#>