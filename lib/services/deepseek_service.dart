import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/cloud_record.dart';

class DeepSeekService {
  final Dio _dio = Dio();

  // DeepSeek API Key
  final String apiKey = "sk-bdf47ced304e40068c97df8a10248039";

  /// 根据文件扩展名返回 MIME 类型
  String _getMimeType(String path) {
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  /// 从 AI 返回的文本中提取第一个 JSON 对象
  /// 兼容带 ```json ... ``` markdown 包裹的情况
  String _extractJson(String raw) {
    final trimmed = raw.trim();
    // 尝试提取 markdown 代码块中的 JSON
    final codeBlock = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(trimmed);
    if (codeBlock != null) return codeBlock.group(1)!.trim();
    // 尝试从文本中提取 { ... } 包裹的最外层 JSON
    final firstBrace = trimmed.indexOf('{');
    final lastBrace = trimmed.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace > firstBrace) {
      return trimmed.substring(firstBrace, lastBrace + 1);
    }
    return trimmed;
  }

  Future<CloudRecord> analyze(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _getMimeType(imagePath);

      final response = await _dio.post(
        "https://api.deepseek.com/v1/chat/completions",
        options: Options(
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          // 60 秒超时，大图可能需要更长时间
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: {
          "model": "deepseek-chat",
          "stream": false,
          "max_tokens": 2048,
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "你是一个专业的气象图像分析专家。"
                      "请分析这张天空/云层照片，以 JSON 格式返回以下字段"
                      "（直接返回纯 JSON，不要使用 markdown 代码块包裹）：\n"
                      "- probability: 火烧云（晚霞）出现概率，0-100 的整数\n"
                      "- humidity: 湿度评分，0-100 的整数\n"
                      "- cloud: 云量评分，0-100 的整数\n"
                      "- light: 透光率评分，0-100 的整数\n"
                      "- type: 云的类型描述，如 '积云'、'层云'、'卷云' 等\n"
                      "- report: 详细的中文气象分析报告（80-150字）\n\n"
                      "请确保字段名使用英文，值的数据类型正确。"
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:$mimeType;base64,$base64Image"
                  }
                }
              ]
            }
          ]
        },
      );

      // 安全地读取响应内容
      final choices = response.data["choices"];
      if (choices == null || choices.isEmpty) {
        throw Exception("API 返回异常：choices 为空");
      }
      final content = choices[0]?["message"]?["content"];
      if (content == null) {
        throw Exception("API 返回异常：message content 为空");
      }

      // 提取并解析 JSON
      final rawJson = _extractJson(content.toString());
      final Map<String, dynamic> json;
      try {
        json = jsonDecode(rawJson) as Map<String, dynamic>;
      } catch (e) {
        throw Exception(
          "JSON 解析失败: $e\n原始内容: ${content.toString().substring(0, content.toString().length.clamp(0, 500))}",
        );
      }

      return CloudRecord(
        id: const Uuid().v4(),
        imagePath: imagePath,
        probability: (json["probability"] ?? 0).toDouble(),
        humidityScore: (json["humidity"] ?? 0).toInt(),
        cloudScore: (json["cloud"] ?? 0).toInt(),
        lightScore: (json["light"] ?? 0).toInt(),
        cloudType: json["type"]?.toString() ?? "未知",
        report: json["report"]?.toString() ?? "暂无分析报告",
        createTime: DateTime.now(),
      );
    } catch (e) {
      debugPrint("DeepSeek API 调用失败: $e");
      rethrow;
    }
  }
}