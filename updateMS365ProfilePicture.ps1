function updateAvatar() {

Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"

$data = getImagesFromUser
if ($null -eq $data) {
    return
}
$imageLocation = $data.Location
$images = $data.Images
$allUsers = Get-MgUser -All

foreach ($image in $images){


$userCheck = $allUsers | Where-Object { $_.Mail -like "$userNameFromImage" }
$fullPath = Join-Path $imageLocation $image.Name

if ($userCheck)
{
Write-Host "$($userCheck.Mail) Funnet. Oppdaterer bilde" -ForegroundColor Green
$userId = $userCheck.Id

if (Test-Path $fullPath) {
    try {
        Set-MgUserPhotoContent -UserId $userId -InFile $fullPath
        Write-Host "User with $userId is updated"
    }
    catch {}
} else {
    Write-Host "Bildet for brukeren $userNameFromImage ble ikke funnet på filbanen" -ForegroundColor Red
}
}
else
{
 Write-Host "Bruker" $userNameFromImage "Ble ikke funnet" -ForegroundColor Red
}
}
Disconnect-MgGraph

}



function getImagesFromUser() {
    $imageLocation = Read-Host "Skriv inn filbane der bildene ligger"
    if ([string]::IsNullOrWhiteSpace($imageLocation)){
        Write-Host "Filbanen kan ikke være tom" -ForegroundColor Red
        return
    }
    $images = Get-ChildItem -Path $imageLocation
    if ($images.Length -eq 0){
        Write-Host "Mappen inneholder ingen bildefiler" -ForegroundColor Yellow
        return $null
    }

    Write-Host "Bilder ble funnet:"
    foreach ($image in $images){
    Write-Host $image -ForegroundColor Green
    }
    Read-Host -Prompt "Hvis alt ser riktig ut, trykker du på Enter for å fortsette"
    return @{ Location = $imageLocation; Images = $images }
    }


function checkModuleInstalled {
 $installedModules = Get-InstalledModule
 foreach ($installedModule in $installedModules)
 {
    if ($installedModule.Name -eq "Microsoft.Graph"){
        return $true
    }
 }
 Write-Host "For installasjon, kjør denne: Install-Module Microsoft.Graph - deretter kan scriptet kjøres på nytt." -ForegroundColor Red
 return $false
}

if (checkModuleInstalled) {
updateAvatar
Read-Host -Prompt "Trykk Enter for å avslutte"
} 
else 
{
Write-Host "Microsoft Graph er ikke installert. For installasjon, kjør denne: Install-Module Microsoft.Graph - deretter kan scriptet kjøres på nytt." -ForegroundColor Red
Read-Host -Prompt "Trykk Enter for å avslutte"
}