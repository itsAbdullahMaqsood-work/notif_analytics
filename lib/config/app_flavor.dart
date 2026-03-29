enum AppFlavor { development, staging, production }

extension AppFlavorX on AppFlavor {
  String get name {
    switch (this) {
      case AppFlavor.development:
        return 'development';
      case AppFlavor.staging:
        return 'staging';
      case AppFlavor.production:
        return 'production';
    }
  }

  String get bannerLabel {
    switch (this) {
      case AppFlavor.development:
        return 'DEV';
      case AppFlavor.staging:
        return 'STAGE';
      case AppFlavor.production:
        return 'PROD';
    }
  }

  bool get showBanner => this != AppFlavor.production;
}
