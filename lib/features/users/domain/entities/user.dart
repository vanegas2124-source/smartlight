enum UserRole { administrator, supervisor, user }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.companyId,
    this.active = true,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String companyId;
  final bool active;
}
