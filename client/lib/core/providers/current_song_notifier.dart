// ignore_for_file: avoid_public_notifier_properties
//this file control all the logic of song playing

import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  late HomeLocalRepository _homeLocalRepository;

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

//this function is responsible to update the song
  void updateSong(SongModel song) async {
//
// Check if the song is the same as the current song
    if (state?.song_url == song.song_url) {
// If the song is the same, do nothing
      return;
    }

    /// Stop the current song if it is playing
    if (audioPlayer != null) {
      await audioPlayer!.stop();
    }

    ///

    audioPlayer = AudioPlayer();

    final audioSource = AudioSource.uri(
      Uri.parse(song.song_url),
      tag: MediaItem(
        id: song.id,
        title: song.song_name,
        artist: song.artist,
        artUri: Uri.parse(song.thumbnail_url),
      ),
    );

    await audioPlayer!.setAudioSource(audioSource);

    audioPlayer!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioPlayer!.seek(Duration.zero);
        audioPlayer!.pause();
        isPlaying = false;

        this.state = this.state?.copyWith(hex_code: this.state?.hex_code);
      }
    });

// this call teh upload local song functionto store songs in hive
    _homeLocalRepository.uploadLocalSong(song);

//play the song
    audioPlayer!.play();
    isPlaying = true;
    state = song;
  }

//function to play and pause music
  void playPause() {
    if (isPlaying) {
      audioPlayer?.pause();
    } else {
      audioPlayer?.play();
    }
    isPlaying = !isPlaying;
    state = state?.copyWith(
        hex_code: state
            ?.hex_code); //thie updates the ui by giving info whcih is actually nothing
  }

  //this help to get seaked value of song
  void seek(double val) {
    audioPlayer!.seek(
      Duration(
        milliseconds: (val * audioPlayer!.duration!.inMilliseconds).toInt(),
      ),
    );
  }
}
