class Person {
  final int id;
  final String name;
  final String? iconPath;

  Person({required this.id, required this.name, this.iconPath = 'assets/images/icon.png'});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(id: json['id'], name: json['name'], iconPath: json['iconPath']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'iconPath': iconPath};
  }

  factory Person.empty() => Person(id: 0, name: 'name', iconPath: 'assets/images/icon.png');
}
