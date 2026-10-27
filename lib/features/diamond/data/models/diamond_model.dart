class DiamondResponseModel {
  final int status;
  final String message;
  final String totalRecords;
  final int perPage;
  final int page;
  final List<DiamondModel> data;

  DiamondResponseModel({
    required this.status,
    required this.message,
    required this.totalRecords,
    required this.perPage,
    required this.page,
    required this.data,
  });

  factory DiamondResponseModel.fromJson(Map<String, dynamic> json) {
    return DiamondResponseModel(
      status: json['status'] is int ? json['status'] : int.tryParse(json['status'].toString()) ?? 0,
      message: json['message']?.toString() ?? '',
      totalRecords: json['total_records']?.toString() ?? '0',
      perPage: json['per_page'] is int ? json['per_page'] : int.tryParse(json['per_page'].toString()) ?? 50,
      page: json['page'] is int ? json['page'] : int.tryParse(json['page'].toString()) ?? 0,
      data: (json['data'] is List)
          ? (json['data'] as List)
              .map((i) => i is Map ? DiamondModel.fromJson(Map<String, dynamic>.from(i)) : null)
              .whereType<DiamondModel>()
              .toList()
          : [],
    );
  }
}

class DiamondModel {
  final String? color;
  final String? cut;
  final String? symmetry;
  final String? fluorescenceInt;
  final String? polish;
  final String? country;
  final String? crownAngle;
  final String? crownHt;
  final String? culet;
  final String? culetCon;
  final String? culetSize;
  final String? depth;
  final String? diamondId;
  final String? diamondImage;
  final String? diamondVideo;
  final String? girdle;
  final String? girdleCon;
  final String? girdlePerct;
  final String? grade;
  final String? lab;
  final String? labLocation;
  final String? measurements;
  final String? memberComment;
  final String? pavillionAngle;
  final String? pavillionDepth;
  final String? availability;
  final String? reportFilename;
  final String? reportNo;
  final String? shade;
  final String? shape;
  final String? stockId;
  final String? tableD;
  final String? weight;
  final String? diamondType;
  final String? brand;
  final String? brComment;
  final String? cn;
  final String? sn;
  final String? cw;
  final String? sw;
  final String? starLen;
  final String? answerdate;
  final String? memotootltip;
  final String? origin;
  final String? rapnet;
  final String? eyeClean;
  final String? keytosymb;
  final String? milky;
  final String? mLength;
  final String? mWidth;
  final String? mDepth;
  final String? insp;
  final String? reportDt;
  final String? ratio;
  final String? flUserActive;
  final String? costCarat;
  final String? totalPrice;
  final String? newDiscount;
  final String? claritySort;
  final String? shapeSort;
  final String? weightSort;
  final String? shapeFull;
  final String? shapeFilter;
  final String? labFull;
  final String? labFilter;
  final String? cutFull;
  final String? polishFull;
  final String? symmetryFull;
  final String? fluorFull;
  final String? vendorId;
  final String? vendorEmail;
  final String? vendorName;
  final String? vendorMobile;
  final String? vendorMarkup;

  DiamondModel({
    this.color,
    this.cut,
    this.symmetry,
    this.fluorescenceInt,
    this.polish,
    this.country,
    this.crownAngle,
    this.crownHt,
    this.culet,
    this.culetCon,
    this.culetSize,
    this.depth,
    this.diamondId,
    this.diamondImage,
    this.diamondVideo,
    this.girdle,
    this.girdleCon,
    this.girdlePerct,
    this.grade,
    this.lab,
    this.labLocation,
    this.measurements,
    this.memberComment,
    this.pavillionAngle,
    this.pavillionDepth,
    this.availability,
    this.reportFilename,
    this.reportNo,
    this.shade,
    this.shape,
    this.stockId,
    this.tableD,
    this.weight,
    this.diamondType,
    this.brand,
    this.brComment,
    this.cn,
    this.sn,
    this.cw,
    this.sw,
    this.starLen,
    this.answerdate,
    this.memotootltip,
    this.origin,
    this.rapnet,
    this.eyeClean,
    this.keytosymb,
    this.milky,
    this.mLength,
    this.mWidth,
    this.mDepth,
    this.insp,
    this.reportDt,
    this.ratio,
    this.flUserActive,
    this.costCarat,
    this.totalPrice,
    this.newDiscount,
    this.claritySort,
    this.shapeSort,
    this.weightSort,
    this.shapeFull,
    this.shapeFilter,
    this.labFull,
    this.labFilter,
    this.cutFull,
    this.polishFull,
    this.symmetryFull,
    this.fluorFull,
    this.vendorId,
    this.vendorEmail,
    this.vendorName,
    this.vendorMobile,
    this.vendorMarkup,
  });

  factory DiamondModel.fromJson(Map<String, dynamic> json) {
    return DiamondModel(
      color: json['color']?.toString(),
      cut: json['cut']?.toString(),
      symmetry: json['symmetry']?.toString(),
      fluorescenceInt: json['fluorescence_int']?.toString(),
      polish: json['polish']?.toString(),
      country: json['country']?.toString(),
      crownAngle: json['crown_angle']?.toString(),
      crownHt: json['crown_ht']?.toString(),
      culet: json['culet']?.toString(),
      culetCon: json['culet_con']?.toString(),
      culetSize: json['culet_size']?.toString(),
      depth: json['depth']?.toString(),
      diamondId: json['diamond_id']?.toString(),
      diamondImage: json['diamond_image']?.toString(),
      diamondVideo: json['diamond_video']?.toString(),
      girdle: json['girdle']?.toString(),
      girdleCon: json['girdle_con']?.toString(),
      girdlePerct: json['girdle_perct']?.toString(),
      grade: json['grade']?.toString(),
      lab: json['lab']?.toString(),
      labLocation: json['lab_location']?.toString(),
      measurements: json['measurements']?.toString(),
      memberComment: json['member_comment']?.toString(),
      pavillionAngle: json['pavillion_angle']?.toString(),
      pavillionDepth: json['pavillion_depth']?.toString(),
      availability: json['availability']?.toString(),
      reportFilename: json['report_filename']?.toString(),
      reportNo: json['report_no']?.toString(),
      shade: json['shade']?.toString(),
      shape: json['shape']?.toString(),
      stockId: json['stock_id']?.toString(),
      tableD: json['table_d']?.toString(),
      weight: json['weight']?.toString(),
      diamondType: json['diamond_type']?.toString(),
      brand: json['brand']?.toString(),
      brComment: json['br_comment']?.toString(),
      cn: json['cn']?.toString(),
      sn: json['sn']?.toString(),
      cw: json['cw']?.toString(),
      sw: json['sw']?.toString(),
      starLen: json['star_len']?.toString(),
      answerdate: json['answerdate']?.toString(),
      memotootltip: json['memotootltip']?.toString(),
      origin: json['origin']?.toString(),
      rapnet: json['rapnet']?.toString(),
      eyeClean: json['eye_clean']?.toString(),
      keytosymb: json['keytosymb']?.toString(),
      milky: json['milky']?.toString(),
      mLength: json['m_length']?.toString(),
      mWidth: json['m_width']?.toString(),
      mDepth: json['m_depth']?.toString(),
      insp: json['insp']?.toString(),
      reportDt: json['report_dt']?.toString(),
      ratio: json['ratio']?.toString(),
      flUserActive: json['FL_USER_ACTIVE']?.toString(),
      costCarat: json['cost_carat']?.toString(),
      totalPrice: json['total_price']?.toString(),
      newDiscount: json['new_discount']?.toString(),
      claritySort: json['clarity_sort']?.toString(),
      shapeSort: json['shape_sort']?.toString(),
      weightSort: json['weight_sort']?.toString(),
      shapeFull: json['shape_full']?.toString(),
      shapeFilter: json['shape_filter']?.toString(),
      labFull: json['lab_full']?.toString(),
      labFilter: json['lab_filter']?.toString(),
      cutFull: json['cut_full']?.toString(),
      polishFull: json['polish_full']?.toString(),
      symmetryFull: json['symmetry_full']?.toString(),
      fluorFull: json['fluor_full']?.toString(),
      vendorId: json['vendor_id']?.toString(),
      vendorEmail: json['vendor_email']?.toString(),
      vendorName: json['vendor_name']?.toString(),
      vendorMobile: json['vendor_mobile']?.toString(),
      vendorMarkup: json['vendor_markup']?.toString(),
    );
  }

  /// Parsed Length in mm from mLength or measurements
  double? get parsedLength {
    if (mLength != null && mLength!.trim().isNotEmpty) {
      final val = double.tryParse(mLength!.trim());
      if (val != null) return val;
    }
    if (measurements != null && measurements!.trim().isNotEmpty) {
      final parts = measurements!.split(RegExp(r'[*xX\s-]+')).where((s) => s.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        return double.tryParse(parts[0]);
      }
    }
    return null;
  }

  /// Parsed Width in mm from mWidth or measurements
  double? get parsedWidth {
    if (mWidth != null && mWidth!.trim().isNotEmpty) {
      final val = double.tryParse(mWidth!.trim());
      if (val != null) return val;
    }
    if (measurements != null && measurements!.trim().isNotEmpty) {
      final parts = measurements!.split(RegExp(r'[*xX\s-]+')).where((s) => s.isNotEmpty).toList();
      if (parts.length > 1) {
        return double.tryParse(parts[1]);
      }
    }
    return null;
  }

  /// Parsed Depth in mm from mDepth or measurements
  double? get parsedDepth {
    if (mDepth != null && mDepth!.trim().isNotEmpty) {
      final val = double.tryParse(mDepth!.trim());
      if (val != null) return val;
    }
    if (measurements != null && measurements!.trim().isNotEmpty) {
      final parts = measurements!.split(RegExp(r'[*xX\s-]+')).where((s) => s.isNotEmpty).toList();
      if (parts.length > 2) {
        return double.tryParse(parts[2]);
      }
    }
    return null;
  }

  /// Human-readable stone availability status
  String get availabilityDisplay {
    final raw = (availability ?? '').trim().toUpperCase();
    if (raw.isEmpty) return 'Available';
    if (raw == 'G') return 'Guaranteed';
    if (raw == 'M' || raw == 'ON MEMO' || raw == 'MEMO') return 'On Memo';
    if (raw == 'A' || raw == 'AVAILABLE') return 'Available';
    if (raw == 'SOLD') return 'Sold';
    if (raw == 'HOLD') return 'On Hold';
    return availability!.trim();
  }

  /// Human-readable location / country status
  String get locationDisplay {
    final c = (country ?? '').trim();
    if (c.isNotEmpty && c.toLowerCase() != 'null' && c.toLowerCase() != 'na') return c;
    final ll = (labLocation ?? '').trim();
    if (ll.isNotEmpty && ll.toLowerCase() != 'null' && ll.toLowerCase() != 'na') return ll;
    final o = (origin ?? '').trim();
    if (o.isNotEmpty && o.toLowerCase() != 'null' && o.toLowerCase() != 'na') return o;
    return '';
  }

  /// Boolean stone availability indicator for purchase / cart actions
  bool get isAvailable {
    final raw = (availability ?? '').trim().toUpperCase();
    if (raw == 'M' || raw == 'ON MEMO' || raw == 'MEMO' || raw == 'SOLD' || raw == 'HOLD') {
      return false;
    }
    return true;
  }
}
