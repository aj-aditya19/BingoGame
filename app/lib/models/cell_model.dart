class CellModel {
  int? value;
  bool chosen;

  CellModel({this.value, this.chosen = false});

  Map<String, dynamic> toJson() => {"value": value, "chosen": chosen};

  factory CellModel.fromJson(Map<String, dynamic> json) {
    return CellModel(value: json["value"], chosen: json["chosen"] ?? false);
  }
}
