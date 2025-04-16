class Contact {
  String name;
  String contact;
  String qrUrl;
  Contact({required this.name, required this.contact, required this.qrUrl});

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
        name: map["name"], contact: map["contact"], qrUrl: map["qrUrl"] ?? "");
  }

  Map<String, dynamic> toMap() {
    return {"name": name, "contact": contact, "qrUrl": qrUrl};
  }
}
