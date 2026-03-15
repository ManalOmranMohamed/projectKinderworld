import 'package:kinder_world/core/api/subscription_api.dart';
import 'package:kinder_world/core/cache/app_cache_store.dart';
import 'package:kinder_world/core/subscription/plan_info.dart';
import 'package:logger/logger.dart';

class SubscriptionService {
  final SubscriptionApi _subscriptionApi;
  final AppCacheStore _cacheStore;
  final Logger _logger;

  SubscriptionService({
    required SubscriptionApi subscriptionApi,
    required AppCacheStore cacheStore,
    required Logger logger,
  })  : _subscriptionApi = subscriptionApi,
        _cacheStore = cacheStore,
        _logger = logger;

  static const _scope = 'subscription';
  static const _subscriptionKey = 'current';
  static const _plansKey = 'plans';
  static const _staleAfter = Duration(minutes: 10);

  Future<bool> activateSubscription(PlanTier tier) async {
    if (tier != PlanTier.free) {
      _logger.w(
        'Blocked activation for paid tier $tier because payment is not configured.',
      );
      return false;
    }
    try {
      final response = await _subscriptionApi.selectPlan(
        planType: _planTypeForTier(tier),
      );
      return response.isNotEmpty;
    } catch (e) {
      _logger.e('Error activating subscription: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSubscription({
    bool forceRefresh = false,
  }) async {
    final snapshot = _cacheStore.snapshot(
      scope: _scope,
      key: _subscriptionKey,
      staleAfter: _staleAfter,
    );
    if (!forceRefresh && snapshot.hasData && !snapshot.isStale) {
      return _cacheStore.readMap(
        scope: _scope,
        key: _subscriptionKey,
      );
    }

    try {
      final data = await _subscriptionApi.getSubscription();
      await _cacheStore.storeMap(
        scope: _scope,
        key: _subscriptionKey,
        payload: data,
      );
      return data;
    } catch (e) {
      _logger.e('Error fetching subscription: $e');
      if (snapshot.hasData) {
        return _cacheStore.readMap(
          scope: _scope,
          key: _subscriptionKey,
        );
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> listPlans({
    bool forceRefresh = false,
  }) async {
    final snapshot = _cacheStore.snapshot(
      scope: _scope,
      key: _plansKey,
      staleAfter: _staleAfter,
    );
    if (!forceRefresh && snapshot.hasData && !snapshot.isStale) {
      return _cacheStore.readList(
        scope: _scope,
        key: _plansKey,
      );
    }

    try {
      final data = await _subscriptionApi.listPlans();
      await _cacheStore.storeList(
        scope: _scope,
        key: _plansKey,
        payload: data,
      );
      return data;
    } catch (e) {
      _logger.e('Error fetching plans: $e');
      if (snapshot.hasData) {
        return _cacheStore.readList(
          scope: _scope,
          key: _plansKey,
        );
      }
    }
    return [];
  }

  Future<bool> openBillingPortal() async {
    try {
      await _subscriptionApi.openBillingPortal();
      return true;
    } catch (e) {
      _logger.e('Error opening billing portal: $e');
      return false;
    }
  }

  String _planTypeForTier(PlanTier tier) {
    switch (tier) {
      case PlanTier.familyPlus:
        return 'family_plus';
      case PlanTier.premium:
        return 'premium';
      case PlanTier.free:
        return 'free';
    }
  }
}
