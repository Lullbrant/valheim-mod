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
    Get-ChildItem $dest -Filter "*.dll" | Copy-Item -Destination $gamePath"\BepInEx\plugins\$_"
    Remove-Item $dest -Recurse
    Remove-Item $dest".zip"
}
$configDeathPenalty = @"
[Death]
## Settings file was created by plugin Death Penalty v1.0.3.0
## Plugin GUID: dev.crystal.deathpenalty

[Death]

## The percent loss suffered to all skills when the player dies. Range 0-100. 0 disables skill loss. 50 reduces all skills by half. 100 resets all skills to 0. Resulting loss is effectively rounded by the game up to the next full level. Game default is 5.
# Setting type: Single
# Default value: 5
SkillLossPercent = 0

## The duration, in seconds, of the "No Skill Loss" status effect that is granted on death which prevents further loss of skills via subsequent deaths. Game default is 600.
# Setting type: Single
# Default value: 600
MercyEffectDuration = 600

## The duration, in seconds, of the "Corpse Run" status effect that is granted upon looting a tombstone which boosts regen and other stats. Game default is 50.
# Setting type: Single
# Default value: 50
SafetyEffectDuration = 50
"@

$gamePath = getSteamGameLocation -gameName "Valheim"
uninstallAllMods -gamePath $gamePath
installBepInExBase -gamePath $gamePath
installBepInExMod -gamePath $gamePath -url "https://valheim.thunderstore.io/package/download/nexus2thunderstore/FogDisabler/0.1.0/"
installBepInExMod -gamePath $gamePath -url "https://github.com/mtnewton/valheim-mods/releases/download/3/mtnewton-ItemStacks-1.2.0.zip"
installBepInExMod -gamePath $gamePath -url "https://valheim.thunderstore.io/package/download/Crystal/DeathPenalty/1.0.3/"
Set-Content -Path $gamePath"\BepInEx\config\dev.crystal.deathpenalty.cfg" -Value $configDeathPenalty
