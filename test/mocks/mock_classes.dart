import 'package:mocktail/mocktail.dart';

import 'package:quraaa/core/connectivity/connectivity_service.dart';
import 'package:quraaa/core/error_monitoring/user_context_provider.dart';
import 'package:quraaa/core/services/storage_service.dart';
import 'package:quraaa/core/sync/sync_manager.dart';
import 'package:quraaa/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quraaa/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:quraaa/features/auth/domain/repositories/auth_repository.dart';
import 'package:quraaa/features/auth/data/datasources/user_local_datasource.dart';
import 'package:quraaa/features/auth/domain/use_cases/login_use_case.dart';
import 'package:quraaa/features/auth/domain/use_cases/register_use_case.dart';
import 'package:quraaa/features/libraries/data/datasources/libraries_remote_data_source.dart';
import 'package:quraaa/features/libraries/domain/repositories/libraries_repository.dart';
import 'package:quraaa/features/libraries/domain/use_cases/get_libraries_use_case.dart';
import 'package:quraaa/features/libraries/data/datasources/library_details_remote_data_source.dart';
import 'package:quraaa/features/libraries/domain/repositories/library_details_repository.dart';
import 'package:quraaa/features/libraries/domain/use_cases/get_library_books_use_case.dart';
import 'package:quraaa/features/settings/domain/repositories/settings_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLibrariesRepository extends Mock implements LibrariesRepository {}

class MockLibrariesRemoteDataSource extends Mock
    implements LibrariesRemoteDataSource {}

class MockGetLibrariesUseCase extends Mock implements GetLibrariesUseCase {}

class MockLibraryDetailsRepository extends Mock
    implements LibraryDetailsRepository {}

class MockLibraryDetailsRemoteDataSource extends Mock
    implements LibraryDetailsRemoteDataSource {}

class MockGetLibraryBooksUseCase extends Mock
    implements GetLibraryBooksUseCase {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockUserLocalDataSource extends Mock implements UserLocalDataSource {}

class MockSyncManager extends Mock implements SyncManager {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockUserContextProvider extends Mock implements UserContextProvider {}
class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockStorageService extends Mock implements StorageService {}
