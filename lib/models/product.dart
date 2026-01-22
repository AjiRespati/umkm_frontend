class Product {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String? imageUrl;

  Product({required this.id, required this.name, required this.price, required this.stock, this.imageUrl});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: json['price'].toDouble(),
        stock: json['stock'],
        imageUrl: json['imageUrl'],
      );
}