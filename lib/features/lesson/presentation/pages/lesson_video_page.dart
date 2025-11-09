import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonVideoPage extends StatefulWidget {
  final String videoUrl;
  const LessonVideoPage({super.key, required this.videoUrl});

  @override
  State<LessonVideoPage> createState() => _LessonVideoPageState();
}

class _LessonVideoPageState extends State<LessonVideoPage> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _error = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print('🎬 [VIDEO] Tentative d\'ouverture: ${widget.videoUrl}');
    
    // Sur Linux/Windows/macOS desktop, video_player n'est pas supporté
    // On ouvre avec le lecteur système
    final isDesktop = !kIsWeb && (
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS
    );
    
    if (isDesktop) {
      print('🖥️ [VIDEO] Plateforme desktop détectée, ouverture avec lecteur système');
      _openWithSystemPlayer();
      return;
    }
    
    // videoUrl may be a network URL or a local file path
    try {
      if (widget.videoUrl.startsWith('http')) {
        print('🌐 [VIDEO] Détecté comme URL réseau');
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        print('📁 [VIDEO] Détecté comme fichier local');
        final file = File(widget.videoUrl);
        print('📁 [VIDEO] Chemin complet: ${file.path}');
        print('📁 [VIDEO] Fichier existe: ${file.existsSync()}');
        
        if (!file.existsSync()) {
          print('❌ [VIDEO] Fichier introuvable!');
          setState(() {
            _error = true;
            _errorMessage = 'Fichier introuvable:\n${widget.videoUrl}';
          });
          return;
        }
        _controller = VideoPlayerController.file(file);
      }
      
      print('⏳ [VIDEO] Initialisation du lecteur...');
      _controller?.initialize().then((_) {
        print('✅ [VIDEO] Lecteur initialisé avec succès');
        if (mounted) {
          setState(() => _initialized = true);
        }
      }).catchError((error) {
        print('❌ [VIDEO] Erreur d\'initialisation: $error');
        if (mounted) {
          setState(() {
            _error = true;
            _errorMessage = 'Erreur d\'initialisation:\n$error';
          });
        } else {
          _error = true;
          _errorMessage = 'Erreur d\'initialisation:\n$error';
        }
      });
    } catch (e) {
      print('❌ [VIDEO] Exception: $e');
      setState(() {
        _error = true;
        _errorMessage = 'Exception:\n$e';
      });
    }
  }

  Future<void> _openWithSystemPlayer() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.linux) {
        // Sur Linux, essayer différents lecteurs vidéo courants
        print('🐧 [VIDEO] Tentative d\'ouverture avec lecteurs Linux');
        
        final players = ['vlc', 'mpv', 'celluloid', 'totem', 'gnome-videos'];
        bool opened = false;
        
        for (final player in players) {
          try {
            print('🔍 [VIDEO] Essai avec $player...');
            final result = await Process.run(
              player,
              [widget.videoUrl],
              runInShell: false,
            ).timeout(const Duration(seconds: 2));
            
            if (result.exitCode == 0 || result.exitCode == null) {
              print('✅ [VIDEO] Ouvert avec succès via $player');
              opened = true;
              break;
            }
          } catch (e) {
            print('⏭️ [VIDEO] $player non disponible, essai suivant...');
            continue;
          }
        }
        
        if (opened) {
          // Retour automatique après ouverture
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) Navigator.of(context).pop();
            });
          }
        } else {
          print('❌ [VIDEO] Aucun lecteur vidéo trouvé');
          if (mounted) {
            setState(() {
              _error = true;
              _errorMessage = 'Aucun lecteur vidéo trouvé.\n\nVeuillez installer VLC ou MPV:\nsudo apt install vlc\nou\nsudo apt install mpv';
            });
          }
        }
        return;
      }
      
      // Pour les autres plateformes desktop (Windows, macOS)
      final Uri uri;
      if (widget.videoUrl.startsWith('http')) {
        uri = Uri.parse(widget.videoUrl);
      } else {
        uri = Uri.file(widget.videoUrl);
      }
      
      print('🚀 [VIDEO] Ouverture URI: $uri');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ [VIDEO] Ouvert avec succès');
        // Retour automatique après ouverture
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.of(context).pop();
          });
        }
      } else {
        print('❌ [VIDEO] Impossible de lancer l\'URI');
        if (mounted) {
          setState(() {
            _error = true;
            _errorMessage = 'Impossible d\'ouvrir la vidéo avec le lecteur système.\nChemin: ${widget.videoUrl}';
          });
        }
      }
    } catch (e) {
      print('❌ [VIDEO] Exception lors de l\'ouverture: $e');
      if (mounted) {
        setState(() {
          _error = true;
          _errorMessage = 'Erreur lors de l\'ouverture:\n$e';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecture vidéo')),
      body: Center(
        child: _error
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage.isEmpty 
                        ? 'Erreur: vidéo introuvable ou non lisible' 
                        : _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                    ),
                  ],
                ),
              )
            : _controller == null
                ? const Text('Impossible de créer le lecteur vidéo')
                : !_initialized
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio == 0
                                ? 16 / 9
                                : _controller!.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                VideoPlayer(_controller!),
                                _PlayPauseOverlay(controller: _controller!),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: VideoProgressIndicator(
                                    _controller!,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                      backgroundColor: Colors.black26,
                                      bufferedColor: Colors.white38,
                                      playedColor: Colors.indigo,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                                iconSize: 40,
                                onPressed: () {
                                  setState(() {
                                    _controller!.value.isPlaying
                                        ? _controller!.pause()
                                        : _controller!.play();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.replay_10),
                                onPressed: () {
                                  final current = _controller!.value.position;
                                  _controller!.seekTo(current - const Duration(seconds: 10));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.forward_10),
                                onPressed: () {
                                  final current = _controller!.value.position;
                                  _controller!.seekTo(current + const Duration(seconds: 10));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  const _PlayPauseOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: Colors.black26,
            ),
          ),
          Center(
            child: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 56.0,
            ),
          ),
        ],
      ),
    );
  }
}
