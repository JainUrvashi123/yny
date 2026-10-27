class CartModel {
  final String? cartId;
  final String? productId;
  final String? stockId;
  final String? quantity;
  final String? productType;
  final String? price;
  final String? totalPrice;
  final String? name;
  final String? description;
  final String? image;
  final String? diamondVideo;
  final String? reportFilename;
  final String? reportNo;
  final String? availability;
  final String? rapnet;
  final String? costCarat;
  final String? eyeClean;
  final String? keytosymb;
  final String? country;

  CartModel({
    this.cartId,
    this.productId,
    this.stockId,
    this.quantity,
    this.productType,
    this.price,
    this.totalPrice,
    this.name,
    this.description,
    this.image,
    this.diamondVideo,
    this.reportFilename,
    this.reportNo,
    this.availability,
    this.rapnet,
    this.costCarat,
    this.eyeClean,
    this.keytosymb,
    this.country,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: json['cart_id']?.toString(),
      productId: json['product_id']?.toString(),
      stockId: json['stock_id']?.toString(),
      quantity: json['quantity']?.toString(),
      productType: json['product_type']?.toString(),
      price: json['price']?.toString(),
      totalPrice: json['total_price']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      diamondVideo: json['diamond_video']?.toString(),
      reportFilename: json['report_filename']?.toString(),
      reportNo: json['report_no']?.toString(),
      availability: json['availability']?.toString(),
      rapnet: json['rapnet']?.toString(),
      costCarat: json['cost_carat']?.toString(),
      eyeClean: json['eye_clean']?.toString(),
      keytosymb: json['keytosymb']?.toString(),
      country: json['country']?.toString(),
    );
  }
}
