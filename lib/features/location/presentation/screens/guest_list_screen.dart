import 'package:flutter/material.dart';

class GuestListScreen extends StatefulWidget {
  const GuestListScreen({super.key});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  // Variabel kontrol untuk tab filter status
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Check-In', 'Selesai'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kunjungan Tamu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff1B5E20), // Primary Color #1B5E20
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. Search Bar (Kolom Pencarian) di bagian atas
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama tamu atau keperluan...',
                prefixIcon: const Icon(Icons.search, color: Color(0xff1B5E20)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff1B5E20), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // 2. Filter Badges (Pilihan Status Kunjungan)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filterName = _filters[index];
                final isSelected = _selectedFilter == filterName;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filterName),
                    selected: isSelected,
                    selectedColor: const Color(0xff1B5E20),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) _selectedFilter = filterName;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // 3. Daftar Utama Tamu (List View)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 5, // Angka tiruan (dummy count) untuk mock visual awal
              itemBuilder: (context, index) {
                // Mock status tiruan untuk membedakan tampilan
                final bool isCheckIn = index % 2 == 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 1, // Aturan elevasi card rest: 1
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Radius card 16dp sesuai laporan
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    leading: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xff1B5E20),
                      child: Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Muhammad Revan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        // Badge status kunjungan
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCheckIn ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isCheckIn ? 'Check-In' : 'Selesai',
                            style: TextStyle(
                              color: isCheckIn ? Colors.orange[800] : Colors.green[800],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text('Keperluan: Interview Kerja', style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              isCheckIn ? 'Masuk: 13:15 WIB' : 'Masuk: 09:00 - Keluar: 11:30 WIB',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
