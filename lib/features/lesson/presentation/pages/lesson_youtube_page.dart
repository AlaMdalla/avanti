import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonYoutubePage extends StatefulWidget {
  final String videoUrl;
  const LessonYoutubePage({super.key, required this.videoUrl});

  @override
  State<LessonYoutubePage> createState() => _LessonYoutubePageState();
}

class _LessonYoutubePageState extends State<LessonYoutubePage> {
  YoutubePlayerController? _controller;
  String? _videoId;

  bool get _useEmbeddedPlayer {
    // Use the embedded player only on mobile platforms (Android/iOS).
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (_useEmbeddedPlayer && _videoId != null && _videoId!.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(widget.videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d’ouvrir la vidéo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we decided not to use embedded player (desktop/web), show a fallback UI
    // with a button to open the video externally.
    if (!_useEmbeddedPlayer) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vidéo')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'La lecture intégrée n’est disponible que sur mobile. Ouvrir la vidéo en externe ?',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Ouvrir la vidéo'),
                  onPressed: _openExternally,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // For mobile, ensure we have a valid video id and controller.
    if (_videoId == null || _videoId!.isEmpty || _controller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vidéo')),
        body: const Center(child: Text('Impossible de lire la vidéo YouTube')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vidéo')),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _controller!),
        builder: (context, player) {
          return Column(
            children: [
              player,
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Lecture YouTube intégrée',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
