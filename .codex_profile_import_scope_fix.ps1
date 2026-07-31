$ErrorActionPreference = 'Stop'

$repoPath = 'lib\features\account\data\repositories\account_repository_impl.dart'
$repo = Get-Content -Raw -LiteralPath $repoPath
$repo = $repo.Replace(
  "import '../../../profile/profile.dart';",
  "import '../../../profile/data/datasources/profile_local_data_source.dart';`r`nimport '../../../profile/domain/entities/profile.dart';"
)
Set-Content -LiteralPath $repoPath -Value $repo -NoNewline

$testPath = 'test\features\account\data\repositories\account_repository_impl_test.dart'
$test = Get-Content -Raw -LiteralPath $testPath
$test = $test.Replace(
  "import 'package:quraaa/features/profile/profile.dart';",
  "import 'package:quraaa/features/profile/data/datasources/profile_local_data_source.dart';`r`nimport 'package:quraaa/features/profile/data/models/profile_model.dart';"
)
Set-Content -LiteralPath $testPath -Value $test -NoNewline
