import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yny/core/services/inventory_sync_service.dart';
import 'package:yny/features/diamond/data/datasources/diamond_remote_datasource.dart';
import 'package:yny/features/diamond/data/models/diamond_model.dart';
import 'package:yny/features/diamond/data/repositories/diamond_repository.dart';

class FakeDiamondRemoteDataSource implements DiamondRemoteDataSource {
  final List<DiamondModel> stubbedDiamonds;

  FakeDiamondRemoteDataSource(this.stubbedDiamonds);

  @override
  Future<DiamondResponseModel> getDiamondList({
    int page = 0,
    int perPage = 50,
    String stock = '',
    List<String>? shapes,
    List<String>? colors,
    List<String>? fancyColors,
    List<String>? clarities,
    List<String>? cuts,
    List<String>? polishes,
    List<String>? symmetries,
    List<String>? labs,
    List<String>? fluorescences,
    List<String>? makes,
    List<String>? culets,
    List<String>? available,
    String? caratFrom,
    String? caratTo,
    String? priceFrom,
    String? priceTo,
    String? ratioFrom,
    String? ratioTo,
    String? depthFrom,
    String? depthTo,
    String? tableFrom,
    String? tableTo,
    String? crAngleFrom,
    String? crAngleTo,
    String? crHeightFrom,
    String? crHeightTo,
    String? pavAngleFrom,
    String? pavAngleTo,
    String? pavHeightFrom,
    String? pavHeightTo,
    String? girdleFrom,
    String? girdleTo,
    String? starLengthFrom,
    String? starLengthTo,
    String? lengthFrom,
    String? lengthTo,
    String? widthFrom,
    String? widthTo,
  }) async {
    return DiamondResponseModel(
      status: 1,
      message: 'OK',
      totalRecords: stubbedDiamonds.length.toString(),
      perPage: perPage,
      page: page,
      data: stubbedDiamonds,
    );
  }

  @override
  Future<bool> addToCart({required String stock, int qty = 1}) async {
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DiamondModel - Dimensions and Availability parsing', () {
    test('parses mLength, mWidth, mDepth when present', () {
      final model = DiamondModel(
        mLength: '6.50',
        mWidth: '6.45',
        mDepth: '4.00',
      );

      expect(model.parsedLength, 6.50);
      expect(model.parsedWidth, 6.45);
      expect(model.parsedDepth, 4.00);
    });

    test('parses dimensions from measurements string (e.g. 5.95 X 5.98 X 3.74)', () {
      final model = DiamondModel(
        measurements: '5.95 X 5.98 X 3.74',
      );

      expect(model.parsedLength, 5.95);
      expect(model.parsedWidth, 5.98);
      expect(model.parsedDepth, 3.74);
    });

    test('parses dimensions with alternative delimiters (asterisk, hyphen)', () {
      final model = DiamondModel(
        measurements: '6.10*4.20*2.80',
      );

      expect(model.parsedLength, 6.10);
      expect(model.parsedWidth, 4.20);
      expect(model.parsedDepth, 2.80);
    });

    test('returns null when dimensions cannot be parsed', () {
      final model = DiamondModel(
        measurements: 'invalid-measurements',
      );

      expect(model.parsedLength, isNull);
      expect(model.parsedWidth, isNull);
      expect(model.parsedDepth, isNull);
    });

    test('availabilityDisplay maps code correctly', () {
      expect(DiamondModel(availability: 'G').availabilityDisplay, 'Guaranteed');
      expect(DiamondModel(availability: 'M').availabilityDisplay, 'On Memo');
      expect(DiamondModel(availability: 'ON MEMO').availabilityDisplay, 'On Memo');
      expect(DiamondModel(availability: 'MEMO').availabilityDisplay, 'On Memo');
      expect(DiamondModel(availability: 'A').availabilityDisplay, 'Available');
      expect(DiamondModel(availability: 'AVAILABLE').availabilityDisplay, 'Available');
      expect(DiamondModel(availability: '').availabilityDisplay, 'Available');
      expect(DiamondModel(availability: null).availabilityDisplay, 'Available');
      expect(DiamondModel(availability: 'SOLD').availabilityDisplay, 'Sold');
      expect(DiamondModel(availability: 'HOLD').availabilityDisplay, 'On Hold');
    });

    test('isAvailable indicates availability for purchasing', () {
      expect(DiamondModel(availability: 'G').isAvailable, isTrue);
      expect(DiamondModel(availability: 'A').isAvailable, isTrue);
      expect(DiamondModel(availability: '').isAvailable, isTrue);
      expect(DiamondModel(availability: null).isAvailable, isTrue);

      expect(DiamondModel(availability: 'M').isAvailable, isFalse);
      expect(DiamondModel(availability: 'ON MEMO').isAvailable, isFalse);
      expect(DiamondModel(availability: 'SOLD').isAvailable, isFalse);
      expect(DiamondModel(availability: 'HOLD').isAvailable, isFalse);
    });
  });

  group('InventorySyncService - Hourly sync tracking', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('isHourlyRefreshNeeded returns true initially when never refreshed', () async {
      final service = InventorySyncService();
      // Reset any in-memory cache by recording null if needed or with empty prefs
      // Since it's a singleton, let's test relative to current state
      final isNeeded = await service.isHourlyRefreshNeeded();
      expect(isNeeded, isTrue);
    });

    test('recordRefresh stores timestamp and isHourlyRefreshNeeded returns false immediately', () async {
      final service = InventorySyncService();
      final now = DateTime.now();

      await service.recordRefresh(now);

      final lastTime = await service.getLastRefreshTime();
      expect(lastTime, isNotNull);
      expect(lastTime!.difference(now).inSeconds.abs(), lessThanOrEqualTo(1));

      final isNeeded = await service.isHourlyRefreshNeeded();
      expect(isNeeded, isFalse);

      final formatted = await service.getLastRefreshFormatted();
      expect(formatted, 'Just now');
    });

    test('isHourlyRefreshNeeded returns true when last refresh was > 1 hour ago', () async {
      final service = InventorySyncService();
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));

      await service.recordRefresh(twoHoursAgo);

      final isNeeded = await service.isHourlyRefreshNeeded();
      expect(isNeeded, isTrue);
    });

    test('triggerHourlyRefresh emits timestamp on onHourlySyncTriggered stream', () async {
      final service = InventorySyncService();

      expectLater(service.onHourlySyncTriggered, emits(isA<DateTime>()));

      service.triggerHourlyRefresh();
    });
  });

  group('DiamondRepositoryImpl - Length and Width filtering', () {
    final d1 = DiamondModel(stockId: 'D1', mLength: '4.50', mWidth: '3.00');
    final d2 = DiamondModel(stockId: 'D2', mLength: '5.50', mWidth: '4.00');
    final d3 = DiamondModel(stockId: 'D3', mLength: '6.50', mWidth: '5.00');
    final d4 = DiamondModel(stockId: 'D4', mLength: '7.50', mWidth: '6.00');

    late DiamondRepositoryImpl repository;

    setUp(() {
      repository = DiamondRepositoryImpl(
        remoteDataSource: FakeDiamondRemoteDataSource([d1, d2, d3, d4]),
      );
    });

    test('returns all diamonds if no length or width filters specified', () async {
      final result = await repository.getDiamondList();
      expect(result.data.length, 4);
    });

    test('filters diamonds by length bounds', () async {
      final result = await repository.getDiamondList(
        lengthFrom: '5.00',
        lengthTo: '6.50',
      );

      expect(result.data.map((d) => d.stockId).toList(), ['D2', 'D3']);
    });

    test('filters diamonds by width bounds', () async {
      final result = await repository.getDiamondList(
        widthFrom: '3.50',
        widthTo: '5.50',
      );

      expect(result.data.map((d) => d.stockId).toList(), ['D2', 'D3']);
    });

    test('filters diamonds by combined length and width bounds', () async {
      final result = await repository.getDiamondList(
        lengthFrom: '5.00',
        lengthTo: '8.00',
        widthFrom: '5.50',
        widthTo: '6.50',
      );

      expect(result.data.map((d) => d.stockId).toList(), ['D4']);
    });
  });
}
