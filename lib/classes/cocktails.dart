class Cocktails {
  int id = 0;
  String name = '';
  String category = '';
  String glass = '';
  String instructions = '';
  String img_url = '';
  bool alcoholic = false;

  Cocktails(this.id, this.name, this.category, this.glass, this.instructions, this.img_url, this.alcoholic);

  factory Cocktails.fromMap(Map<String, dynamic> json) {
    return Cocktails(
      json['id'],
      json['name'],
      json['category'],
      json['glass'],
      json['instructions'],
      json['imageUrl'],
      json['alcoholic'],
    );
  }
}