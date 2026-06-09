import 'dart:io';

import 'package:flutter/material.dart';
import '../../models/cloud_record.dart';

class DetailPage extends StatelessWidget {
  final CloudRecord record;

  const DetailPage(this.record, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: record.id,
                child: Image.file(
                  File(record.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    "火烧云概率",
                    "${record.probability.toInt()}%",
                  ),

                  _buildCard(
                    "湿度评分",
                    "${record.humidityScore}",
                  ),

                  _buildCard(
                    "云量评分",
                    "${record.cloudScore}",
                  ),

                  _buildCard(
                    "透光评分",
                    "${record.lightScore}",
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "AI分析报告",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    record.report,
                    style: TextStyle(
                      color: Colors.white
                          .withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}