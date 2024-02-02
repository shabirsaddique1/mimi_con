import 'package:get/get.dart';

class LocalizationModel extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          "save": 'Save',
          'take_a_picture_again': 'Take a picture again',
          "eye": 'Eye',
          "mouth": 'Mouth',
          "two_or_more_faces_were_detected": 'Two or more faces were detected!',
          "no_face_found": 'No face found',
          'image_downloaded':'Image Downloaded',

        },

        /// French or other Languages Strings
        'ko_KR': {
          "save": '저장하기',
          'take_a_picture_again': '다시찍기',
          "eye": '눈',
          "mouth": '입',
          "two_or_more_faces_were_detected": '2개 이상의 얼굴이 감지되었어요! -',
          "no_face_found": '얼굴을 찾을 수 없습니다.',
          'image_downloaded':'이미지가 다운로드됨',
        }
      };
}
