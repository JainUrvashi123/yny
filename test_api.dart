import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  const baseUrl = 'https://ynyjewelsinc.com/m_api';

  try {
    print("--- GET DIAMOND BY STOCK ---");
    final res = await dio.post(
      '$baseUrl/diamond-list',
      data: {
        "page": 0,
        "per_page": 50,
        "stock": "BD-351238"
      },
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }),
    );
    print("Status code: ${res.statusCode}");
    print("Response data keys: ${res.data.keys}");
    print("Status in data: ${res.data['status']}");
    print("Data length: ${res.data['data']?.length}");
    if (res.data['data'] != null && res.data['data'].isNotEmpty) {
      print("First item keys: ${res.data['data'][0].keys}");
      print("First item description: ${res.data['data'][0]['description']}");
    }
  } catch (e) {
    if (e is DioException) {
      print("ERROR: ${e.response?.data}");
    } else {
      print("ERROR: $e");
    }
  }
}
