import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class GifPage extends StatelessWidget {
  const GifPage({super.key, required this.gifData});

  final Map<String, dynamic> gifData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(gifData["title"], style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => shareGifUrl(gifData["images"]["fixed_height"]["url"]),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(gifData["images"]["fixed_height"]["url"]),
      ),
    );
  }

  Future<void> shareGifUrl(String gifUrl) async {
    final params = ShareParams(
      text: 'Olha este GIF: $gifUrl',
      // você pode colocar title ou subject se quiser
      // subject: 'Veja isso!',
    );
    final result = await SharePlus.instance.share(params);
    // Você pode checar o status:
    if (result.status == ShareResultStatus.success) {
      print('Compartilhado com sucesso!');
    } else {
      print('Compartilhamento cancelado ou falhou.');
    }
  }
}
