import 'dart:convert';

class Sport {

  String id;
  String name;
  int votes;

  Sport({
    required this.id,
    required this.name,
    required this.votes,
  });

  factory Sport.fromJson(String str) => Sport.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Sport.fromMap(Map<String, dynamic> json) => Sport(
        name: json["name"],
        id: json["id"],
        votes: json["votes"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "id": id,
        "votes": votes,
      };
}
