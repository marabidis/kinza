.PHONY: build-android-prod
build-android-prod: ## Build for Android with production environment
  @flutter build apk --dart-define-from-file=config/production.json && flutter install || (echo "¯\_(ツ)_/¯ ERROR BUILDING FOR ANDROID WITH PROD ENVIRONMENT "; exit 1)

.PHONY: build-android-dev
build-android-prod: ## Build for Android with development environment
  @flutter build apk --dart-define-from-file=config/development.json && flutter install || (echo "¯\_(ツ)_/¯ ERROR BUILDING FOR ANDROID WITH DEV ENVIRONMENT "; exit 1)