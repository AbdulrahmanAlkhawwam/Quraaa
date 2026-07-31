$ErrorActionPreference = 'Stop'

$path = 'test\features\profile\data\models\profile_model_test.dart'
$content = Get-Content -Raw -LiteralPath $path
$content = $content.Replace(
  "import 'package:quraaa/features/profile/profile.dart';",
  "import 'package:quraaa/features/profile/data/models/profile_model.dart';"
)
Set-Content -LiteralPath $path -Value $content -NoNewline
