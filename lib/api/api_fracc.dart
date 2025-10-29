class ApiFracc {
  final dio = Dio();

  Future<List<ApiFraccDao>>getAll() async{
    final URL = "http://127.0.0.1:3002/residentes"; 
    final response = await dio.get(URL);
    final res = response.data['results'] as List;
    return res.map((movie) => ApiFraccDao.fromMap(movie)).toList();
  }
}
