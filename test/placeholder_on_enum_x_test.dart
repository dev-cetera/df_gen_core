import 'package:df_gen_core/df_gen_core.dart';
import 'package:test/test.dart';

enum _T { ALPHA, BETA }

void main() {
  test('placeholder wraps the enum name with triple underscores', () {
    expect(_T.ALPHA.placeholder, '___ALPHA___');
    expect(_T.BETA.placeholder, '___BETA___');
  });
}
