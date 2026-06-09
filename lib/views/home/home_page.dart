import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../providers/record_provider.dart';
import '../../services/deepseek_service.dart';
import '../list/list_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  File? image;
  bool loading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final result = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (result == null) return;

    setState(() {
      image = File(result.path);
      loading = true;
    });

    try {
      final record =
      await DeepSeekService().analyze(result.path);

      await ref
          .read(recordProvider.notifier)
          .addRecord(record);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ListPage(),
        ),
      );
    } catch (e) {
      debugPrint("分析失败: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("分析失败: ${e.toString().length > 60 ? e.toString().substring(0, 60) : e.toString()}"),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("火烧云预测"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  image!,
                  height: 200,
                ),
              ),

            const SizedBox(height: 20),

            loading
                ? Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor:
              Colors.grey.shade600,
              child: Container(
                height: 120,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.1),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            )
                : GestureDetector(
              onTap: pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6C63FF),
                      Color(0xFF00D4FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text(
                  "AI 解析气象图",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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