import 'package:mocktail/mocktail.dart';

import 'package:quraaa/core/connectivity/connectivity_service.dart';
import 'package:quraaa/core/sync/sync_manager.dart';
import 'package:quraaa/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:quraaa/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:quraaa/features/auth/domain/repositories/auth_repository.dart';
import 'package:quraaa/features/auth/domain/use_cases/login_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSyncManager extends Mock implements SyncManager {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockLoginUseCase extends Mock implements LoginUseCase {}
