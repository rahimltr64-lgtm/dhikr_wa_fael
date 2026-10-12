class TaskModel {
  final String id;
  String title;
  bool isCompleted;
  DateTime? reminderTime;
  String? linkedDhikr;

  TaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.reminderTime,
    this.linkedDhikr,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'reminderTime': reminderTime?.toIso8601String(),
        'linkedDhikr': linkedDhikr,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        reminderTime: json['reminderTime'] != null
            ? DateTime.tryParse(json['reminderTime'] as String)
            : null,
        linkedDhikr: json['linkedDhikr'] as String?,
      );
}
