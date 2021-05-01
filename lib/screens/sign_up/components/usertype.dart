class UserType {
  int id;
  String name;

  UserType(this.id, this.name);

  static List<UserType> getCompanies() {
    return <UserType>[
      UserType(1, 'HOSPITAL'),
      UserType(2, 'PATIENT'),
    ];
  }
}