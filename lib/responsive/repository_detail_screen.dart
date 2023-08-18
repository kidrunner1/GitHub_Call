import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RepositoryDetailScreen extends StatefulWidget {
  final String repositoryName;
  final String username;

  RepositoryDetailScreen(
      {required this.repositoryName,
      required this.username,
      required String repositoryUrl});

  @override
  _RepositoryDetailScreenState createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState extends State<RepositoryDetailScreen> {
  late Future<Map<String, dynamic>> _repositoryData;

  @override
  void initState() {
    super.initState();
    // ดึงรายละเอียดที่เก็บเมื่อเริ่มต้นหน้าจอ
    _repositoryData =
        fetchRepositoryDetails(widget.username, widget.repositoryName);
  }

  Future<Map<String, dynamic>> fetchRepositoryDetails(
      String username, String repositoryName) async {
    // ทำการเรียก API เพื่อดึงรายละเอียดที่เก็บโดยใช้ GitHub API
    final response = await http.get(
        Uri.parse('https://api.github.com/repos/$username/$repositoryName'));

    if (response.statusCode == 200) {
      // หากการตอบสนองสำเร็จ ให้ถอดรหัสข้อมูล JSON
      final Map<String, dynamic> repositoryData = json.decode(response.body);
      return repositoryData;
    } else {
      // หากการตอบสนองไม่สำเร็จ โยนข้อยกเว้น
      throw Exception(
          'Failed to load repository details: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade300,
        title: Text('Repository Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _repositoryData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ขณะที่กำลังดึงข้อมูล แสดงการโหลด
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // หากเกิดข้อผิดพลาดระหว่างการดึงข้อมูล ให้แสดงข้อความแสดงข้อผิดพลาด
            return Center(child: Text('Error loading repository details'));
          }

          final repositoryData = snapshot.data!;

          // เมื่อมีข้อมูลแล้ว ให้แสดงรายละเอียดที่เก็บโดยใช้ SingleChildScrollView
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แสดงชื่อที่เก็บเป็นตัวหนา
                Text(
                  repositoryData['name'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // แสดงคำอธิบายที่เก็บ (หรือ 'ไม่มีคำอธิบาย')
                Text(
                  repositoryData['description'] ?? 'No description available',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                // แสดงภาษาที่เก็บ
                Text(
                  'Language: ${repositoryData['language'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                // แสดงจำนวนส้อมที่เก็บ
                Text(
                  'Forks: ${repositoryData['forks_count'] ?? 0}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                // Display repository stargazers count
                Text(
                  'Stars: ${repositoryData['stargazers_count'] ?? 0}',
                  style: TextStyle(fontSize: 16),
                ),
                // Add more details as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
