class AppLocaleSettings {
  final String theme;

  const AppLocaleSettings({this.theme = 'system'});

  factory AppLocaleSettings.fromJson(Map<String, dynamic> json) {
    return AppLocaleSettings(theme: json['theme'] as String? ?? 'system');
  }

  Map<String, dynamic> toJson() => {'theme': theme};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLocaleSettings &&
          runtimeType == other.runtimeType &&
          theme == other.theme;

  @override
  int get hashCode => theme.hashCode;
}
