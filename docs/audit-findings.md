> Full scanner output for the architecture audit, 2026-09-22, master @ 8f07c34. The summary and plan are in [AUDIT.md](AUDIT.md).
> The scanner is a Dart port of the skill's audit_flutter_arch.py, because Python isn't installed on this machine. Known false positives are listed in AUDIT.md.

# Architecture audit — Quraaa

**Score: 0/100** · errors 136 · warnings 131 · info 223

Features found: account, auth, book_assistant, book_engagement, books, cart, favorites, home, libraries, local_explorer, onboarding, orders, pdf_reader, profile, purchases, search, sell_book, settings, splash, subscription

## ERROR (136)

| Rule | File | Line | Message |
|---|---|---|---|
| C01 | `lib/config/env/env.dart` | 70 | hardcoded URL — move to ApiEndpoints / AppConfig |
| C01 | `lib/core/error_monitoring/telegram_notification_service.dart` | 100 | hardcoded URL — move to ApiEndpoints / AppConfig |
| C01 | `lib/features/book_assistant/data/repositories/book_assistant_repository_impl.dart` | 50 | hardcoded URL — move to ApiEndpoints / AppConfig |
| C01 | `lib/features/book_assistant/data/repositories/book_assistant_repository_impl.dart` | 43 | hardcoded URL — move to ApiEndpoints / AppConfig |
| C01 | `lib/features/book_assistant/data/repositories/book_assistant_repository_impl.dart` | 36 | hardcoded URL — move to ApiEndpoints / AppConfig |
| C01 | `lib/features/profile/presentation/pages/profile_locations_screen.dart` | 659 | hardcoded URL — move to ApiEndpoints / AppConfig |
| C06 | `lib/features/auth/data/datasources/auth_local_datasource.dart` | 316 | token/secret written to plain storage — must go through secure storage |
| C06 | `lib/features/auth/data/datasources/auth_local_datasource.dart` | 313 | token/secret written to plain storage — must go through secure storage |
| C06 | `lib/features/auth/data/datasources/auth_local_datasource.dart` | 310 | token/secret written to plain storage — must go through secure storage |
| C06 | `lib/features/auth/data/datasources/user_local_datasource.dart` | 118 | token/secret written to plain storage — must go through secure storage |
| C06 | `lib/features/auth/data/datasources/user_local_datasource.dart` | 115 | token/secret written to plain storage — must go through secure storage |
| C06 | `lib/features/auth/data/datasources/user_local_datasource.dart` | 114 | token/secret written to plain storage — must go through secure storage |
| C06 | `lib/features/auth/data/datasources/user_local_datasource.dart` | 76 | token/secret written to plain storage — must go through secure storage |
| C06 | `lib/features/auth/data/datasources/user_local_datasource.dart` | 70 | token/secret written to plain storage — must go through secure storage |
| C06 | `lib/features/auth/data/datasources/user_local_datasource.dart` | 73 | token/secret written to plain storage — must go through secure storage |
| C09 | `.env` |  | .env is tracked by git — remove from history |
| C09 | `.gitignore` |  | 'GoogleService-Info.plist' is not ignored |
| C09 | `.gitignore` |  | 'google-services.json' is not ignored |
| C09 | `google-services.json` |  | google-services.json is tracked by git — remove from history |
| C10 | `lib/config/routes/route_names.dart` | 52 | possible inline credential in source |
| C10 | `lib/config/routes/route_names.dart` | 51 | possible inline credential in source |
| C10 | `lib/config/routes/route_names.dart` | 46 | possible inline credential in source |
| C10 | `lib/core/constants/api_endpoints.dart` | 15 | possible inline credential in source |
| C10 | `lib/core/constants/api_endpoints.dart` | 13 | possible inline credential in source |
| C10 | `lib/firebase_options.dart` | 71 | possible inline credential in source |
| C10 | `lib/firebase_options.dart` | 54 | possible Google API key in source |
| C10 | `lib/firebase_options.dart` | 44 | possible Google API key in source |
| C10 | `lib/firebase_options.dart` | 80 | possible inline credential in source |
| C10 | `lib/firebase_options.dart` | 62 | possible inline credential in source |
| C10 | `lib/firebase_options.dart` | 54 | possible inline credential in source |
| C10 | `lib/firebase_options.dart` | 44 | possible inline credential in source |
| C10 | `lib/firebase_options.dart` | 80 | possible Google API key in source |
| C10 | `lib/firebase_options.dart` | 71 | possible Google API key in source |
| C10 | `lib/firebase_options.dart` | 62 | possible Google API key in source |
| D03 | `lib/features/auth/presentation/bloc/auth_bloc.dart` | 9 | presentation imports data layer: ../../data/datasources/auth_local_datasource.dart — use the entity and the use case |
| D03 | `lib/features/auth/presentation/bloc/auth_bloc.dart` | 10 | presentation imports data layer: ../../data/services/auth_session_service.dart — use the entity and the use case |
| D03 | `lib/features/auth/presentation/bloc/auth_journey_cubit.dart` | 2 | presentation imports data layer: ../../data/datasources/auth_local_datasource.dart — use the entity and the use case |
| D03 | `lib/features/auth/presentation/bloc/auth_permission_cubit.dart` | 6 | presentation imports data layer: ../../data/datasources/auth_local_datasource.dart — use the entity and the use case |
| D03 | `lib/features/auth/presentation/bloc/auth_recovery_cubit.dart` | 8 | presentation imports data layer: ../../data/services/auth_session_service.dart — use the entity and the use case |
| D03 | `lib/features/auth/presentation/bloc/auth_recovery_cubit.dart` | 7 | presentation imports data layer: ../../data/datasources/auth_local_datasource.dart — use the entity and the use case |
| D03 | `lib/features/pdf_reader/presentation/pages/pdf_reader_page.dart` | 16 | presentation imports data layer: ../../data/datasources/local/pdf_reader_local_state_datasource.dart — use the entity and the use case |
| D03 | `lib/features/profile/presentation/bloc/profile_bloc.dart` | 11 | presentation imports data layer: ../../data/datasources/profile_local_data_source.dart — use the entity and the use case |
| D03 | `lib/features/profile/presentation/bloc/profile_bloc.dart` | 8 | presentation imports data layer: ../../../auth/data/datasources/user_local_datasource.dart — use the entity and the use case |
| D03 | `lib/features/profile/presentation/bloc/profile_bloc.dart` | 7 | presentation imports data layer: ../../../auth/data/datasources/auth_local_datasource.dart — use the entity and the use case |
| S03 | `lib/features/account` |  | feature 'account' has no presentation/ layer |
| S03 | `lib/features/account/data` |  | data/ is missing models/ |
| S03 | `lib/features/account/data` |  | data/ is missing data_sources/ |
| S03 | `lib/features/book_engagement/data` |  | data/ is missing data_sources/ |
| S03 | `lib/features/book_engagement/data` |  | data/ is missing models/ |
| S03 | `lib/features/book_engagement/data` |  | data/ is missing repositories/ |
| S03 | `lib/features/book_engagement/domain` |  | domain/ is missing use_cases/ |
| S03 | `lib/features/book_engagement/domain` |  | domain/ is missing repositories/ |
| S03 | `lib/features/book_engagement/domain` |  | domain/ is missing entities/ |
| S03 | `lib/features/book_engagement/presentation` |  | presentation/ is missing screen/ |
| S03 | `lib/features/book_engagement/presentation` |  | presentation/ is missing logic/ |
| S03 | `lib/features/pdf_reader/data` |  | data/ is missing models/ |
| S03 | `lib/features/profile/domain` |  | domain/ is missing use_cases/ |
| S03 | `lib/features/purchases/data` |  | data/ is missing models/ |
| S03 | `lib/features/purchases/data` |  | data/ is missing data_sources/ |
| S03 | `lib/features/purchases/data` |  | data/ is missing repositories/ |
| S03 | `lib/features/purchases/domain` |  | domain/ is missing use_cases/ |
| S03 | `lib/features/purchases/domain` |  | domain/ is missing repositories/ |
| S03 | `lib/features/purchases/domain` |  | domain/ is missing entities/ |
| S03 | `lib/features/purchases/presentation` |  | presentation/ is missing logic/ |
| S03 | `lib/features/search` |  | feature 'search' has no domain/ layer |
| S03 | `lib/features/search` |  | feature 'search' has no data/ layer |
| S03 | `lib/features/search/presentation` |  | presentation/ is missing logic/ |
| S03 | `lib/features/sell_book/data` |  | data/ is missing models/ |
| S03 | `lib/features/sell_book/presentation` |  | presentation/ is missing logic/ |
| S03 | `lib/features/splash` |  | feature 'splash' has no domain/ layer |
| S03 | `lib/features/splash` |  | feature 'splash' has no data/ layer |
| S03 | `lib/features/splash/presentation` |  | presentation/ is missing logic/ |
| S03 | `lib/features/subscription` |  | feature 'subscription' has no data/ layer |
| S03 | `lib/features/subscription` |  | feature 'subscription' has no domain/ layer |
| S03 | `lib/features/subscription/presentation` |  | presentation/ is missing logic/ |
| S04 | `lib/features/auth/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/auth/presentation/bloc` |  | folder 'bloc' should be 'logic' |
| S04 | `lib/features/auth/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/auth/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/book_assistant/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/book_assistant/presentation/bloc` |  | folder 'bloc' should be 'logic' |
| S04 | `lib/features/book_assistant/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/book_assistant/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/books/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/books/presentation/bloc` |  | folder 'bloc' should be 'logic' |
| S04 | `lib/features/books/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/books/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/cart/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/cart/presentation/bloc` |  | folder 'bloc' should be 'logic' |
| S04 | `lib/features/cart/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/cart/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/favorites/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/favorites/presentation/cubit` |  | folder 'cubit' should be 'logic' |
| S04 | `lib/features/favorites/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/home/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/home/presentation/bloc` |  | folder 'bloc' should be 'logic' |
| S04 | `lib/features/home/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/home/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/libraries/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/libraries/presentation/cubit` |  | folder 'cubit' should be 'logic' |
| S04 | `lib/features/libraries/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/libraries/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/local_explorer/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/local_explorer/presentation/bloc` |  | folder 'bloc' should be 'logic' |
| S04 | `lib/features/local_explorer/presentation/cubit` |  | folder 'cubit' should be 'logic' |
| S04 | `lib/features/local_explorer/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/local_explorer/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/onboarding/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/onboarding/presentation/bloc` |  | folder 'bloc' should be 'logic' |
| S04 | `lib/features/onboarding/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/onboarding/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/orders/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/orders/presentation/cubit` |  | folder 'cubit' should be 'logic' |
| S04 | `lib/features/orders/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/pdf_reader/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/pdf_reader/presentation/bloc` |  | folder 'bloc' should be 'logic' |
| S04 | `lib/features/pdf_reader/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/pdf_reader/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/profile/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/profile/presentation/bloc` |  | folder 'bloc' should be 'logic' |
| S04 | `lib/features/profile/presentation/cubit` |  | folder 'cubit' should be 'logic' |
| S04 | `lib/features/profile/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/profile/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/purchases/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/search/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/search/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/sell_book/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/sell_book/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/settings/data/datasources` |  | folder 'datasources' should be 'data_sources' |
| S04 | `lib/features/settings/presentation/bloc` |  | folder 'bloc' should be 'logic' |
| S04 | `lib/features/settings/presentation/cubit` |  | folder 'cubit' should be 'logic' |
| S04 | `lib/features/settings/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/settings/presentation/widgets` |  | folder 'widgets' should be 'widget' |
| S04 | `lib/features/splash/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/subscription/presentation/pages` |  | folder 'pages' should be 'screen' |
| S04 | `lib/features/subscription/presentation/widgets` |  | folder 'widgets' should be 'widget' |

## WARNING (131)

| Rule | File | Line | Message |
|---|---|---|---|
| C02 | `lib/core/core.dart` | 21 | hardcoded asset path — move to AppAssets |
| C02 | `lib/core/core.dart` | 22 | hardcoded asset path — move to AppAssets |
| C02 | `lib/core/localization/localization_constants.dart` | 4 | hardcoded asset path — move to AppAssets |
| C02 | `lib/features/books/data/datasources/books_mock_remote_data_source.dart` | 42 | hardcoded asset path — move to AppAssets |
| C02 | `lib/features/books/data/datasources/books_mock_remote_data_source.dart` | 56 | hardcoded asset path — move to AppAssets |
| C02 | `lib/features/books/data/datasources/books_mock_remote_data_source.dart` | 49 | hardcoded asset path — move to AppAssets |
| C02 | `lib/features/books/data/datasources/books_mock_remote_data_source.dart` | 35 | hardcoded asset path — move to AppAssets |
| C02 | `lib/features/books/data/datasources/books_mock_remote_data_source.dart` | 28 | hardcoded asset path — move to AppAssets |
| C02 | `lib/features/books/data/datasources/books_mock_remote_data_source.dart` | 21 | hardcoded asset path — move to AppAssets |
| C02 | `lib/features/sell_book/data/datasources/sell_book_mock_remote_data_source.dart` | 23 | hardcoded asset path — move to AppAssets |
| C03 | `lib/features/orders/presentation/pages/account_orders_screen.dart` | 522 | Image.network — use the core image helper (caching + error state) |
| C03 | `lib/features/purchases/presentation/pages/purchased_books_screen.dart` | 178 | Image.network — use the core image helper (caching + error state) |
| C03 | `lib/features/sell_book/presentation/pages/my_listings_screen.dart` | 145 | Image.network — use the core image helper (caching + error state) |
| C03 | `lib/features/sell_book/presentation/pages/sell_book_screen.dart` | 420 | Image.network — use the core image helper (caching + error state) |
| C03 | `lib/shared/widgets/app_image.dart` | 143 | Image.network — use the core image helper (caching + error state) |
| C05 | `lib/core/di/injection_container.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/core/error_monitoring/dio_logging_interceptor.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/core/error_monitoring/telegram_notification_service.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/core/errors/error_mapper.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/core/network/auth_interceptor.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/core/network/connectivity_interceptor.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/core/network/http_helper.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/core/network/language_interceptor.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/auth/data/datasources/auth_remote_datasource.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/book_assistant/data/datasources/book_assistant_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/book_engagement/data/book_engagement_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/books/data/datasources/books_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/cart/data/datasources/cart_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/favorites/data/datasources/favorite_books_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/home/data/datasources/home_books_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/libraries/data/datasources/authors_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/libraries/data/datasources/libraries_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/libraries/data/datasources/library_details_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/onboarding/data/datasources/onboarding_remote_datasource.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/orders/data/datasources/orders_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/profile/data/datasources/profile_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/purchases/data/purchases_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/purchases/data/secure_purchase_book_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/sell_book/data/datasources/sell_book_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C05 | `lib/features/settings/data/datasources/library_registration_remote_data_source.dart` |  | Dio import — house rule is package:http behind HttpHelper |
| C13 | `lib/core/constants/app_routes.dart` |  | expected core module missing: constants/app_routes.dart |
| C13 | `lib/core/di/service_locator.dart` |  | expected core module missing: di/service_locator.dart |
| C13 | `lib/core/routing/app_router.dart` |  | expected core module missing: routing/app_router.dart |
| C14 | `pubspec.yaml` |  | no Either package (fpdart) — how are failures returned? |
| C17 | `lib/features/book_assistant/data/models/book_summary_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/books/data/models/home_catalog_book_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/cart/data/models/cart_response_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/favorites/data/models/favorite_book_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/home/data/models/home_book_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/home/data/models/paginated_home_books_response_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/libraries/data/models/library_book_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/libraries/data/models/library_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/libraries/data/models/paginated_libraries_response_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/libraries/data/models/paginated_library_books_response_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/libraries/data/models/paginated_library_search_response_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/local_explorer/data/models/local_directory_snapshot_model.dart` | 2 | model does not extend/implement its entity |
| C17 | `lib/features/local_explorer/data/models/local_file_entry_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/local_explorer/data/models/local_path_segment_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/orders/data/models/checkout_confirmation_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/orders/data/models/order_checkout_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/profile/data/models/update_profile_request_model.dart` | 1 | model does not extend/implement its entity |
| C17 | `lib/features/settings/data/models/library_registration_model.dart` | 1 | model does not extend/implement its entity |
| D05 | `lib/features/account/data/repositories/account_repository_impl.dart` |  | repository impl has no try/catch — exceptions will leak past the domain boundary |
| D05 | `lib/features/books/data/repositories/books_repository_impl.dart` |  | repository impl has no try/catch — exceptions will leak past the domain boundary |
| D05 | `lib/features/onboarding/data/repositories/onboarding_repository_impl.dart` |  | repository impl has no try/catch — exceptions will leak past the domain boundary |
| D05 | `lib/features/profile/data/repositories/profile_repository_impl.dart` |  | repository impl has no try/catch — exceptions will leak past the domain boundary |
| D05 | `lib/features/settings/data/repositories/settings_repository_impl.dart` |  | repository impl has no try/catch — exceptions will leak past the domain boundary |
| D06 | `lib/features/account/domain/repositories/account_repository.dart` | 1 | domain repository is not abstract |
| D06 | `lib/features/auth/domain/repositories/auth_repository.dart` | 2 | domain repository is not abstract |
| D06 | `lib/features/book_assistant/domain/repositories/book_assistant_repository.dart` | 3 | domain repository is not abstract |
| D06 | `lib/features/cart/domain/repositories/cart_repository.dart` | 3 | domain repository is not abstract |
| D06 | `lib/features/favorites/domain/repositories/favorite_books_repository.dart` | 2 | domain repository is not abstract |
| D06 | `lib/features/home/domain/repositories/home_books_repository.dart` | 4 | domain repository is not abstract |
| D06 | `lib/features/libraries/domain/repositories/authors_repository.dart` | 4 | domain repository is not abstract |
| D06 | `lib/features/local_explorer/domain/repositories/explorer_history_repository.dart` | 2 | domain repository is not abstract |
| D06 | `lib/features/local_explorer/domain/repositories/local_file_repository.dart` | 2 | domain repository is not abstract |
| D06 | `lib/features/onboarding/domain/repositories/onboarding_repository.dart` | 3 | domain repository is not abstract |
| D06 | `lib/features/orders/domain/repositories/orders_repository.dart` | 5 | domain repository is not abstract |
| D06 | `lib/features/pdf_reader/domain/repositories/pdf_reader_repository.dart` | 5 | domain repository is not abstract |
| D06 | `lib/features/profile/domain/repositories/profile_repository.dart` | 2 | domain repository is not abstract |
| D06 | `lib/features/settings/domain/repositories/library_registration_repository.dart` | 3 | domain repository is not abstract |
| D07 | `lib/features/libraries/presentation/pages/libraries_screen.dart` | 8 | reaches into feature 'home' presentation/ — shared UI belongs in core/widgets, shared domain in a parent feature |
| S03 | `lib/features/book_engagement/presentation` |  | presentation/ is missing widget/ |
| S03 | `lib/features/favorites/presentation` |  | presentation/ is missing widget/ |
| S03 | `lib/features/orders/presentation` |  | presentation/ is missing widget/ |
| S03 | `lib/features/purchases/presentation` |  | presentation/ is missing widget/ |
| S03 | `lib/features/sell_book/presentation` |  | presentation/ is missing widget/ |
| S03 | `lib/features/splash/presentation` |  | presentation/ is missing widget/ |
| S05 | `lib/features/account/account_injection.dart` |  | missing account_injection.dart — DI/routes for 'account' are probably inlined in core |
| S05 | `lib/features/account/account_routes.dart` |  | missing account_routes.dart — DI/routes for 'account' are probably inlined in core |
| S05 | `lib/features/auth/auth_injection.dart` |  | missing auth_injection.dart — DI/routes for 'auth' are probably inlined in core |
| S05 | `lib/features/auth/auth_routes.dart` |  | missing auth_routes.dart — DI/routes for 'auth' are probably inlined in core |
| S05 | `lib/features/book_assistant/book_assistant_injection.dart` |  | missing book_assistant_injection.dart — DI/routes for 'book_assistant' are probably inlined in core |
| S05 | `lib/features/book_assistant/book_assistant_routes.dart` |  | missing book_assistant_routes.dart — DI/routes for 'book_assistant' are probably inlined in core |
| S05 | `lib/features/book_engagement/book_engagement_injection.dart` |  | missing book_engagement_injection.dart — DI/routes for 'book_engagement' are probably inlined in core |
| S05 | `lib/features/book_engagement/book_engagement_routes.dart` |  | missing book_engagement_routes.dart — DI/routes for 'book_engagement' are probably inlined in core |
| S05 | `lib/features/books/books_injection.dart` |  | missing books_injection.dart — DI/routes for 'books' are probably inlined in core |
| S05 | `lib/features/books/books_routes.dart` |  | missing books_routes.dart — DI/routes for 'books' are probably inlined in core |
| S05 | `lib/features/cart/cart_injection.dart` |  | missing cart_injection.dart — DI/routes for 'cart' are probably inlined in core |
| S05 | `lib/features/cart/cart_routes.dart` |  | missing cart_routes.dart — DI/routes for 'cart' are probably inlined in core |
| S05 | `lib/features/favorites/favorites_injection.dart` |  | missing favorites_injection.dart — DI/routes for 'favorites' are probably inlined in core |
| S05 | `lib/features/favorites/favorites_routes.dart` |  | missing favorites_routes.dart — DI/routes for 'favorites' are probably inlined in core |
| S05 | `lib/features/home/home_injection.dart` |  | missing home_injection.dart — DI/routes for 'home' are probably inlined in core |
| S05 | `lib/features/home/home_routes.dart` |  | missing home_routes.dart — DI/routes for 'home' are probably inlined in core |
| S05 | `lib/features/libraries/libraries_injection.dart` |  | missing libraries_injection.dart — DI/routes for 'libraries' are probably inlined in core |
| S05 | `lib/features/libraries/libraries_routes.dart` |  | missing libraries_routes.dart — DI/routes for 'libraries' are probably inlined in core |
| S05 | `lib/features/local_explorer/local_explorer_injection.dart` |  | missing local_explorer_injection.dart — DI/routes for 'local_explorer' are probably inlined in core |
| S05 | `lib/features/local_explorer/local_explorer_routes.dart` |  | missing local_explorer_routes.dart — DI/routes for 'local_explorer' are probably inlined in core |
| S05 | `lib/features/onboarding/onboarding_injection.dart` |  | missing onboarding_injection.dart — DI/routes for 'onboarding' are probably inlined in core |
| S05 | `lib/features/onboarding/onboarding_routes.dart` |  | missing onboarding_routes.dart — DI/routes for 'onboarding' are probably inlined in core |
| S05 | `lib/features/orders/orders_injection.dart` |  | missing orders_injection.dart — DI/routes for 'orders' are probably inlined in core |
| S05 | `lib/features/orders/orders_routes.dart` |  | missing orders_routes.dart — DI/routes for 'orders' are probably inlined in core |
| S05 | `lib/features/pdf_reader/pdf_reader_injection.dart` |  | missing pdf_reader_injection.dart — DI/routes for 'pdf_reader' are probably inlined in core |
| S05 | `lib/features/pdf_reader/pdf_reader_routes.dart` |  | missing pdf_reader_routes.dart — DI/routes for 'pdf_reader' are probably inlined in core |
| S05 | `lib/features/profile/profile_injection.dart` |  | missing profile_injection.dart — DI/routes for 'profile' are probably inlined in core |
| S05 | `lib/features/profile/profile_routes.dart` |  | missing profile_routes.dart — DI/routes for 'profile' are probably inlined in core |
| S05 | `lib/features/purchases/purchases_injection.dart` |  | missing purchases_injection.dart — DI/routes for 'purchases' are probably inlined in core |
| S05 | `lib/features/purchases/purchases_routes.dart` |  | missing purchases_routes.dart — DI/routes for 'purchases' are probably inlined in core |
| S05 | `lib/features/search/search_injection.dart` |  | missing search_injection.dart — DI/routes for 'search' are probably inlined in core |
| S05 | `lib/features/search/search_routes.dart` |  | missing search_routes.dart — DI/routes for 'search' are probably inlined in core |
| S05 | `lib/features/sell_book/sell_book_injection.dart` |  | missing sell_book_injection.dart — DI/routes for 'sell_book' are probably inlined in core |
| S05 | `lib/features/sell_book/sell_book_routes.dart` |  | missing sell_book_routes.dart — DI/routes for 'sell_book' are probably inlined in core |
| S05 | `lib/features/settings/settings_injection.dart` |  | missing settings_injection.dart — DI/routes for 'settings' are probably inlined in core |
| S05 | `lib/features/settings/settings_routes.dart` |  | missing settings_routes.dart — DI/routes for 'settings' are probably inlined in core |
| S05 | `lib/features/splash/splash_injection.dart` |  | missing splash_injection.dart — DI/routes for 'splash' are probably inlined in core |
| S05 | `lib/features/splash/splash_routes.dart` |  | missing splash_routes.dart — DI/routes for 'splash' are probably inlined in core |
| S05 | `lib/features/subscription/subscription_injection.dart` |  | missing subscription_injection.dart — DI/routes for 'subscription' are probably inlined in core |
| S05 | `lib/features/subscription/subscription_routes.dart` |  | missing subscription_routes.dart — DI/routes for 'subscription' are probably inlined in core |
| S07 | `lib/app` |  | lib/app/ is outside core/ and features/ — decide where its contents belong |
| S07 | `lib/config` |  | lib/config/ is outside core/ and features/ — decide where its contents belong |
| S07 | `lib/shared` |  | lib/shared/ is outside core/ and features/ — decide where its contents belong |

## INFO (223)

| Rule | File | Line | Message |
|---|---|---|---|
| C11 | `lib/app/app.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/core/errors/error_message_resolver.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/core/localization/localization_service.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/auth/presentation/pages/change_password_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/auth/presentation/pages/forgot_password_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/auth/presentation/pages/landing_page.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/auth/presentation/pages/location_permission_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/auth/presentation/pages/login_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/auth/presentation/pages/notification_permission_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/auth/presentation/pages/otp_verification_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/auth/presentation/pages/register_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/auth/presentation/pages/reset_password_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/book_assistant/presentation/pages/ai_text_tools_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/book_assistant/presentation/widgets/assistant_book_picker_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/book_assistant/presentation/widgets/assistant_composer.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/book_assistant/presentation/widgets/assistant_header.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/book_assistant/presentation/widgets/assistant_prompt_chips.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/book_engagement/presentation/book_engagement_panel.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/books/presentation/pages/books_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/books/presentation/widgets/book_card.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/books/presentation/widgets/books_filter_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/books/presentation/widgets/books_search_bar.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/cart/presentation/widgets/add_payment_card_bottom_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/cart/presentation/widgets/cart_bottom_nav.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/cart/presentation/widgets/cart_coupon_card.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/cart/presentation/widgets/cart_item_tile.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/cart/presentation/widgets/cart_totals_card.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/cart/presentation/widgets/cart_view.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/cart/presentation/widgets/payment_info_bottom_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/favorites/presentation/pages/favorite_books_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/home/presentation/pages/audio_books_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/home/presentation/pages/home_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/home/presentation/pages/stores_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/home/presentation/widgets/home_app_bar.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/home/presentation/widgets/home_banner.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/home/presentation/widgets/home_drawer.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/home/presentation/widgets/home_feature_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/home/presentation/widgets/home_order_status_card.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/home/presentation/widgets/home_quick_actions.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/home/presentation/widgets/home_section.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/libraries/presentation/pages/author_details_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/libraries/presentation/pages/book_details_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/libraries/presentation/pages/libraries_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/libraries/presentation/pages/library_details_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/libraries/presentation/widgets/book_purchase_bottom_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/libraries/presentation/widgets/library_info_header.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/local_explorer/presentation/pages/explorer_history_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/local_explorer/presentation/widgets/explorer_access_view.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/local_explorer/presentation/widgets/explorer_empty_view.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/local_explorer/presentation/widgets/explorer_failure_view.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/local_explorer/presentation/widgets/explorer_header.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/local_explorer/presentation/widgets/explorer_list.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/onboarding/presentation/pages/age_onboarding_page.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/onboarding/presentation/pages/gender_onboarding_page.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/onboarding/presentation/pages/interests_onboarding_page.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/orders/presentation/pages/account_orders_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/pages/pdf_reader_page.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/pdf_note_dialog.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/pdf_page_image.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/pdf_reader_continuous_view.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/pdf_reader_controls.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/pdf_reader_header.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/pdf_reader_layout_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/pdf_reader_progress_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/pdf_reader_title_block.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/pdf_saved_note_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/pdf_selection_toolbar.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/pdf_reader/presentation/widgets/purchased_pdf_reader_loader.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/profile/presentation/extensions/profile_model_ui_extensions.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/profile/presentation/pages/edit_profile_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/profile/presentation/pages/profile_locations_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/profile/presentation/widgets/avatar_customization_tabs.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/profile/presentation/widgets/gender_dropdown.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/profile/presentation/widgets/phone_number_field.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/purchases/presentation/pages/purchased_books_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/search/presentation/pages/search_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/sell_book/presentation/pages/my_listings_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/pages/account_type_page.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/pages/personal_information_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/appearance_bottom_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/language_bottom_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/library_registration_listener.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/notification_bottom_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/personal_data_section.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/personal_information_header.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/settings_header.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/settings_list_tile.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/settings_logout_button.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/settings_search_bar.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/settings_tab_bar.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/settings/presentation/widgets/settings_view.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/splash/presentation/pages/splash_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/features/subscription/presentation/pages/account_type_screen.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/shared/widgets/app_shell.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/shared/widgets/language_bottom_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/shared/widgets/notification_bottom_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/shared/widgets/onboarding_scaffold.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/shared/widgets/primary_bottom_nav.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/shared/widgets/terms_privacy_bottom_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C11 | `lib/shared/widgets/theme_bottom_sheet.dart` |  | easy_localization — house rule is gen-l10n (compile-time checked) |
| C15 | `lib/features/auth/presentation/pages/change_password_screen.dart` |  | 3 setState calls in a screen — state probably belongs in a cubit |
| C15 | `lib/features/auth/presentation/pages/login_screen.dart` |  | 3 setState calls in a screen — state probably belongs in a cubit |
| C15 | `lib/features/auth/presentation/pages/register_screen.dart` |  | 5 setState calls in a screen — state probably belongs in a cubit |
| C15 | `lib/features/auth/presentation/pages/reset_password_screen.dart` |  | 3 setState calls in a screen — state probably belongs in a cubit |
| C15 | `lib/features/book_assistant/presentation/pages/ai_text_tools_screen.dart` |  | 4 setState calls in a screen — state probably belongs in a cubit |
| C15 | `lib/features/pdf_reader/presentation/pages/pdf_reader_page.dart` |  | 14 setState calls in a screen — state probably belongs in a cubit |
| C15 | `lib/features/profile/presentation/pages/profile_locations_screen.dart` |  | 7 setState calls in a screen — state probably belongs in a cubit |
| C15 | `lib/features/search/presentation/pages/search_screen.dart` |  | 5 setState calls in a screen — state probably belongs in a cubit |
| C15 | `lib/features/sell_book/presentation/pages/my_listings_screen.dart` |  | 3 setState calls in a screen — state probably belongs in a cubit |
| C15 | `lib/features/sell_book/presentation/pages/sell_book_screen.dart` |  | 19 setState calls in a screen — state probably belongs in a cubit |
| C17 | `lib/features/local_explorer/data/models/local_directory_snapshot_model.dart` |  | model has no fromJson |
| C17 | `lib/features/local_explorer/data/models/local_file_entry_model.dart` |  | model has no fromJson |
| C17 | `lib/features/local_explorer/data/models/local_path_segment_model.dart` |  | model has no fromJson |
| C17 | `lib/features/profile/data/models/update_profile_request_model.dart` |  | model has no fromJson |
| C18 | `lib/features/account/domain/entities/account_user_snapshot.dart` |  | entity has no copyWith |
| C18 | `lib/features/book_assistant/domain/entities/assistant_book.dart` |  | entity has no copyWith |
| C18 | `lib/features/book_assistant/domain/entities/assistant_response.dart` |  | entity has no copyWith |
| C18 | `lib/features/favorites/domain/entities/favorite_book.dart` |  | entity has no copyWith |
| C18 | `lib/features/home/domain/entities/home_book_entity.dart` |  | entity has no copyWith |
| C18 | `lib/features/libraries/domain/entities/author_entity.dart` |  | entity has no copyWith |
| C18 | `lib/features/libraries/domain/entities/library_book_entity.dart` |  | entity has no copyWith |
| C18 | `lib/features/libraries/domain/entities/library_entity.dart` |  | entity has no copyWith |
| C18 | `lib/features/libraries/domain/entities/library_search_entity.dart` |  | entity has no copyWith |
| C18 | `lib/features/local_explorer/domain/entities/explorer_history_entry.dart` |  | entity has no copyWith |
| C18 | `lib/features/local_explorer/domain/entities/local_directory_snapshot.dart` |  | entity has no copyWith |
| C18 | `lib/features/onboarding/domain/entities/category.dart` |  | entity has no copyWith |
| C18 | `lib/features/onboarding/domain/entities/onboarding_draft.dart` |  | entity has no copyWith |
| C18 | `lib/features/orders/domain/entities/checkout_confirmation.dart` |  | entity has no copyWith |
| C18 | `lib/features/orders/domain/entities/order_checkout.dart` |  | entity has no copyWith |
| C18 | `lib/features/orders/domain/entities/order_checkout_context.dart` |  | entity has no copyWith |
| C18 | `lib/features/pdf_reader/domain/entities/pdf_text_layer.dart` |  | entity has no copyWith |
| C18 | `lib/features/pdf_reader/domain/entities/pdf_text_note.dart` |  | entity has no copyWith |
| C18 | `lib/features/profile/domain/entities/update_profile_input.dart` |  | entity has no copyWith |
| C18 | `lib/features/sell_book/domain/entities/my_listing.dart` |  | entity has no copyWith |
| C18 | `lib/features/settings/domain/entities/library_profile.dart` |  | entity has no copyWith |
| C18 | `lib/features/settings/domain/entities/library_registration.dart` |  | entity has no copyWith |
| C18 | `lib/features/settings/domain/entities/personal_information.dart` |  | entity has no copyWith |
| C18 | `lib/features/settings/domain/entities/settings_tab.dart` |  | entity has no copyWith |
| C19 | `test/features/favorites` |  | no tests for feature 'favorites' |
| C19 | `test/features/local_explorer` |  | no tests for feature 'local_explorer' |
| C19 | `test/features/search` |  | no tests for feature 'search' |
| C19 | `test/features/splash` |  | no tests for feature 'splash' |
| C19 | `test/features/subscription` |  | no tests for feature 'subscription' |
| N03 | `lib/app/app.dart` | 16 | first class is 'QuraaaApp', file name suggests 'App' |
| N03 | `lib/core/errors/exceptions.dart` | 1 | first class is 'AppException', file name suggests 'Exceptions' |
| N03 | `lib/core/errors/failures.dart` | 3 | first class is 'Failure', file name suggests 'Failures' |
| N03 | `lib/features/auth/data/datasources/auth_local_datasource.dart` | 72 | first class is 'AuthLocalDataSource', file name suggests 'AuthLocalDatasource' |
| N03 | `lib/features/auth/data/datasources/auth_remote_datasource.dart` | 9 | first class is 'AuthRemoteDataSource', file name suggests 'AuthRemoteDatasource' |
| N03 | `lib/features/auth/data/datasources/user_local_datasource.dart` | 13 | first class is 'UserLocalDataSource', file name suggests 'UserLocalDatasource' |
| N03 | `lib/features/auth/domain/use_cases/change_password_use_case.dart` | 3 | first class is 'ChangePasswordParams', file name suggests 'ChangePasswordUseCase' |
| N03 | `lib/features/auth/domain/use_cases/forgot_password_use_case.dart` | 3 | first class is 'ForgotPasswordParams', file name suggests 'ForgotPasswordUseCase' |
| N03 | `lib/features/auth/domain/use_cases/login_use_case.dart` | 4 | first class is 'LoginParams', file name suggests 'LoginUseCase' |
| N03 | `lib/features/auth/domain/use_cases/register_use_case.dart` | 4 | first class is 'RegisterParams', file name suggests 'RegisterUseCase' |
| N03 | `lib/features/auth/domain/use_cases/reset_password_use_case.dart` | 3 | first class is 'ResetPasswordParams', file name suggests 'ResetPasswordUseCase' |
| N03 | `lib/features/auth/domain/use_cases/verify_otp_use_case.dart` | 4 | first class is 'VerifyOtpParams', file name suggests 'VerifyOtpUseCase' |
| N03 | `lib/features/auth/presentation/bloc/auth_journey_cubit.dart` | 6 | first class is 'AuthJourneyState', file name suggests 'AuthJourneyCubit' |
| N03 | `lib/features/auth/presentation/bloc/auth_recovery_cubit.dart` | 25 | first class is 'AuthRecoveryState', file name suggests 'AuthRecoveryCubit' |
| N03 | `lib/features/auth/presentation/bloc/auth_registration_cubit.dart` | 8 | first class is 'AuthRegistrationState', file name suggests 'AuthRegistrationCubit' |
| N03 | `lib/features/auth/presentation/bloc/change_password_cubit.dart` | 6 | first class is 'ChangePasswordState', file name suggests 'ChangePasswordCubit' |
| N03 | `lib/features/auth/presentation/widgets/auth_form_fields.dart` | 5 | first class is 'AuthLabeledField', file name suggests 'AuthFormFields' |
| N03 | `lib/features/book_assistant/presentation/bloc/book_assistant_bloc.dart` | 10 | first class is 'BookAssistantEvent', file name suggests 'BookAssistantBloc' |
| N03 | `lib/features/book_engagement/domain/book_engagement.dart` | 3 | first class is 'BookComment', file name suggests 'BookEngagement' |
| N03 | `lib/features/book_engagement/presentation/book_engagement_cubit.dart` | 5 | first class is 'BookEngagementState', file name suggests 'BookEngagementCubit' |
| N03 | `lib/features/books/presentation/bloc/books_bloc.dart` | 5 | first class is 'BooksEvent', file name suggests 'BooksBloc' |
| N03 | `lib/features/cart/presentation/bloc/cart_bloc.dart` | 10 | first class is 'CartEvent', file name suggests 'CartBloc' |
| N03 | `lib/features/cart/presentation/widgets/payment_card_mark.dart` | 1 | first class is 'MastercardMark', file name suggests 'PaymentCardMark' |
| N03 | `lib/features/cart/presentation/widgets/payment_info_bottom_sheet.dart` | 13 | first class is 'CheckoutSelection', file name suggests 'PaymentInfoBottomSheet' |
| N03 | `lib/features/favorites/presentation/cubit/favorite_books_cubit.dart` | 6 | first class is 'FavoriteBooksState', file name suggests 'FavoriteBooksCubit' |
| N03 | `lib/features/favorites/presentation/cubit/favorite_status_cubit.dart` | 7 | first class is 'FavoriteStatusState', file name suggests 'FavoriteStatusCubit' |
| N03 | `lib/features/libraries/domain/use_cases/get_libraries_use_case.dart` | 3 | first class is 'GetLibrariesParams', file name suggests 'GetLibrariesUseCase' |
| N03 | `lib/features/libraries/domain/use_cases/get_library_books_use_case.dart` | 3 | first class is 'GetLibraryBooksParams', file name suggests 'GetLibraryBooksUseCase' |
| N03 | `lib/features/libraries/domain/use_cases/get_listing_details_use_case.dart` | 4 | first class is 'GetListingDetailsParams', file name suggests 'GetListingDetailsUseCase' |
| N03 | `lib/features/libraries/presentation/cubit/author_details_cubit.dart` | 6 | first class is 'AuthorDetailsState', file name suggests 'AuthorDetailsCubit' |
| N03 | `lib/features/libraries/presentation/models/library_details_navigation_data.dart` | 4 | first class is 'AuthorDetailsNavigationData', file name suggests 'LibraryDetailsNavigationData' |
| N03 | `lib/features/libraries/presentation/widgets/library_book_card.dart` | 6 | first class is 'LibraryDetailsBookCard', file name suggests 'LibraryBookCard' |
| N03 | `lib/features/local_explorer/data/datasources/local/local_explorer_platform_datasource.dart` | 5 | first class is 'LocalExplorerPlatformDataSource', file name suggests 'LocalExplorerPlatformDatasource' |
| N03 | `lib/features/local_explorer/data/datasources/local/local_file_system_datasource.dart` | 2 | first class is 'LocalFileSystemDataSource', file name suggests 'LocalFileSystemDatasource' |
| N03 | `lib/features/local_explorer/data/datasources/local/local_file_system_datasource_io.dart` | 13 | first class is 'IoLocalFileSystemDataSource', file name suggests 'LocalFileSystemDatasourceIo' |
| N03 | `lib/features/local_explorer/data/datasources/local/local_file_system_datasource_stub.dart` | 10 | first class is 'UnsupportedLocalFileSystemDataSource', file name suggests 'LocalFileSystemDatasourceStub' |
| N03 | `lib/features/local_explorer/domain/use_cases/get_local_directory_parent_use_case.dart` | 3 | first class is 'GetLocalDirectoryParentParams', file name suggests 'GetLocalDirectoryParentUseCase' |
| N03 | `lib/features/local_explorer/domain/use_cases/load_local_directory_use_case.dart` | 4 | first class is 'LoadLocalDirectoryParams', file name suggests 'LoadLocalDirectoryUseCase' |
| N03 | `lib/features/local_explorer/presentation/bloc/local_explorer_bloc.dart` | 10 | first class is 'LocalExplorerEvent', file name suggests 'LocalExplorerBloc' |
| N03 | `lib/features/local_explorer/presentation/cubit/explorer_history_cubit.dart` | 5 | first class is 'ExplorerHistoryState', file name suggests 'ExplorerHistoryCubit' |
| N03 | `lib/features/onboarding/data/datasources/onboarding_local_datasource.dart` | 6 | first class is 'OnboardingLocalDataSource', file name suggests 'OnboardingLocalDatasource' |
| N03 | `lib/features/onboarding/data/datasources/onboarding_remote_datasource.dart` | 8 | first class is 'OnboardingRemoteDataSource', file name suggests 'OnboardingRemoteDatasource' |
| N03 | `lib/features/onboarding/domain/use_cases/save_birth_date_use_case.dart` | 2 | first class is 'SaveBirthDateParams', file name suggests 'SaveBirthDateUseCase' |
| N03 | `lib/features/onboarding/domain/use_cases/save_category_id_use_case.dart` | 2 | first class is 'SaveCategoryIdParams', file name suggests 'SaveCategoryIdUseCase' |
| N03 | `lib/features/onboarding/presentation/bloc/onboarding_bloc.dart` | 16 | first class is 'OnboardingEvent', file name suggests 'OnboardingBloc' |
| N03 | `lib/features/orders/data/models/account_order_model.dart` | 1 | first class is 'AccountOrderItemModel', file name suggests 'AccountOrderModel' |
| N03 | `lib/features/orders/domain/entities/order_checkout_context.dart` | 1 | first class is 'OrderCheckoutLocation', file name suggests 'OrderCheckoutContext' |
| N03 | `lib/features/orders/presentation/cubit/account_orders_cubit.dart` | 9 | first class is 'AccountOrdersState', file name suggests 'AccountOrdersCubit' |
| N03 | `lib/features/orders/presentation/cubit/checkout_cubit.dart` | 18 | first class is 'CheckoutState', file name suggests 'CheckoutCubit' |
| N03 | `lib/features/orders/presentation/pages/account_orders_screen.dart` | 11 | first class is 'MyOrdersScreen', file name suggests 'AccountOrdersScreen' |
| N03 | `lib/features/pdf_reader/data/datasources/local/pdf_note_datasource.dart` | 1 | first class is 'PdfNoteDataSource', file name suggests 'PdfNoteDatasource' |
| N03 | `lib/features/pdf_reader/data/datasources/local/pdf_reader_local_state_datasource.dart` | 4 | first class is 'PdfReaderLocalStateDataSource', file name suggests 'PdfReaderLocalStateDatasource' |
| N03 | `lib/features/pdf_reader/data/datasources/local/pdf_render_datasource.dart` | 5 | first class is 'PdfRenderDataSource', file name suggests 'PdfRenderDatasource' |
| N03 | `lib/features/pdf_reader/domain/entities/pdf_reader_local_state.dart` | 5 | first class is 'PdfInkPoint', file name suggests 'PdfReaderLocalState' |
| N03 | `lib/features/pdf_reader/domain/entities/pdf_text_layer.dart` | 1 | first class is 'PdfTextBounds', file name suggests 'PdfTextLayer' |
| N03 | `lib/features/pdf_reader/domain/entities/pdf_text_note.dart` | 3 | first class is 'PdfPageAnchor', file name suggests 'PdfTextNote' |
| N03 | `lib/features/pdf_reader/domain/use_cases/delete_pdf_text_note_use_case.dart` | 4 | first class is 'DeletePdfTextNoteParams', file name suggests 'DeletePdfTextNoteUseCase' |
| N03 | `lib/features/pdf_reader/domain/use_cases/get_pdf_page_count_use_case.dart` | 3 | first class is 'GetPdfPageCountParams', file name suggests 'GetPdfPageCountUseCase' |
| N03 | `lib/features/pdf_reader/domain/use_cases/get_pdf_text_layer_use_case.dart` | 4 | first class is 'GetPdfTextLayerParams', file name suggests 'GetPdfTextLayerUseCase' |
| N03 | `lib/features/pdf_reader/domain/use_cases/load_pdf_text_notes_use_case.dart` | 4 | first class is 'LoadPdfTextNotesParams', file name suggests 'LoadPdfTextNotesUseCase' |
| N03 | `lib/features/pdf_reader/domain/use_cases/render_pdf_page_use_case.dart` | 5 | first class is 'RenderPdfPageParams', file name suggests 'RenderPdfPageUseCase' |
| N03 | `lib/features/pdf_reader/domain/use_cases/save_pdf_text_note_use_case.dart` | 4 | first class is 'SavePdfTextNoteParams', file name suggests 'SavePdfTextNoteUseCase' |
| N03 | `lib/features/pdf_reader/domain/use_cases/share_pdf_text_use_case.dart` | 3 | first class is 'SharePdfTextParams', file name suggests 'SharePdfTextUseCase' |
| N03 | `lib/features/pdf_reader/presentation/bloc/pdf_reader_bloc.dart` | 13 | first class is 'PdfReaderEvent', file name suggests 'PdfReaderBloc' |
| N03 | `lib/features/pdf_reader/presentation/services/pdf_reader_screen_security.dart` | 5 | first class is 'PlatformPdfReaderScreenSecurity', file name suggests 'PdfReaderScreenSecurity' |
| N03 | `lib/features/profile/presentation/cubit/profile_edit_cubit.dart` | 7 | first class is 'ProfileEditState', file name suggests 'ProfileEditCubit' |
| N03 | `lib/features/profile/presentation/cubit/profile_location_cubit.dart` | 5 | first class is 'ProfileLocationState', file name suggests 'ProfileLocationCubit' |
| N03 | `lib/features/purchases/data/secure_purchase_book_data_source.dart` | 19 | first class is 'PurchaseCacheKeyStore', file name suggests 'SecurePurchaseBookDataSource' |
| N03 | `lib/features/purchases/domain/purchases.dart` | 5 | first class is 'PurchasedBook', file name suggests 'Purchases' |
| N03 | `lib/features/purchases/presentation/purchases_cubit.dart` | 5 | first class is 'PurchasesState', file name suggests 'PurchasesCubit' |
| N03 | `lib/features/settings/domain/use_cases/update_appearance_option_use_case.dart` | 4 | first class is 'UpdateAppearanceOptionParams', file name suggests 'UpdateAppearanceOptionUseCase' |
| N03 | `lib/features/settings/domain/use_cases/update_language_option_use_case.dart` | 4 | first class is 'UpdateLanguageOptionParams', file name suggests 'UpdateLanguageOptionUseCase' |
| N03 | `lib/features/settings/domain/use_cases/update_notification_setting_use_case.dart` | 4 | first class is 'UpdateNotificationSettingParams', file name suggests 'UpdateNotificationSettingUseCase' |
| N03 | `lib/features/settings/presentation/bloc/settings_bloc.dart` | 25 | first class is 'SettingsEvent', file name suggests 'SettingsBloc' |
| N03 | `lib/features/settings/presentation/cubit/library_registration_cubit.dart` | 8 | first class is 'LibraryRegistrationState', file name suggests 'LibraryRegistrationCubit' |
| N03 | `lib/firebase_options.dart` | 16 | first class is 'DefaultFirebaseOptions', file name suggests 'FirebaseOptions' |
| N03 | `lib/main.dart` | 143 | first class is '_StartupFailureApp', file name suggests 'Main' |
| N03 | `lib/shared/theme/styles/text_styles.dart` | 1 | first class is 'AppTextStyles', file name suggests 'TextStyles' |
| N03 | `lib/shared/widgets/preference_selection_bottom_sheet.dart` | 6 | first class is 'PreferenceSelectionOption', file name suggests 'PreferenceSelectionBottomSheet' |
| N03 | `lib/shared/widgets/primary_bottom_nav.dart` | 15 | first class is 'HomeBottomNav', file name suggests 'PrimaryBottomNav' |

## By rule

- C11: 100
- N03: 80
- S04: 61
- S05: 40
- S03: 37
- C05: 25
- C18: 24
- C17: 22
- C10: 15
- D06: 14
- D03: 10
- C15: 10
- C02: 10
- C06: 9
- C01: 6
- D05: 5
- C03: 5
- C19: 5
- C09: 4
- S07: 3
- C13: 3
- D07: 1
- C14: 1
