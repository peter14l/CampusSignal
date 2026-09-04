class ClubModel {
  final String id;
  final String name;
  final String? description;
  final String? logoR2Key;
  final Map<String, dynamic> metadata;

  const ClubModel({
    required this.id,
    required this.name,
    this.description,
    this.logoR2Key,
    this.metadata = const {},
  });

  factory ClubModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ClubModel(id: '', name: 'Unknown Club');
    }

    Map<String, dynamic> parseMetadata(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), v));
      }
      return const {};
    }

    return ClubModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Club',
      description: json['description']?.toString(),
      logoR2Key: json['logo_r2_key']?.toString() ??
          json['logoR2Key']?.toString() ??
          json['logo_url']?.toString() ??
          json['logoUrl']?.toString(),
      metadata: parseMetadata(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_r2_key': logoR2Key,
      'metadata': metadata,
    };
  }

  ClubModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoR2Key,
    Map<String, dynamic>? metadata,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoR2Key: logoR2Key ?? this.logoR2Key,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClubModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
