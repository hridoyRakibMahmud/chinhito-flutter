enum DestinationCategory {
  beach,
  hill,
  forest,
  historical,
  religious,
  waterfall,
  lake,
  island,
  archaeological,
  other;

  static DestinationCategory fromName(String value) => DestinationCategory
      .values
      .firstWhere((c) => c.name == value, orElse: () => DestinationCategory.other);
}

class Destination {
  const Destination({
    required this.id,
    required this.districtId,
    required this.districtGeojsonId,
    required this.districtName,
    required this.divisionName,
    required this.name,
    this.nameBn,
    required this.slug,
    this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.rating,
  });

  final String id;
  final String districtId;

  /// The enclosing district's `geojson_id` (e.g. `BD2022`) — matches the
  /// district polygon level's `idProperty` in geo_drilldown, so a point can
  /// be filtered into the right district when the map drills down.
  final String districtGeojsonId;
  final String districtName;
  final String divisionName;

  final String name;
  final String? nameBn;
  final String slug;
  final String? description;
  final DestinationCategory category;
  final double latitude;
  final double longitude;
  final double rating;

  factory Destination.fromMap(Map<String, dynamic> map) {
    final district = map['districts'] as Map<String, dynamic>;
    final division = district['divisions'] as Map<String, dynamic>;
    return Destination(
      id: map['id'] as String,
      districtId: map['district_id'] as String,
      districtGeojsonId: district['geojson_id'] as String,
      districtName: district['name'] as String,
      divisionName: division['name'] as String,
      name: map['name'] as String,
      nameBn: map['name_bn'] as String?,
      slug: map['slug'] as String,
      description: map['description'] as String?,
      category: DestinationCategory.fromName(map['category'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Shape expected by `MapPointsConfig(format: PointsFormat.plainList)`.
  Map<String, dynamic> toMapPoint() => {
        'id': id,
        'name': name,
        'lat': latitude,
        'lng': longitude,
        'parentId': districtGeojsonId,
        'slug': slug,
        'category': category.name,
        'rating': rating,
      };
}
