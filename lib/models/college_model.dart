class CollegeModel {
  final String id;
  final String name;
  final String shortCode; // e.g. "SXUK", "JU", "IITKGP"
  final String city;
  final String state;
  final String? logoUrl;
  final List<String> domainPatterns; // e.g. ["@sxuk.edu.in", "@sxuk.in"]
  final List<String> popularBranches;

  const CollegeModel({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.city,
    required this.state,
    this.logoUrl,
    this.domainPatterns = const [],
    this.popularBranches = const [],
  });

  factory CollegeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CollegeModel(
        id: 'sxuk',
        name: "St. Xavier's University, Kolkata",
        shortCode: 'SXUK',
        city: 'Kolkata',
        state: 'West Bengal',
      );
    }

    List<String> parseStringList(dynamic value) {
      if (value == null) return const [];
      if (value is List) {
        return value
            .where((e) => e != null)
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (value is String && value.isNotEmpty) {
        return value
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return const [];
    }

    return CollegeModel(
      id: json['id']?.toString() ?? 'sxuk',
      name: json['name']?.toString() ?? "St. Xavier's University, Kolkata",
      shortCode: json['short_code']?.toString() ??
          json['shortCode']?.toString() ??
          'SXUK',
      city: json['city']?.toString() ?? 'Kolkata',
      state: json['state']?.toString() ?? 'West Bengal',
      logoUrl: json['logo_url']?.toString() ?? json['logoUrl']?.toString(),
      domainPatterns: parseStringList(json['domain_patterns'] ?? json['domainPatterns']),
      popularBranches: parseStringList(json['popular_branches'] ?? json['popularBranches']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_code': shortCode,
      'city': city,
      'state': state,
      if (logoUrl != null && logoUrl!.isNotEmpty) 'logo_url': logoUrl,
      'domain_patterns': domainPatterns,
      'popular_branches': popularBranches,
    };
  }

  CollegeModel copyWith({
    String? id,
    String? name,
    String? shortCode,
    String? city,
    String? state,
    String? logoUrl,
    List<String>? domainPatterns,
    List<String>? popularBranches,
  }) {
    return CollegeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shortCode: shortCode ?? this.shortCode,
      city: city ?? this.city,
      state: state ?? this.state,
      logoUrl: logoUrl ?? this.logoUrl,
      domainPatterns: domainPatterns ?? this.domainPatterns,
      popularBranches: popularBranches ?? this.popularBranches,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollegeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
