import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../shared.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.soloAmbient,
    ));
  }

  _isMicDisabled() {
    return $DB.get('mic', 1) == 0 ? true : false;
  }

  playRightAnswer() {
    if (_isMicDisabled()) {
      return;
    }

    _player
      ..setAsset('assets/audio/right.wav')
      ..play();
  }

  playTap() {
    if (_isMicDisabled()) {
      return;
    }
    _player
      ..setAsset('assets/audio/click.wav')
      ..play();
  }

  playWrongAnswer() {
    if (_isMicDisabled()) {
      return;
    }
    _player
      ..setAsset('assets/audio/wrong.wav')
      ..play();
  }
}
