import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gifs_search_engine/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? wordSearch;
  int offset = 0;

  final appBarTitle =
      "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif";

  Future<Map> search() async {
    http.Response response;

    if (wordSearch == null || wordSearch!.isEmpty) {
      response = await http.get(
        Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=kcJ0NfnpErRVw7fVqLx8aRwMmaJC4Hyx&limit=25&offset=$offset&rating=g&bundle=messaging_non_clips",
        ),
      );
    } else {
      response = await http.get(
        Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=kcJ0NfnpErRVw7fVqLx8aRwMmaJC4Hyx&q=$wordSearch&limit=25&offset=$offset&rating=g&lang=en&bundle=messaging_non_clips",
        ),
      );
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    search().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(appBarTitle),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search here!",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white, fontSize: 18),
              onSubmitted: (text) {
                setState(() {
                  wordSearch = text;
                  offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: search(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int getCount(List data) {
    if (wordSearch == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: snapshot.data["data"].length + 1,
      itemBuilder: (context, index) {
        if (index < snapshot.data["data"].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image:
                  snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GifPage(gifData: snapshot.data["data"][index]),
                ),
              );
            },
            onLongPress: () => shareGifUrl(
              snapshot.data["data"][index]["images"]["fixed_height"]["url"],
            ),
          );
        } else {
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 70),
                Text(
                  "Load more...",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                offset += 25;
              });
            },
          );
        }
      },
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
