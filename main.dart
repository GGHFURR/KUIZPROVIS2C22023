import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

// ,e,buat kelas pinjnam model
class PinjamanModel {
  // memiliki 2 atribut yaitu id dan nama
  String id;
  String nama;

  PinjamanModel({required this.id, required this.nama}); // konstruktor

  factory PinjamanModel.fromJson(Map<String, dynamic> json) {
    return PinjamanModel(
      id: json['id'],
      nama: json['nama'],
    );
  }
}

class PinjamanCubit extends Cubit<List<PinjamanModel>> {
  PinjamanCubit() : super([]);

  // fetch data
  Future<void> fetchData(String selectedID) async {
    final response = await http
        .get(Uri.parse('http://178.128.17.76:8000/jenis_pinjaman/$selectedID'));

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      var pinjamanList = result['data'] as List<dynamic>;
      emit(pinjamanList.map((e) => PinjamanModel.fromJson(e)).toList());
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PinjamanCubit>(
          create: (BuildContext context) => PinjamanCubit(),
        ),
        // BlocProvider<ActivityCubit>(
        //   create: (BuildContext context) => ActivityCubit(),
        // ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        home: HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<StatefulWidget> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  String? SelectedPinjam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jenis Pinjaman'),
      ),
      body: Center(
        child: Column(
          children: [
            Text("2106413, Nadhief Athallah Isya; 2106923, M. Fadlan Ghafur;"
                "Saya berjanji tidak akan berbuat curang data atau membuat"
                "orang lain berbuat curang"),
            DropdownButton<String>(
              value: SelectedPinjam,
              items:
                  ['1', '2', '3'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('pinjaman jenis $value'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  SelectedPinjam = newValue!;
                  context.read<PinjamanCubit>().fetchData(newValue);
                });
              },
            ),
            Expanded(
              child: BlocBuilder<PinjamanCubit, List<PinjamanModel>>(
                builder: (context, result) => ListView.builder(
                  itemCount: result.length,
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      leading: Image.network(
                          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                      title: Text(result[index].nama),
                      subtitle: Text('Id: ${result[index].id}'),
                      // onTap: () => Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => DetilPage(id: result[index].id),
                      //   ),
                      // ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
