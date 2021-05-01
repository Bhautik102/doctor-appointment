abstract class Model1 {
  final String id;

  Model1(this.id);

  Map<String, dynamic> toMap();
  Map<String, dynamic> toUpdateMap();

  @override
  String toString() {
    return this.toMap().toString();
  }
}
