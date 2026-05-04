import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final supabase = Supabase.instance.client;

  // Controllers
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final kodePosC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  final weightC = TextEditingController();
  final heightC = TextEditingController();
  final bloodC = TextEditingController();
  final allergyC = TextEditingController();
  final historyC = TextEditingController();

  bool obscurePassword = true;

  // API wilayah
  List provinces = [];
  List regencies = [];
  List districts = [];
  List villages = [];

  String? provinceId, regencyId, districtId, villageId;
  String? provinceName, regencyName, districtName, villageName;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  // ================= API =================

  Future<void> fetchProvinces() async {
    final res = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json'));
    setState(() => provinces = json.decode(res.body));
  }

  Future<void> fetchRegencies(String id) async {
    final res = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$id.json'));
    setState(() {
      regencies = json.decode(res.body);
      districts = [];
      villages = [];
    });
  }

  Future<void> fetchDistricts(String id) async {
    final res = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$id.json'));
    setState(() {
      districts = json.decode(res.body);
      villages = [];
    });
  }

  Future<void> fetchVillages(String id) async {
    final res = await http.get(Uri.parse(
        'https://www.emsifa.com/api-wilayah-indonesia/api/villages/$id.json'));
    setState(() => villages = json.decode(res.body));
  }

  // ================= REGISTER =================

  Future<void> register() async {
    if (passwordC.text != confirmPasswordC.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak sama')),
      );
      return;
    }

    try {
      final auth = await supabase.auth.signUp(
        email: emailC.text,
        password: passwordC.text,
      );

      final userId = auth.user!.id;

      await supabase.from('patients').insert({
        'id': userId,
        'full_name': nameC.text,
        'email': emailC.text,
        'phone': phoneC.text,
        'provinsi': provinceName,
        'kota': regencyName,
        'kecamatan': districtName,
        'kelurahan': villageName,
        'kode_pos': kodePosC.text,
        'address': addressC.text,
        'weight': weightC.text,
        'height': heightC.text,
        'blood_type': bloodC.text,
        'allergy': allergyC.text,
        'medical_history': historyC.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
              color: const Color(0xFF00BBA7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Daftar Pasien",
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text("Buat akun untuk layanan fisioterapi",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  section("Informasi Pribadi"),

                  label("Nama Lengkap *"),
                  field("Masukkan nama lengkap", nameC, Icons.person),

                  label("Email *"),
                  field("nama@email.com", emailC, Icons.email),

                  label("Nomor Telepon *"),
                  field("+62 812 xxxx", phoneC, Icons.phone),

                  label("Alamat"),
                  dropdown("Pilih Provinsi", provinces, provinceId,
                      Icons.location_on, (val) {
                    setState(() {
                      provinceId = val['id'];
                      provinceName = val['name'];
                    });
                    fetchRegencies(val['id']);
                  }),

                  dropdown("Pilih Kota", regencies, regencyId,
                      Icons.location_city, (val) {
                    setState(() {
                      regencyId = val['id'];
                      regencyName = val['name'];
                    });
                    fetchDistricts(val['id']);
                  }),

                  dropdown("Pilih Kecamatan", districts, districtId,
                      Icons.map, (val) {
                    setState(() {
                      districtId = val['id'];
                      districtName = val['name'];
                    });
                    fetchVillages(val['id']);
                  }),

                  dropdown("Pilih Kelurahan", villages, villageId,
                      Icons.home, (val) {
                    setState(() {
                      villageId = val['id'];
                      villageName = val['name'];
                    });
                  }),

                  field("Kode Pos", kodePosC, Icons.numbers),
                  field("Alamat lengkap", addressC, Icons.home,
                      maxLines: 3),

                  const SizedBox(height: 20),

                  section("Informasi Medis"),
                  helper(
                      "Informasi ini membantu terapis memberikan perawatan terbaik"),

                  Row(
                    children: [
                      Expanded(
                          child: field(
                              "Berat (kg)", weightC, Icons.monitor_weight)),
                      const SizedBox(width: 10),
                      Expanded(
                          child:
                              field("Tinggi (cm)", heightC, Icons.height)),
                    ],
                  ),

                  field("Golongan Darah", bloodC, Icons.bloodtype),
                  field("Alergi", allergyC, Icons.warning),
                  field("Riwayat Penyakit", historyC, Icons.history,
                      maxLines: 3),

                  const SizedBox(height: 20),

                  section("Keamanan Akun"),

                  label("Password *"),
                  passwordField("Minimal 8 karakter", passwordC),

                  label("Konfirmasi Password *"),
                  passwordField("Ulangi password", confirmPasswordC),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BBA7),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Daftar Sekarang",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= COMPONENT =================

  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget helper(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
    );
  }

  Widget field(String hint, TextEditingController c, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 18),
          filled: true,
          fillColor: const Color(0xFFF5F7F9),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget passwordField(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscurePassword,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.lock, size: 18),
          suffixIcon: IconButton(
            icon: Icon(obscurePassword
                ? Icons.visibility_off
                : Icons.visibility),
            onPressed: () {
              setState(() => obscurePassword = !obscurePassword);
            },
          ),
          filled: true,
          fillColor: const Color(0xFFF5F7F9),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget dropdown(String hint, List data, String? value, IconData icon,
      Function(dynamic) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField(
        value: value,
        hint: Text(hint),
        items: data
            .map<DropdownMenuItem>((e) => DropdownMenuItem(
                  value: e['id'],
                  child: Text(e['name']),
                ))
            .toList(),
        onChanged: (val) {
          final selected =
              data.firstWhere((element) => element['id'] == val);
          onChanged(selected);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18),
          filled: true,
          fillColor: const Color(0xFFF5F7F9),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}