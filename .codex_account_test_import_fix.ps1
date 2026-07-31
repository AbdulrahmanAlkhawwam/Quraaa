$ErrorActionPreference = 'Stop'

$path = 'test\features\account\data\repositories\account_repository_impl_test.dart'
$content = Get-Content -Raw -LiteralPath $path
$content = $content.Replace(
  "import 'package:quraaa/features/account/account.dart';`nimport 'package:quraaa/features/auth/auth.dart';",
  "import 'package:quraaa/features/account/data/repositories/account_repository_impl.dart';`nimport 'package:quraaa/features/account/data/user_data_local_data_source.dart';`nimport 'package:quraaa/features/account/domain/entities/account_user_snapshot.dart';`nimport 'package:quraaa/features/auth/data/datasources/auth_local_datasource.dart';"
)
Set-Content -LiteralPath $path -Value $content -NoNewline
