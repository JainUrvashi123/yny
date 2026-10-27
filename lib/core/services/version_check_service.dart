import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class AppVersionInfo {
  final bool status;
  final bool updateRequired;
  final String currentVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String? playstoreUrl;
  final String? appstoreUrl;

  AppVersionInfo({
    required this.status,
    required this.updateRequired,
    required this.currentVersion,
    required this.latestVersion,
    required this.forceUpdate,
    this.playstoreUrl,
    this.appstoreUrl,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      status: json['status'] ?? false,
      updateRequired: json['update_required'] ?? false,
      currentVersion: json['current_version'] ?? '',
      latestVersion: json['latest_version'] ?? '',
      forceUpdate: json['force_update'] ?? false,
      playstoreUrl: json['playstore_url'],
      appstoreUrl: json['appstore_url'],
    );
  }
}

class VersionCheckService {
  static final VersionCheckService _instance = VersionCheckService._internal();
  factory VersionCheckService() => _instance;
  VersionCheckService._internal();

  final Dio _dio = Dio();
  AppVersionInfo? _cachedVersionInfo;
  bool _dialogShownThisSession = false;

  AppVersionInfo? get cachedVersionInfo => _cachedVersionInfo;

  /// Performs the remote version check against the API.
  Future<AppVersionInfo?> checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentAppVersion = packageInfo.version;
      final platform = Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'android';

      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/check-app-version',
        data: {
          'version': currentAppVersion,
          'platform': platform,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is String 
            ? Map<String, dynamic>.from(response.data as Map) 
            : response.data as Map<String, dynamic>;
        _cachedVersionInfo = AppVersionInfo.fromJson(data);
        return _cachedVersionInfo;
      }
    } catch (e) {
      debugPrint('Error performing version check: $e');
    }
    return null;
  }

  /// Launch play store / app store URL
  Future<void> _launchStoreUrl(AppVersionInfo info) async {
    final urlString = Platform.isIOS ? info.appstoreUrl : info.playstoreUrl;
    if (urlString != null && urlString.isNotEmpty) {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      // Fallback if URL is null
      final fallbackUrl = Platform.isIOS
          ? AppConstants.appStoreUrl
          : AppConstants.playStoreUrl;
      final uri = Uri.parse(fallbackUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  /// Shows the Update Dialog styled to match the design.
  void showUpdateDialog(BuildContext context, {bool forceShow = false}) {
    final info = _cachedVersionInfo;
    if (info == null || !info.updateRequired) return;

    // Avoid showing the dialog multiple times automatically in a single session
    if (_dialogShownThisSession && !forceShow) return;
    _dialogShownThisSession = true;

    showDialog(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

        return PopScope(
          canPop: !info.forceUpdate,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: isDark ? AppConstants.surfaceColor : Colors.white,
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(
                  color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                ),
                boxShadow: isDark
                    ? AppConstants.glassShadow
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Download/Update Icon
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.08),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.file_download_outlined,
                        color: accentColor,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'Update Available!',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    'A new version of ${AppConstants.appName} is available! Please update to get the latest features and improvements.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      height: 1.4,
                      color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // "Update Now" Action Button
                  ElevatedButton(
                    onPressed: () {
                      _launchStoreUrl(info);
                      if (!info.forceUpdate) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Update Now',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  
                  // "Later" Action Button (only if not a force update)
                  if (!info.forceUpdate) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Later',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
