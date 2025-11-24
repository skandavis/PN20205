class FamilyMember {
  String id;
  String name;
  String email;
  String relation;
  FamilyMember({
    required this.id,
    required this.name,
    required this.email,
    required this.relation
  });

  void displayFamilyMemberDetails() {
    print('FamilyMember Details:');
    print('ID: $id');
    print('Name: $name');
  }
 @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyMember && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    
    return FamilyMember(
      id: json['id'],
      name: json['name'],
      relation: json['relation'],
      email: json['email'],
    );
  }

}