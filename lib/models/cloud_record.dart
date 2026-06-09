class CloudRecord {
  final String id;
  final String imagePath;

  final double probability;
  final int humidityScore;
  final int cloudScore;
  final int lightScore;

  final String cloudType;
  final String report;

  final DateTime createTime;

  CloudRecord({
    required this.id,
    required this.imagePath,
    required this.probability,
    required this.humidityScore,
    required this.cloudScore,
    required this.lightScore,
    required this.cloudType,
    required this.report,
    required this.createTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "imagePath": imagePath,
      "probability": probability,
      "humidityScore": humidityScore,
      "cloudScore": cloudScore,
      "lightScore": lightScore,
      "cloudType": cloudType,
      "report": report,
      "createTime": createTime.toIso8601String(),
    };
  }

  factory CloudRecord.fromMap(Map map) {
    return CloudRecord(
      id: map["id"],
      imagePath: map["imagePath"],
      probability: map["probability"],
      humidityScore: map["humidityScore"],
      cloudScore: map["cloudScore"],
      lightScore: map["lightScore"],
      cloudType: map["cloudType"],
      report: map["report"],
      createTime: DateTime.parse(map["createTime"]),
    );
  }
}