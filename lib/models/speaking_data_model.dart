// Mô hình dữ liệu cho speaking data đã được tối ưu hóa và kiểm tra lỗi
import 'dart:convert';

class SpeakingDataModel {
  final int id;
  final List<SpeakingData> data;
  final int exerciseId;

  SpeakingDataModel({
    required this.id,
    required this.data,
    required this.exerciseId,
  });

  factory SpeakingDataModel.fromJson(Map<String, dynamic> json) {
    try {
      // Kiểm tra và xử lý trường data
      List<SpeakingData> speakingDataList = [];
      if (json['data'] != null) {
        if (json['data'] is List) {
          speakingDataList = List<SpeakingData>.from(
              json['data'].map((x) => SpeakingData.fromJson(x)));
        } else if (json['data'] is String) {
          // Trường hợp data là chuỗi JSON
          try {
            final decodedData = jsonDecode(json['data']);
            if (decodedData is List) {
              speakingDataList = List<SpeakingData>.from(
                  decodedData.map((x) => SpeakingData.fromJson(x)));
            }
          } catch (e) {
            print('Error decoding data JSON string: $e');
          }
        }
      }

      return SpeakingDataModel(
        id: json['id'] ?? 0,
        data: speakingDataList,
        exerciseId: json['exerciseId'] ?? 0,
      );
    } catch (e) {
      print('Error parsing SpeakingDataModel: $e');
      // Trả về một mô hình mặc định với danh sách rỗng khi có lỗi
      return SpeakingDataModel(
        id: 0,
        data: [],
        exerciseId: 0,
      );
    }
  }

  // Chuyển đổi đối tượng thành chuỗi cho việc debug
  @override
  String toString() {
    return 'SpeakingDataModel(id: $id, exerciseId: $exerciseId, data.length: ${data.length})';
  }

  // Tạo một bản sao của đối tượng với dữ liệu mới
  SpeakingDataModel copyWith({
    int? id,
    List<SpeakingData>? data,
    int? exerciseId,
  }) {
    return SpeakingDataModel(
      id: id ?? this.id,
      data: data ?? this.data,
      exerciseId: exerciseId ?? this.exerciseId,
    );
  }

  // Chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data.map((x) => x.toJson()).toList(),
      'exerciseId': exerciseId,
    };
  }
}

class SpeakingData {
  final String sentence;
  final String translation;

  SpeakingData({
    required this.sentence,
    required this.translation,
  });

  // Constructor với giá trị mặc định
  SpeakingData.fallback()
      : sentence = "",
        translation = "";

  // Tạo đối tượng SpeakingData từ dữ liệu JSON với xử lý lỗi
  factory SpeakingData.fromJson(Map<String, dynamic> json) {
    try {
      return SpeakingData(
        sentence: json['sentence'] ?? "",
        translation: json['translation'] ?? "",
      );
    } catch (e) {
      print('Error parsing SpeakingData: $e');
      return SpeakingData.fallback();
    }
  }

  // Chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'sentence': sentence,
      'translation': translation,
    };
  }

  // Chuyển đổi đối tượng thành chuỗi cho việc debug
  @override
  String toString() {
    return 'SpeakingData(sentence: $sentence, translation: $translation)';
  }
}
