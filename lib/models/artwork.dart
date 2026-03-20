class Artwork {
  int? id;
  String title;
  String artist;
  int year;
  String category;
  String description;
  int createdBy; // ID của user sở hữu

  Artwork({
    this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.category,
    required this.description,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'year': year,
      'category': category,
      'description': description,
      'createdBy': createdBy,
    };
  }

  factory Artwork.fromMap(Map<String, dynamic> map) {
    return Artwork(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      year: map['year'],
      category: map['category'],
      description: map['description'],
      createdBy: map['createdBy'],
    );
  }
}
