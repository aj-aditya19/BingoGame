class CellModel {
  int value;
  bool marked;

  CellModel({required this.value, this.marked = false});

  Map<String, dynamic> toJson() => {"value": value, "marked": marked};

  factory CellModel.fromJson(Map<String, dynamic> json) {
    return CellModel(value: json["value"], marked: json["marked"] ?? false);
  }
}
