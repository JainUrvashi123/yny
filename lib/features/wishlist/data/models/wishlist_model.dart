class WishlistItemModel {
  final String wishlistId;
  final String diamondId;
  final String stockId;
  final String quantity;
  final String productType;
  final String price;
  final String totalPrice;
  final String name;
  final String description;
  final String image;
  final String createdAt;
  final String customerId;
  final String? diamondVideo;
  final String? reportFilename;
  final String? reportNo;
  final String? availability;
  final String? rapnet;
  final String? costCarat;
  final String? eyeClean;
  final String? keytosymb;
  final String? country;

  WishlistItemModel({
    required this.wishlistId,
    required this.diamondId,
    required this.stockId,
    required this.quantity,
    required this.productType,
    required this.price,
    required this.totalPrice,
    required this.name,
    required this.description,
    required this.image,
    required this.createdAt,
    required this.customerId,
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

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      wishlistId: json['wishlist_id']?.toString() ?? '',
      diamondId: json['diamond_id']?.toString() ?? '',
      stockId: json['stock_id']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      productType: json['product_type']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      totalPrice: json['total_price']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
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
