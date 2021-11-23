import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'photo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Scroll',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Infinite Scroll'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Photo> photos = [];
  bool loading = false;
  int albumId = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getPhosts(albumId);

    _scrollController.addListener(() {
      print(_scrollController.position.pixels);
      print(_scrollController.position.maxScrollExtent);

      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        albumId++;
        getPhosts(albumId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getPhosts(int albumId) async {
    // jsonplaceholder.typicode.com에서 albumId당 50개의 목록을 제공한다.
    if (albumId > 50) {
      return;
    }
    final String url =
        'https://jsonplaceholder.typicode.com/photos?albumId=$albumId';

    try {
      if (albumId == 1) {
        setState(() => loading = true);
      }

      http.Response response = await http.get(Uri.parse(url));
      if (albumId == 1) {
        setState(() => loading = false);
      }

      final items = json.decode(response.body);

      items.forEach((item) {
        photos.add(Photo.fromJson(item));
      });

      setState(() {});
    } catch (err) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.red[200],
            title: const Text('Failure'),
            content: const Text('Fail to get album data'),
          );
        },
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: photos.length + 1,
                // itemCount를 의도적으로 늘린다 (CircularProgressIndicator를 표시하기 위해)
                itemBuilder: (ctx, i) {
                  if (i == photos.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          Image.network(
                            photos[i].url,
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Text(photos[i].title),
                        ],
                      ),
                      Text(
                        '${i + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ],
                  );
                },
              ));
  }
}
