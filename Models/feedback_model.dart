class Feedback {
  final int? id;
  final int userId;
  final int doctorId;
  final String? message;
  final int? rating; // 1 to 5

  Feedback({
    this.id,
    required this.userId,
    required this.doctorId,
    this.message,
    this.rating,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'doctor_id': doctorId,
        'message': message,
        'rating': rating,
      };

  factory Feedback.fromMap(Map<String, dynamic> map) => Feedback(
        id: map['id'],
        userId: map['user_id'],
        doctorId: map['doctor_id'],
        message: map['message'],
        rating: map['rating'],
      );

  @override
  String toString() =>
      'Feedback(userId: $userId, doctorId: $doctorId, rating: $rating)';
}
