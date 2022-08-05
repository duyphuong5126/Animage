import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Fetching all artists', () async {
    List<int> abc = [1, 6, 5, 3, 4, 2]..sort((a, b) {
      int result = b.compareTo(a);
      print('Test>>> result=$result');
      return result;
    });
    print('Test>>> abc=$abc');
  });
}