class DistanceMatrix {
  List<String> destinationAddresses;
  List<String> originAddresses;
  List<Row> rows;
  String status;

  DistanceMatrix({
    required this.destinationAddresses,
    required this.originAddresses,
    required this.rows,
    required this.status,
  });

  factory DistanceMatrix.fromJson(Map<String, dynamic> json) {
    return DistanceMatrix(
      destinationAddresses: List<String>.from(json['destination_addresses']),
      originAddresses: List<String>.from(json['origin_addresses']),
      rows: List<Row>.from(json['rows'].map((row) => Row.fromJson(row))),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination_addresses': destinationAddresses,
      'origin_addresses': originAddresses,
      'rows': rows.map((row) => row.toJson()).toList(),
      'status': status,
    };
  }
}

class Row {
  List<Element> elements;

  Row({
    required this.elements,
  });

  factory Row.fromJson(Map<String, dynamic> json) {
    return Row(
      elements: List<Element>.from(
          json['elements'].map((element) => Element.fromJson(element))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elements': elements.map((element) => element.toJson()).toList(),
    };
  }
}

class Element {
  Distance duration;
  Distance distance;
  String status;

  Element({
    required this.duration,
    required this.distance,
    required this.status,
  });

  factory Element.fromJson(Map<String, dynamic> json) {
    return Element(
      duration: Distance.fromJson(json['duration']),
      distance: Distance.fromJson(json['distance']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration.toJson(),
      'distance': distance.toJson(),
      'status': status,
    };
  }
}

class Distance {
  String text;
  int value;

  Distance({
    required this.text,
    required this.value,
  });

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
      text: json['text'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'value': value,
    };
  }
}
