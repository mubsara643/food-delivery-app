import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiPracticeScreen extends StatefulWidget {
  const ApiPracticeScreen({super.key});

  @override
  State<ApiPracticeScreen> createState() => _ApiPracticeScreenState();
}

class _ApiPracticeScreenState extends State<ApiPracticeScreen> {
  List posts = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );

      if (response.statusCode == 200) {
        setState(() {
          posts = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          error = 'API Error: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Something went wrong';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Practice'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${post['id']}'),
                      ),
                      title: Text(post['title']),
                      subtitle: Text(post['body']),
                    );
                  },
                ),
    );
  }
}