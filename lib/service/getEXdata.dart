// import 'package:language_app/Models/exercise_model.dart';
// import 'package:language_app/res/imagesLA/AppImages.dart';

// class MockExerciseData {
//   static List<ExerciseModel> getGrammarExercises() {
//     return [
//       // Người mới bắt đầu
//       ExerciseModel(
//         id: 1,
//         name: 'Hiện tại đơn cơ bản',
//         type: 'grammar',
//         level: 'Người mới bắt đầu', // Thêm level
//         description: 'Bài tập ngữ pháp cho người mới bắt đầu',
//         duration: 15,
//         theory:
//             "Thì hiện tại đơn diễn tả một hành động xảy ra thường xuyên, thói quen hoặc sự thật hiển nhiên.\n"
//             "- Cấu trúc: \n"
//             "  + Khẳng định: S + V(s/es) + O \n"
//             "  + Phủ định: S + do/does + not + V + O \n"
//             "  + Nghi vấn: Do/Does + S + V + O ?",
//         audio: '',
//       ),
//       // Cơ bản
//       ExerciseModel(
//         id: 2,
//         name: 'Quá khứ đơn',
//         type: 'grammar',
//         level: 'Cơ bản', // Thêm level
//         description: 'Bài tập ngữ pháp cấp độ cơ bản',
//         duration: 20,
//         theory:
//             "Thì quá khứ đơn được sử dụng để diễn tả các hành động đã hoàn thành trong quá khứ.\n"
//             "- Cấu trúc: \n"
//             "  + Khẳng định: S + V2 + O \n"
//             "  + Phủ định: S + did + not + V(nguyên mẫu) + O \n"
//             "  + Nghi vấn: Did + S + V(nguyên mẫu) + O ?",
//         audio: '',
//       ),
//       // Trung cấp
//       ExerciseModel(
//         id: 3,

//         name: 'Hiện tại hoàn thành',
//         type: 'grammar',
//         level: 'Trung cấp', // Thêm level
//         description: 'Bài tập ngữ pháp cấp độ trung cấp',
//         duration: 25,
//         theory:
//             "Thì hiện tại hoàn thành được sử dụng để diễn tả một hành động đã hoàn thành và có liên quan đến hiện tại.\n"
//             "- Cấu trúc: \n"
//             "  + Khẳng định: S + have/has + V3 + O \n"
//             "  + Phủ định: S + have/has + not + V3 + O \n"
//             "  + Nghi vấn: Have/Has + S + V3 + O ?",
//         audio: '',
//       ),
//       // Nâng cao
//       ExerciseModel(
//         id: 12,
//         name: 'Câu điều kiện',
//         type: 'grammar',
//         level: 'Nâng cao', // Thêm level
//         description: 'Bài tập ngữ pháp cấp độ nâng cao',
//         duration: 30,
//         theory:
//             "Câu điều kiện được sử dụng để diễn tả các tình huống giả định.\n"
//             "- Loại 1: Điều kiện thực tế\n"
//             "  + Cấu trúc: If + S + V(hiện tại), S + will + V\n"
//             "- Loại 2: Điều kiện không thực tế\n"
//             "  + Cấu trúc: If + S + V(quá khứ), S + would + V",
//         audio: '',
//       ),
//     ];
//   }

//   static List<ExerciseModel> getListeningExercises() {
//     return [
//       // Người mới bắt đầu
//       ExerciseModel(
//           id: 4,
//           name: 'Nghe hội thoại cơ bản',
//           type: 'listening',
//           level: 'Người mới bắt đầu', // Thêm level
//           description: 'Bài tập nghe cho người mới bắt đầu',
//           duration: 15,
//           audio: 'https://example.com/basic_listening.mp3',
//           theory: ''),
//       // Cơ bản
//       ExerciseModel(
//           id: 5,
//           name: 'Nghe mô tả hàng ngày',
//           type: 'listening',
//           level: 'Cơ bản', // Thêm level
//           description: 'Bài tập nghe hiểu mô tả cuộc sống hàng ngày',
//           imageUrl: AppImages.listen,
//           duration: 20,
//           audio: 'https://example.com/daily_life_listening.mp3',
//           theory: ''),
//       // Trung cấp
//       ExerciseModel(
//           id: 6,
//           name: 'Nghe tin tức',
//           type: 'listening',
//           level: 'Trung cấp', // Thêm level
//           description: 'Bài tập nghe hiểu tin tức và sự kiện',
//           imageUrl: AppImages.listen,
//           duration: 25,
//           audio: 'https://example.com/news_listening.mp3',
//           theory: ''),
//       // Nâng cao
//       ExerciseModel(
//           id: 7,
//           name: 'Nghe phỏng vấn chuyên sâu',
//           type: 'listening',
//           level: 'Nâng cao', // Thêm level
//           description:
//               'Bài tập nghe hiểu phỏng vấn và cuộc trò chuyện phức tạp',
//           imageUrl: AppImages.listen,
//           duration: 30,
//           audio: 'https://example.com/advanced_interview_listening.mp3',
//           theory: ''),
//     ];
//   }

//   static List<ExerciseModel> getSpeakingExercises() {
//     return [
//       // Người mới bắt đầu
//       ExerciseModel(
//           id: 8,
//           name: 'Phát âm từ vựng cơ bản',
//           type: 'speaking',
//           level: 'Người mới bắt đầu', // Thêm level
//           description: 'Bài tập phát âm cho người mới bắt đầu',
//           imageUrl: AppImages.imgnoi,
//           duration: 15,
//           audio: '',
//           theory: ''),
//       // Cơ bản
//       ExerciseModel(
//           id: 9,
//           name: 'Giao tiếp hàng ngày',
//           type: 'speaking',
//           level: 'Cơ bản', // Thêm level
//           description: 'Bài tập giao tiếp và phát âm cơ bản',
//           imageUrl: AppImages.imgnoi,
//           duration: 20,
//           audio: '',
//           theory: ''),
//       // Trung cấp
//       ExerciseModel(
//         id: 10,
//         name: 'Miêu tả hình ảnh',
//         type: 'speaking',
//         level: 'Trung cấp', // Thêm level
//         description: 'Bài tập miêu tả và trình bày',
//         imageUrl: AppImages.imgnoi,
//         duration: 25,
//         audio: '',
//         theory: '',
//       ),
//       // Nâng cao
//       ExerciseModel(
//         id: 11,
//         name: 'Thuyết trình',
//         type: 'speaking',
//         level: 'Nâng cao', // Thêm level
//         description: 'Bài tập thuyết trình và giao tiếp chuyên sâu',
//         imageUrl: AppImages.imgnoi,
//         duration: 30,
//         audio: '',
//         theory: '',
//       ),
//     ];
//   }
// }
