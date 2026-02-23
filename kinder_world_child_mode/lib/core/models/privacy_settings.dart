class PrivacySettings {
  final bool analyticsEnabled;
  final bool personalizedRecommendations;
  final bool dataCollectionOptOut;

  const PrivacySettings({
    required this.analyticsEnabled,
    required this.personalizedRecommendations,
    required this.dataCollectionOptOut,
  });

  factory PrivacySettings.defaults() => const PrivacySettings(
        analyticsEnabled: true,
        personalizedRecommendations: true,
        dataCollectionOptOut: false,
      );

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      analyticsEnabled: json['analytics_enabled'] as bool? ?? true,
      personalizedRecommendations:
          json['personalized_recommendations'] as bool? ?? true,
      dataCollectionOptOut: json['data_collection_opt_out'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'analytics_enabled': analyticsEnabled,
        'personalized_recommendations': personalizedRecommendations,
        'data_collection_opt_out': dataCollectionOptOut,
      };

  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? personalizedRecommendations,
    bool? dataCollectionOptOut,
  }) {
    return PrivacySettings(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      personalizedRecommendations:
          personalizedRecommendations ?? this.personalizedRecommendations,
      dataCollectionOptOut: dataCollectionOptOut ?? this.dataCollectionOptOut,
    );
  }
}
