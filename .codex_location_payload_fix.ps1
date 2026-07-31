$ErrorActionPreference = 'Stop'

$path = 'lib\features\profile\data\datasources\profile_remote_data_source.dart'
$content = Get-Content -Raw -LiteralPath $path
$content = $content.Replace("'latitude': location.latitude,", "'latitude': location.latitude.toString(),")
$content = $content.Replace("'longitude': location.longitude,", "'longitude': location.longitude.toString(),")
Set-Content -LiteralPath $path -Value $content -NoNewline
