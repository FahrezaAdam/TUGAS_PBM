class Product {
  final int? id;
  final String name;
  final num price; // Pakai num untuk jaga-jaga kalau server mengembalikan desimal
  final String description;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  // Factory untuk memetakan data dari JSON (response GET)
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: int.tryParse(json['id']?.toString() ?? ''),
    name: json['name']?.toString() ?? 'Tanpa Nama',
    price: double.tryParse(json['price']?.toString() ?? '')?.toInt() ?? 0,
    description: json['description']?.toString() ?? '',
  );

  // Method untuk mengubah object ke JSON (request POST)
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'description': description,
  };
}