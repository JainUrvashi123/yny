import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class InventorySyncService {
  static final InventorySyncService _instance = InventorySyncService._internal();
  factory InventorySyncService() => _instance;
  InventorySyncService._internal();

  static const String _keyLastRefresh = 'last_diamond_inventory_refresh';
  static const Duration refreshInterval = Duration(hours: 1);

  final _syncEventController = StreamController<DateTime>.broadcast();
  Stream<DateTime> get onHourlySyncTriggered => _syncEventController.stream;

  DateTime? _cachedLastRefreshTime;

  /// Records that an inventory refresh has occurred right now
  Future<void> recordRefresh([DateTime? time]) async {
    final now = time ?? DateTime.now();
    _cachedLastRefreshTime = now;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastRefresh, now.toIso8601String());
    } catch (_) {
      // Ignored if prefs unavailable
    }
  }

  /// Retrieves the last recorded refresh time
  Future<DateTime?> getLastRefreshTime() async {
    if (_cachedLastRefreshTime != null) {
      return _cachedLastRefreshTime;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyLastRefresh);
      if (str != null && str.isNotEmpty) {
        _cachedLastRefreshTime = DateTime.tryParse(str);
        return _cachedLastRefreshTime;
      }
    } catch (_) {}
    return null;
  }

  /// Checks if an hourly refresh is needed (>= 1 hour since last refresh)
  Future<bool> isHourlyRefreshNeeded() async {
    final lastRefresh = await getLastRefreshTime();
    if (lastRefresh == null) return true;
    final diff = DateTime.now().difference(lastRefresh);
    return diff >= refreshInterval;
  }

  /// Returns human-readable relative/formatted refresh time
  Future<String> getLastRefreshFormatted() async {
    final lastRefresh = await getLastRefreshTime();
    if (lastRefresh == null) return 'Not yet synced';
    final diff = DateTime.now().difference(lastRefresh);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      final h = lastRefresh.hour > 12 ? lastRefresh.hour - 12 : (lastRefresh.hour == 0 ? 12 : lastRefresh.hour);
      final m = lastRefresh.minute.toString().padLeft(2, '0');
      final period = lastRefresh.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $period';
    } else {
      return '${lastRefresh.day}/${lastRefresh.month}';
    }
  }

  /// Triggers a broadcast event to notify listeners that an hourly refresh should execute
  void triggerHourlyRefresh() {
    _syncEventController.add(DateTime.now());
  }

  void dispose() {
    _syncEventController.close();
  }
}
