import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firstapp/constant.dart';
import 'package:firstapp/details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';

class ApiTest extends StatefulWidget {
  const ApiTest({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ApiTestState createState() => _ApiTestState();
}

class _ApiTestState extends State<ApiTest> {
  int _page = 1;
  double _perPage = 10;
  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();
  List data = [];
  bool isInternet = true;
  @override
  void initState() {
    internetCheker();
    getData();
    _scrollController.addListener(_onScroll);
    // ignore: todo

    super.initState();
  }

  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      getData();
    }
  }

  Future getData() async {
    internetCheker();
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/comments?_page=$_page&_limit=10'));
    if (response.statusCode == 200) {
      var resBoody = jsonDecode(response.body);

      setState(() {
        data.addAll(resBoody);
        _page++;
        _isLoading = false;
      });
      // ignore: avoid_print
      print(" here number of data : ${data.length}");
    } else {
      throw Exception('Failed to load data');
    }
  }

  void refreshData() async {
    // ignore: unrelated_type_equality_checks
    if (InternetConnectionChecker().hasConnection == true) {
      await getData();
    } else {
      const SnackBar(content: Text("no internet "));
    }
  }

  internetCheker() async {
    isInternet = await InternetConnectionChecker().hasConnection;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: isInternet
            ? data.isEmpty || data == null
                ? const CircularProgressIndicator()
                : Scrollbar(
                    thumbVisibility: true,
                    // ignore: deprecated_member_use
                    showTrackOnHover: true,
                    child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverAppBar(
                            pinned: true,
                            backgroundColor: Colors.teal[800],
                            expandedHeight: 200.0,
                            flexibleSpace: const FlexibleSpaceBar(
                              title: Text('Horizons'),
                              centerTitle: true,
                            ),
                          ),
                          _buildListData()
                        ]),
                  )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset("assets/lotties/a.json"),
                    ),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal),
                        onPressed: () {
                          setState(() {
                            refreshData();
                          });
                        },
                        icon: const Icon(Icons.reply_all_outlined),
                        label: const Text('try Again'))
                  ],
                ),
              ),
      ),
    );
  }

  _buildListData() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == data.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
                return const Details();
              })));
            },
            child: ListTile(
              title: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      const BoxShadow(
                          color: Colors.black12,
                          blurRadius: 1,
                          offset: Offset(0, 1))
                    ],
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        height: 50,
                        width: 50,
                        child: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text("${data[index]["postId"]}"),
                        )),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${data[index]["name"]}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${data[index]["email"]}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          Text(
                            "${data[index]["body"]}",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
      }, childCount: data.length + (_isLoading ? 1 : 0)),
    );
  }
}
