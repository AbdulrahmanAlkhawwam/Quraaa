import 'package:mocktail/mocktail.dart';

import 'package:quraaa/core/connectivity/connectivity_service.dart';
import 'package:quraaa/core/error_monitoring/user_context_provider.dart';
import 'package:quraaa/core/sync/sync_manager.dart';
import 'package:quraaa/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quraaa/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:quraaa/features/auth/domain/repositories/auth_repository.dart';
import 'package:quraaa/features/auth/data/datasources/user_local_datasource.dart';
import 'package:quraaa/features/auth/domain/use_cases/login_use_case.dart';
import 'package:quraaa/features/auth/domain/use_cases/register_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockUserLocalDataSource extends Mock implements UserLocalDataSource {}

class MockSyncManager extends Mock implements SyncManager {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockUserContextProvider extends Mock implements UserContextProvider {}
