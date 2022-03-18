$ErrorActionPreference='Stop'

if (!(Test-Path patches)) {
    Throw "patches directory doesn't exist!"
}

$xenia_log_default='xenia.log'
if (Test-Path $xenia_log_default) {
    Write-Output "Found $xenia_log_default"
    $xenia_log="$xenia_log_default"
} else {
    Throw "Log doesn't exist!"
}

Write-Output 'Checking log...'
$xenia_log_cleaned=(Select-String ' {7}Title ID: [0-9A-F]{8}|i> [0-9A-F]{8} Title name:.+|i> [0-9A-F]{8} Module hash: [0-9A-F]{16} for.+' "$xenia_log" -AllMatches).Matches.Value | Select-Object -Unique
$new_patch_title_ids=(Select-String '(?<= {7}Title ID: )[0-9A-F]{8}' -InputObject "$xenia_log_cleaned" -AllMatches).Matches.Value
$new_patch_title_names=(Select-String '(?<=i> [0-9A-F]{8} Title name: ).+' -InputObject "$xenia_log_cleaned" -AllMatches).Matches.Value -replace '(/|\\|:|\*|\?|\"|<|>|\|)'
$new_patch_hashes=(Select-String '(?<=i> [0-9A-F]{8} Module hash: )[0-9A-F]{16}(?= for .+)' -InputObject "$xenia_log_cleaned" -AllMatches).Matches.Value

function prompt {
    param (
        [Parameter(Mandatory,Position=0)][String]$Prompt,
        [Parameter(Mandatory,Position=1)][String]$Variable_Name,
        [Parameter(ParameterSetName='InputKeys')]$Input_Keys,
        [Parameter(ParameterSetName='Length')]$Length,
        [Parameter(ParameterSetName='Pattern')]$Pattern # Regex
    )
    Read-Host "$Prompt"
}

if ($new_patch_title_id -and $new_patch_title_name -and $new_patch_hash) {
    $new_patch_filename="$new_patch_title_id - ${new_patch_title_name}.toml"
    Write-Output "Patch filename: $new_patch_filename`nPatch hash: $new_patch_hash"
} else {
    Throw "Title ID, title name, and/or hash are missing from the log.`nMake sure log_level is set to 2 in the Xenia config."
}
