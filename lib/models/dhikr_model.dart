class DhikrModel {
  final String id;
  final String title;
  final String text;
  final int targetCount;
  int currentCount;

  DhikrModel({
    required this.id,
    required this.title,
    required this.text,
    this.targetCount = 33,
    this.currentCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'text': text,
        'targetCount': targetCount,
        'currentCount': currentCount,
      };

  factory DhikrModel.fromJson(Map<String, dynamic> json) => DhikrModel(
        id: json['id'] as String,
        title: json['title'] as String,
        text: json['text'] as String,
        targetCount: json['targetCount'] as int? ?? 33,
        currentCount: json['currentCount'] as int? ?? 0,
      );

  DhikrModel copyWith({int? currentCount}) {
    return DhikrModel(
      id: id,
      title: title,
      text: text,
      targetCount: targetCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}
