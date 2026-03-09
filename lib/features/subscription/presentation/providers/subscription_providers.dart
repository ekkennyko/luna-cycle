import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> initRevenueCat() async {
  await Purchases.setLogLevel(LogLevel.debug);

  final config = PurchasesConfiguration(
    Platform.isAndroid
        ? AppConstants.revenueCatApiKeyAndroid
        : AppConstants.revenueCatApiKeyIos,
  );
  await Purchases.configure(config);
}

final customerInfoProvider = FutureProvider<CustomerInfo>((ref) async {
  return Purchases.getCustomerInfo();
});

final isPremiumProvider = FutureProvider<bool>((ref) async {
  final info = await ref.watch(customerInfoProvider.future);
  return info.entitlements.active.containsKey(AppConstants.premiumEntitlement);
});

final offeringsProvider = FutureProvider<Offerings>((ref) async {
  return Purchases.getOfferings();
});

class SubscriptionNotifier extends AsyncNotifier<CustomerInfo?> {
  @override
  Future<CustomerInfo?> build() async => null;

  Future<void> purchase(Package package) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // ignore: deprecated_member_use
      final result = await Purchases.purchasePackage(package);
      ref.invalidate(customerInfoProvider);
      return result.customerInfo;
    });
  }

  Future<void> restorePurchases() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final info = await Purchases.restorePurchases();
      ref.invalidate(customerInfoProvider);
      return info;
    });
  }
}

final subscriptionNotifierProvider =
    AsyncNotifierProvider<SubscriptionNotifier, CustomerInfo?>(
  SubscriptionNotifier.new,
);
