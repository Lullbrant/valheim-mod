function getSteamGameLocation {
    param(
        $gameName
    )
    $lib = Get-Content ((Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Valve\Steam\).installPath+"\steamapps\libraryfolders.vdf")
    $libraries = $lib | Where-Object { $_ -match "path"} | ForEach-Object {return (($_ -split '"')[3] -replace "\\\\","\")+"\steamapps\common"}
    return (gci $libraries -Directory -Filter $gameName).PSPath
}
function installBepInExBase {
    param(
        $gamePath
        
    )
    Invoke-WebRequest "https://valheim.thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.1900/" -OutFile $env:HOMEPATH"\downloads\BepInEx.zip"
    Expand-Archive -Path $env:HOMEPATH"\downloads\BepInEx.zip" -DestinationPath $env:HOMEPATH"\downloads\BepInEx" -Force
    Copy-Item -Path $env:HOMEPATH"\downloads\BepInEx\BepInExPack_Valheim\*" -Recurse -Destination $gamePath
    Remove-Item $env:HOMEPATH"\downloads\BepInEx" -Recurse
    Remove-Item $env:HOMEPATH"\downloads\BepInEx.zip"
}
function uninstallAllMods{
    param(
        $gamePath
    )
    $excludeList = "valheim.exe", "UnityPlayer.dll", "UnityCrashHandler64.exe", "steam_appid.txt", "valheim_Data", "MonoBleedingEdge"
    gci -Path $gamePath -Exclude $excludeList | Remove-Item -Recurse -Force
}

function installBepInExMod{
    param(
        $gamePath,
        $url
    )
    $dest = $env:HOMEPATH+"\downloads\1234"
    Invoke-WebRequest $url -OutFile "$dest.zip"
    Expand-Archive -path "$dest.zip" -DestinationPath $dest
    Get-ChildItem $dest -Filter "*.dll" -Recurse | Copy-Item -Destination $gamePath"\BepInEx\plugins\$_"
    Remove-Item $dest -Recurse
    Remove-Item $dest".zip"
}

$gamePath = getSteamGameLocation -gameName "Valheim"
uninstallAllMods -gamePath $gamePath
installBepInExBase -gamePath $gamePath
installBepInExMod -gamePath $gamePath -url "https://valheim.thunderstore.io/package/download/nexus2thunderstore/FogDisabler/0.1.0/"
installBepInExMod -gamePath $gamePath -url "https://github.com/mtnewton/valheim-mods/releases/download/3/mtnewton-ItemStacks-1.2.0.zip"
installBepInExMod -gamePath $gamePath -url "https://github.com/Lullbrant/valheim-mod/raw/main/No%20Death%20Penalty-118-1-0-0-1614205064.zip"
