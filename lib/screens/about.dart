import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Latar Belakang',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'images/gis.png',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black),
                    children: [
                      TextSpan(text: 'Aplikasi ini terinspirasi dari semangat buku yang saya tulis dari tugas pak rengga yaitu: \n'),
                      TextSpan(
                        text: 'Merekam Bumi & Mengurai Ruang\n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text:
                        'mengajak kita menelusuri perjalanan panjang Sistem Informasi Geografis (SIG), mulai dari masa kartografi manual hingga era digital '
                            'yang dipenuhi dengan data besar dan pemodelan spasial berbasis kecerdasan buatan. Lebih dari sekadar teknologi, aplikasi ini hadir untuk '
                            'menggambarkan bagaimana SIG berkembang sebagai alat yang tidak hanya memetakan ruang, tetapi juga memahami interaksi kompleks di dalamnya, '
                            'dengan landasan filosofis dan teori yang mendalam sebagai pijakan.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
