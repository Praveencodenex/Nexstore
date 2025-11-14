// places_model.dart

class PredictionResponse {
  final List<Prediction> predictions;
  final String status;

  PredictionResponse({
    required this.predictions,
    required this.status,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      predictions: (json['predictions'] as List)
          .map((x) => Prediction.fromJson(x))
          .toList(),
      status: json['status'],
    );
  }
}

class PlaceResult {
  final String? formattedAddress;
  final Geometry? geometry;
  final String? placeId;
  final List<AddressComponent>? addressComponents;
  final String? name; // Add this for establishment names

  PlaceResult({
    this.formattedAddress,
    this.geometry,
    this.placeId,
    this.addressComponents,
    this.name,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    // Added null checks and safe conversions
    return PlaceResult(
      formattedAddress: json['formatted_address'],
      geometry: json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null,
      placeId: json['place_id']?.toString(), // Convert to string or null
      addressComponents: json['address_components'] != null
          ? List<AddressComponent>.from(
          json['address_components'].map((x) => AddressComponent.fromJson(x)))
          : null,
      name: json['name'], // Extract name if available
    );
  }
}

class Prediction {
  final String description;
  final String placeId;
  final StructuredFormatting? structuredFormatting;
  final List<Term>? terms;
  final List<String>? types;

  Prediction({
    required this.description,
    required this.placeId,
    this.structuredFormatting,
    this.terms,
    this.types,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'],
      placeId: json['place_id'],
      structuredFormatting: json['structured_formatting'] != null
          ? StructuredFormatting.fromJson(json['structured_formatting'])
          : null,
      terms: json['terms'] != null
          ? (json['terms'] as List).map((x) => Term.fromJson(x)).toList()
          : null,
      types: json['types'] != null
          ? List<String>.from(json['types'])
          : null,
    );
  }
}

class StructuredFormatting {
  final String mainText;
  final List<MainTextMatchedSubstring>? mainTextMatchedSubstrings;
  final String secondaryText;

  StructuredFormatting({
    required this.mainText,
    this.mainTextMatchedSubstrings,
    required this.secondaryText,
  });

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'],
      mainTextMatchedSubstrings: json['main_text_matched_substrings'] != null
          ? (json['main_text_matched_substrings'] as List)
          .map((x) => MainTextMatchedSubstring.fromJson(x))
          .toList()
          : null,
      secondaryText: json['secondary_text'],
    );
  }
}

class MainTextMatchedSubstring {
  final int length;
  final int offset;

  MainTextMatchedSubstring({
    required this.length,
    required this.offset,
  });

  factory MainTextMatchedSubstring.fromJson(Map<String, dynamic> json) {
    return MainTextMatchedSubstring(
      length: json['length'],
      offset: json['offset'],
    );
  }
}

class Term {
  final int offset;
  final String value;

  Term({
    required this.offset,
    required this.value,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      offset: json['offset'],
      value: json['value'],
    );
  }
}

// Nearby Places API response
class NearbyPlacesResponse {
  final List<Place> results;
  final String status;

  NearbyPlacesResponse({
    required this.results,
    required this.status,
  });

  factory NearbyPlacesResponse.fromJson(Map<String, dynamic> json) {
    return NearbyPlacesResponse(
      results: (json['results'] as List? ?? [])
          .map((place) => Place.fromJson(place))
          .toList(),
      status: json['status'] ?? 'UNKNOWN',
    );
  }
}

class Place {
  final String? placeId;
  final String? name;
  final String? vicinity;
  final Geometry? geometry;
  final List<String>? types;

  Place({
    this.placeId,
    this.name,
    this.vicinity,
    this.geometry,
    this.types,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['place_id'],
      name: json['name'],
      vicinity: json['vicinity'],
      geometry: json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null,
      types: json['types'] != null ? List<String>.from(json['types']) : null,
    );
  }
}

// place_detail_model.dart

class PlaceDetailResponse {
  final PlaceResult result;
  final String status;

  PlaceDetailResponse({
    required this.result,
    required this.status,
  });

  factory PlaceDetailResponse.fromJson(Map<String, dynamic> json) {
    // Handle both Place Details and Geocoding API responses
    final result = json.containsKey('result')
        ? json['result']
        : (json['results'] as List).first;

    return PlaceDetailResponse(
      result: PlaceResult.fromJson(result),
      status: json['status'],
    );
  }
}

class Geometry {
  final Location? location;
  final ViewPort? viewPort;
  final String? locationType;

  Geometry({
    this.location,
    this.viewPort,
    this.locationType,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      viewPort: json['viewport'] != null ? ViewPort.fromJson(json['viewport']) : null,
      locationType: json['location_type'],
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] is int) ? (json['lat'] as int).toDouble() : (json['lat'] as num).toDouble(),
      lng: (json['lng'] is int) ? (json['lng'] as int).toDouble() : (json['lng'] as num).toDouble(),
    );
  }
}

class ViewPort {
  final Location northeast;
  final Location southwest;

  ViewPort({
    required this.northeast,
    required this.southwest,
  });

  factory ViewPort.fromJson(Map<String, dynamic> json) {
    return ViewPort(
      northeast: Location.fromJson(json['northeast']),
      southwest: Location.fromJson(json['southwest']),
    );
  }
}

class AddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json['long_name'],
      shortName: json['short_name'],
      types: List<String>.from(json['types']),
    );
  }
}

class PlaceType {
  static const String streetAddress = 'street_address';
  static const String route = 'route';
  static const String locality = 'locality';
  static const String sublocality = 'sublocality';
  static const String administrativeAreaLevel1 = 'administrative_area_level_1';
  static const String postalCode = 'postal_code';
  static const String establishment = 'establishment';
  static const String pointOfInterest = 'point_of_interest';
  static const String premise = 'premise';
}