class Company {
  const Company({required this.id, required this.name, this.active = true});

  final String id;
  final String name;
  final bool active;
}

class Site {
  const Site({
    required this.id,
    required this.companyId,
    required this.name,
    required this.address,
    required this.timezone,
  });

  final String id;
  final String companyId;
  final String name;
  final String address;
  final String timezone;
}

class Floor {
  const Floor({
    required this.id,
    required this.siteId,
    required this.name,
    required this.number,
  });

  final String id;
  final String siteId;
  final String name;
  final int number;
}

class Area {
  const Area({
    required this.id,
    required this.floorId,
    required this.name,
    this.description = '',
    this.active = true,
  });

  final String id;
  final String floorId;
  final String name;
  final String description;
  final bool active;
}
