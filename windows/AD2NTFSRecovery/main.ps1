
# Maximum name lenght of group is 64 bytes!

#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
Import-Module activedirectory

$WorkingShareFull = "F:\FileServer"
$ADController = "serverdc.DOMAIN.ru"
$OrganizationalUnitDN = 'OU=FS,OU=_TEST,dc=DOMAIN,DC=ru'
$DomainAdmins = "DOMAIN\Domain Admins"
$DomainAdmins2 = "DOMAIN\ExternalServerAdmins"
$DomainAdmins3 = "DOMAIN\ServerAdmins"
$rootspecialgroup = "PREFIX-Fileserver_S"
$prefix = "PREFIX-"
$timeout = 180
$Levels = 2
$LevelsChar = "\*"

if (!(Test-Path $WorkingShareFull)) {
	write-host "Working filder does not exist"
	exit
}


function add-adgroup ($groupname) {
    try {
        New-ADGroup -GroupCategory "Security" -GroupScope "DomainLocal" -Name "$groupname" -Path "$OrganizationalUnitDN" -SamAccountName "$groupname" -Server "$ADController" -ErrorAction Stop
#===>>        return "Group $groupname created."
    }
    catch {
        return "Catcher AddGroup: " + "$groupname " + $_
    }
}

function waitGroup($object, $timeout) {
    while ($timeout -gt 0) {
        Start-Sleep -Seconds 1
        try {
            if ((Get-ADGroup $object).Name) {
                $timeout = 0
            }
        } catch {
            write-host -NoNewline "."
            $timeout = $timeout - 1
        }
    }
}

function add-admember ($groupname, $member) {
	# If given Identity with domain prefix then cut domain else use as is
	if ($member -like "*\*") { 
		$member = ($member.Value).Split("\",2) 
		if ($member[0] -eq (Get-ADDomain).NetBIOSName -and $groupname -ne $member[1]) { 
			$member = $member[1] 
		} 
	} elseif ($groupname -ne $member) { 
	} else { 
		return "Member $member can not added to istself or member not in working domain." 
	}
    if ($member -like "*NT AUTHORITY SYSTEM*") {
        return "."
    }
	# Get type of AD object
	#$check = ((get-adobject -filter *) | ?{$_.name -like $member}).objectclass
    $check = (get-adobject -filter {samaccountname -like $member}).objectclass
	#	write-host "$check - $member"
	# If type is user add it to group
	if ($check -eq "user") { 
		try {
			Add-AdGroupMember -Identity $groupname -Members $member
			#===>> return "Member $member added to group $groupname."
		}
        catch [Microsoft.ActiveDirectory.Management.ADException] {}
		catch {
			return "Catch: Add $member 2 $groupname " + $_ + " " + $error[0].exception.gettype().fullname
		}
	# If type is group then get members and call oneself
	} elseif ($check -eq "group") {
		foreach ($item in Get-ADGroupMember $member) {
			# write-host $item.name
			add-admember $groupname $item.SamAccountName
		}
	} else {
		write-host "Member $member can not added to group $groupname because it not found or had different type than User or Group."
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
		$principal = $object #(Get-ADGroup -Server $ADController $object).Name
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
		return "Catcher AddGrp2FS: Obj: $object : " + $_
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
    [char]'�' = "y"
    [char]'�' = "Y"
    [char]'�' = "z"
    [char]'�' = "Z"
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
    [char]'�' = "c"
    [char]'�' = "C"
    [char]'�' = "s"
    [char]'�' = "S"
    [char]'�' = "s"
    [char]'�' = "S"
    [char]'�' = ""
    [char]'�' = ""
    [char]'�' = "y"
    [char]'�' = "Y"
    [char]'�' = ""
    [char]'�' = ""
    [char]'�' = "e"
    [char]'�' = "E"
    [char]'�' = "y"
    [char]'�' = "Y"
    [char]'�' = "y"
    [char]'�' = "Y"
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
function removePerm($path, $identity) {
	$acl = (Get-Acl $path)
    if ($identity -eq 1) {
	    $accessToRemove = $acl.Access | ?{ $_.IsInherited -eq $false }
    } else {
	    $accessToRemove = $acl.Access | ?{ $_.IsInherited -eq $false -and $_.IdentityReference -eq $identity}
    }
	if ($accessToRemove) {
		foreach ($item in $accessToRemove) {
		    $acl.RemoveAccessRuleAll($item)
		}
		Set-Acl -AclObject $acl $path
	} 
}

function resetperm($rootpath) {
	$firstLevel = get-childitem ($rootpath) | ?{$_.PSIsContainer} | %{ $_.FullName}
	foreach ($firstLevelItem in $firstLevel) {
		$secondLevel = get-childitem ($firstLevelItem) | ?{$_.PSIsContainer} | %{ $_.FullName}
		if ($secondLevel) {
			foreach ($secondLevelItem in $secondLevel) {
				write-host $secondLevelItem
				icacls "$secondLevelItem\*" /q /c /t /reset
			}
		}
	}
}


# Get permissions from ntfs, create AD group, add members to AD group
function retrAndSetPerm($path, $pathroot) {
    write-host -NoNewline "===> Working with $path"
	if ($path -eq $pathroot) {
		#$nameforad = translit(($path -replace ((Split-Path $pathroot) -replace "\\","\\"), "") -replace "^\\", "")
		#$pathupper = translit(((Split-Path $path) -replace ((Split-Path $pathroot) -replace "\\","\\"), "") -replace "^\\", "")
	} else {
		$nameforad = $prefix + (translit(($path -replace (($pathroot) -replace "\\","\\"), "") -replace "^\\", ""))
		$pathupper = $prefix + (translit(((Split-Path $path) -replace (($pathroot) -replace "\\","\\"), "") -replace "^\\", ""))
		$pathupperif = (translit(((Split-Path $path) -replace (($pathroot) -replace "\\","\\"), "") -replace "^\\", ""))
	}

	# Turn On Inheritance
	#inhiton $path
	#write-host "inhiton $path"

	# Create groups
	add-adgroup "$($nameforad)_F"
	add-adgroup "$($nameforad)_C"
	add-adgroup "$($nameforad)_R"
	add-adgroup "$($nameforad)_S"

    waitGroup "$($nameforad)_F" $timeout
    waitGroup "$($nameforad)_C" $timeout
    waitGroup "$($nameforad)_R" $timeout
    waitGroup "$($nameforad)_S" $timeout
    write-host "."


	if ($pathupperif) {
		Add-AdGroupMember -Identity "$($pathupper)_S" -Members "$($nameforad)_F" 
		Add-AdGroupMember -Identity "$($pathupper)_S" -Members "$($nameforad)_C" 
		Add-AdGroupMember -Identity "$($pathupper)_S" -Members "$($nameforad)_R" 
		Add-AdGroupMember -Identity "$($pathupper)_S" -Members "$($nameforad)_S" 
	} elseif ($pathupper -eq $prefix) {
		Add-AdGroupMember -Identity $rootspecialgroup -Members "$($nameforad)_F" 
		Add-AdGroupMember -Identity $rootspecialgroup -Members "$($nameforad)_C" 
		Add-AdGroupMember -Identity $rootspecialgroup -Members "$($nameforad)_R" 
		Add-AdGroupMember -Identity $rootspecialgroup -Members "$($nameforad)_S" 
	}

	add-group2fs "$path" $DomainAdmins "FullControl"
    Start-Sleep -Seconds 1
	add-group2fs "$path" $DomainAdmins2 "FullControl"
    Start-Sleep -Seconds 1
	add-group2fs "$path" $DomainAdmins3 "FullControl"
    Start-Sleep -Seconds 1
    
    # Fill created groups
	foreach ($item in ((Get-Acl $path).Access | ?{ $_.IsInherited -eq $false }) ) {
        if ($item.IdentityReference -like "CREATOR OWNER*") { 
        } elseif ($item.IdentityReference -like "BUILTIN*") { 
        } elseif ($item.IdentityReference -like $DomainAdmins) { 
        } elseif ($item.IdentityReference -like $DomainAdmins2) { 
        } elseif ($item.IdentityReference -like $DomainAdmins3) { 
        } else {
            if ($item.FileSystemRights -like "*FullControl*") {
                add-admember "$($nameforad)_F" $item.IdentityReference
                removePerm $path $item.IdentityReference
    		} elseif ($item.FileSystemRights -like "*Modify*") {
        		add-admember "$($nameforad)_C" $item.IdentityReference
                removePerm $path $item.IdentityReference
    		} elseif ($item.FileSystemRights -like "*ReadAndExecute*") {
        		add-admember "$($nameforad)_R" $item.IdentityReference
                removePerm $path $item.IdentityReference
    		} else {
        		write-host "Object $($item.IdentityReference) did not added to $path because permissions is $($item.FileSystemRights)" 
        	}	
        }
	}

    Start-Sleep -Seconds 15

    # Add created groups to ntfs
	add-group2fs "$path" "$($nameforad)_F" "FullControl"
    Start-Sleep -Seconds 1
	add-group2fs "$path" "$($nameforad)_C" "Modify"
    Start-Sleep -Seconds 1
	add-group2fs "$path" "$($nameforad)_R" "ReadAndExecute"
    Start-Sleep -Seconds 1
	add-group2fs "$path" "$($nameforad)_S" "33" "None"
    Start-Sleep -Seconds 1

	# Remove all permissions Except inherited
	#removePerm $path "1"
}


#######################################################
### Main Program

clear 

#add-adgroup $rootspecialgroup

for ($i=0; $i -le $Levels; $i++) {
	if ($i -eq 0) {
		#$FullName = get-item $WorkingShareFull | %{ $_.FullName}
	} else {
		$FullName = get-childitem ($WorkingShareFull + $LevelsChar * $i) | ?{$_.PSIsContainer} | %{ $_.FullName}
		foreach ($FullNameItem in $FullName) {
#            takeown.exe /a /f $FullNameItem
#			retrAndSetPerm $FullNameItem $WorkingShareFull
		}
	}
}

#resetperm $WorkingShareFull



<#
#add-adgroup "$(translit($WorkingShare))_S"
#add-group2fs $WorkingShareFull "$(translit($WorkingShare))_S" "33" "ContainerInherit"


translit ("eewefg�����������������42�2345234�(*)*?(-=-_=+;:[]{}\/*&7^?/.,")
add-adgroup "testttt"
add-admember "testttt" "Vasiliy"
add-group2fs "$WorkingShare" "LocalGroup" "ReadAndExecute"
inhitoff "$WorkingShare"
retrAndSetPerm $WorkingShareFull $WorkingShareFull
removePerm $path


#>