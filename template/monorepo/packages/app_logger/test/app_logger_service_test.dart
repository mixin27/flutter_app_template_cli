import 'package:app_logger/app_logger.dart';
import 'package:test/test.dart';

void main() {
  test('logger methods can be called without throwing', () {
    final logger = AppLogger(enabled: false);

    logger.debug('debug');
    logger.info('info');
    logger.warning('warning');
    logger.error('error');
    logger.critical('critical');

    expect(logger.talker, isNotNull);
  });
}
