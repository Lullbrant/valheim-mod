function getSteamGameLocation {
    param(
        $gameName
    )
    $lib = Get-Content ((Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Valve\Steam\).installPath+"\steamapps\libraryfolders.vdf")
    $libraries = $lib | Where-Object { $_ -match "path"} | ForEach-Object {return (($_ -split '"')[3] -replace "\\\\","\")+"\steamapps\common"}
    return (gci $libraries -Directory -Filter $gameName).PSPath
}

function uninstallAllMods{
    param(
        $gamePath
    )
    $excludeList = "valheim.exe", "UnityPlayer.dll", "UnityCrashHandler64.exe", "steam_appid.txt", "valheim_Data", "MonoBleedingEdge"
    Get-ChildItem -Path $gamePath -Exclude $excludeList | Remove-Item -Recurse -Force
}

function installMod{
    param(
        $gamePath,
        $url,
        $installType = "dll",
        $modLoader = "BepInEx",
        $subfolder = ""
    )
    $dest = $env:HOMEPATH+"\downloads\1234"
    Invoke-WebRequest $url -OutFile "$dest.zip"
    Expand-Archive -path "$dest.zip" -DestinationPath $dest
    if ($modLoader -eq "BepInEx") {
        if ($installType -eq "dll") {
            Get-ChildItem $dest -Filter "*.dll" -Recurse | Copy-Item -Destination $gamePath"\BepInEx\plugins\$_"
        }
        elseif ($installType -eq "folder") {
            if ($subfolder -ne "") {
                Get-ChildItem $dest -Directory | Copy-Item -Destination $gamePath"\"$subfolder -Recurse -Container -Force
            }
            else {
                Get-ChildItem $dest -Directory | Get-ChildItem | Copy-Item -Destination $gamePath"\"$subfolder -Recurse
            }
        }
        else {
            Write-Host "Undefined"
        }
    }
    else {
        Write-Host "Undefined"
    }
    Remove-Item $dest -Recurse
    Remove-Item $dest".zip"
}

$aedenthornDeathTweaksConfig = @"
## Settings file was created by plugin Death Tweaks v0.8.1
## Plugin GUID: aedenthorn.DeathTweaks
[General]
Enabled = true
[Skills]
ReduceSkills = false
[Toggles]
KeepFoodLevels = true
"@

$gamePath = getSteamGameLocation -gameName "Valheim"
uninstallAllMods -gamePath $gamePath

installMod -gamePath $gamePath -url "https://valheim.thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.1900/" -installType "folder"
installMod -gamePath $gamePath -url "https://valheim.thunderstore.io/package/download/nexus2thunderstore/FogDisabler/0.1.0/"
installMod -gamePath $gamePath -url "https://github.com/mtnewton/valheim-mods/releases/download/3/mtnewton-ItemStacks-1.2.0.zip"
installMod -gamePath $gamePath -url "https://valheim.thunderstore.io/package/download/CanisDirus/DeathTweaks/0.8.1/"
installMod -gamePath $gamePath -url "https://valheim.thunderstore.io/package/download/TJzilla/BepInEx_ConfigurationManager/16.1.2/"
installMod -gamePath $gamePath -url "https://valheim.thunderstore.io/package/download/MSchmoecker/PressurePlate/0.6.2/"
installMod -gamePath $gamePath -url "https://valheim.thunderstore.io/package/download/ValheimModding/HookGenPatcher/0.0.3/" -installType "folder" -subfolder "BepInEx"
installMod -gamePath $gamePath -url "https://valheim.thunderstore.io/package/download/ValheimModding/Jotunn/2.5.1/"
#installMod -gamePath $gamePath -url "https://github.com/MofoMojo/ValheimMods/raw/master/MMWishboneTweak/bin/Release/MofoMojo.MMWishboneTweak.1.2.zip"

Set-Content -Path $gamePath"\BepInEx\config\aedenthorn.DeathTweaks.cfg" -Value $aedenthornDeathTweaksConfig
