class Doctor {
  final int? id;
  final String name;
  final String? type;           // نوع الطبيب (عام / أخصائي...)
  final String? specialty;      // التخصص
  final String? districtCommune; // الدائرة والبلدية
  final String? phone;
  final String? email;
  final String? address;
  final String? workingHours;   // ساعات العمل
  final String? appointmentBook; // حجز المواعيد (رقم أو رابط)
  final String? gps;            // إحداثيات GPS
  final String? socialNetwork;  // رابط وسائل التواصل

  // ── Availability fields ─────────────────────────
  final String? schedule;       // JSON weekly schedule (see DoctorAvailabilityService)
  final bool isAvailable;       // true if currently within working hours
  final String? lastCheckedAt;  // ISO-8601 timestamp of last availability check

  Doctor({
    this.id,
    required this.name,
    this.type,
    this.specialty,
    this.districtCommune,
    this.phone,
    this.email,
    this.address,
    this.workingHours,
    this.appointmentBook,
    this.gps,
    this.socialNetwork,
    // Availability
    this.schedule,
    this.isAvailable = false,
    this.lastCheckedAt,
  });

  // Convert Doctor → Map (for DB insert)
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'specialty': specialty,
        'district_commune': districtCommune,
        'phone': phone,
        'email': email,
        'address': address,
        'working_hours': workingHours,
        'appointment_book': appointmentBook,
        'gps': gps,
        'social_network': socialNetwork,
        // Availability
        'schedule': schedule,
        'is_available': isAvailable ? 1 : 0,
        'last_checked_at': lastCheckedAt,
      };

  // Convert Map → Doctor (from DB query)
  factory Doctor.fromMap(Map<String, dynamic> map) => Doctor(
        id: map['id'],
        name: map['name'],
        type: map['type'],
        specialty: map['specialty'],
        districtCommune: map['district_commune'],
        phone: map['phone'],
        email: map['email'],
        address: map['address'],
        workingHours: map['working_hours'],
        appointmentBook: map['appointment_book'],
        gps: map['gps'],
        socialNetwork: map['social_network'],
        // Availability
        schedule: map['schedule'],
        isAvailable: (map['is_available'] as int? ?? 0) == 1,
        lastCheckedAt: map['last_checked_at'],
      );

  @override
  String toString() => 'Doctor(id: $id, name: $name, specialty: $specialty)';
}
