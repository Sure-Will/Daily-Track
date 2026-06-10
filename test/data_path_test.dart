import 'package:flutter_test/flutter_test.dart';

import 'package:daily_track/services/habit_bridge_io.dart';

void main() {
  group('resolveDataPath', () {
    test('环境变量优先于指针文件', () {
      final resolved = resolveDataPath(
        environment: {dataPathEnvKey: '/env/path.json'},
        pointerContent: '/pointer/path.json',
      );

      expect(resolved, '/env/path.json');
    });

    test('无环境变量时使用指针文件内容并去除空白', () {
      final resolved = resolveDataPath(
        environment: const {},
        pointerContent: '  /pointer/path.json\n',
      );

      expect(resolved, '/pointer/path.json');
    });

    test('指针文件支持 ~/ 前缀展开', () {
      final resolved = resolveDataPath(
        environment: const {'HOME': '/Users/tester'},
        pointerContent: '~/repos/Daily-Track/data/daily-track.json',
      );

      expect(resolved, '/Users/tester/repos/Daily-Track/data/daily-track.json');
    });

    test('环境变量同样支持 ~/ 前缀展开', () {
      final resolved = resolveDataPath(
        environment: const {
          'HOME': '/Users/tester',
          dataPathEnvKey: '~/data.json',
        },
        pointerContent: null,
      );

      expect(resolved, '/Users/tester/data.json');
    });

    test('空白指针内容回退到默认相对路径', () {
      final resolved = resolveDataPath(
        environment: const {},
        pointerContent: '   \n',
      );

      expect(resolved, defaultDataPath);
    });

    test('两者都缺失时回退到默认相对路径', () {
      final resolved = resolveDataPath(environment: const {});

      expect(resolved, defaultDataPath);
    });
  });

  group('expandHomePath', () {
    test('非 ~/ 路径原样返回', () {
      expect(expandHomePath('/abs/path', const {'HOME': '/h'}), '/abs/path');
    });

    test('缺少 HOME 时原样返回', () {
      expect(expandHomePath('~/x.json', const {}), '~/x.json');
    });
  });
}
