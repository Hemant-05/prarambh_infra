import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MediaCarousel extends StatefulWidget {
  final List<Map<String, String>> mediaItems;
  
  /// Pass this as true when the screen is navigated away from, 
  /// so the carousel can pause the video.
  final bool isVisible;

  const MediaCarousel({
    super.key,
    required this.mediaItems,
    this.isVisible = true,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  Timer? _carouselTimer;

  // Video state
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoPlaying = false;
  bool _isUserManuallySwiped = false;

  @override
  void initState() {
    super.initState();
    _initCurrentMedia();
    _startCarousel();
  }

  @override
  void didUpdateWidget(covariant MediaCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the widget becomes invisible (navigated away), pause the video
    if (oldWidget.isVisible && !widget.isVisible) {
      _videoPlayerController?.pause();
    } 
    // If the widget becomes visible again, play the video if it's the current media
    else if (!oldWidget.isVisible && widget.isVisible) {
      if (_isVideoCurrent()) {
        _videoPlayerController?.play();
      }
    }
  }

  bool _isVideoCurrent() {
    if (widget.mediaItems.isEmpty) return false;
    return widget.mediaItems[_currentIndex]['type'] == 'video';
  }

  Future<void> _initCurrentMedia() async {
    if (_isVideoCurrent()) {
      await _initVideo(widget.mediaItems[_currentIndex]['url']!);
    } else {
      _disposeVideo();
    }
  }

  Future<void> _initVideo(String url) async {
    _disposeVideo();
    
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: widget.isVisible, // Only auto-play if the screen is currently visible
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      showControlsOnInitialize: false,
      fullScreenByDefault: false,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blueAccent,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white,
      ),
    );

    _videoPlayerController!.addListener(_videoListener);
    if (mounted) setState(() {});
  }

  void _videoListener() {
    if (_videoPlayerController == null) return;
    
    final bool isPlaying = _videoPlayerController!.value.isPlaying;
    if (isPlaying != _isVideoPlaying) {
      _isVideoPlaying = isPlaying;
    }

    // Check if video has ended
    if (_videoPlayerController!.value.isInitialized &&
        !_videoPlayerController!.value.isPlaying &&
        _videoPlayerController!.value.position >= _videoPlayerController!.value.duration &&
        _videoPlayerController!.value.position > Duration.zero) {
      
      // Video ended -> move to next slide
      _isUserManuallySwiped = false; // Reset manual swipe flag
      _moveToNext();
    }
  }

  void _disposeVideo() {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    
    _chewieController?.dispose();
    _chewieController = null;
  }

  void _startCarousel() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (!widget.isVisible) return; // Don't auto-slide if screen is hidden
      if (widget.mediaItems.isEmpty || !_pageController.hasClients) return;
      if (_isUserManuallySwiped) return; // Stop auto-sliding if user interacted
      
      // If the current media is a video, DO NOT auto-slide away from it
      if (_isVideoCurrent()) {
        return; 
      }

      _moveToNext();
    });
  }

  void _moveToNext() {
    if (widget.mediaItems.isEmpty || !_pageController.hasClients) return;
    int next = (_currentIndex + 1) % widget.mediaItems.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // When the page changes, initialize the new media
    _initCurrentMedia();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.width * 9 / 16,
          width: double.infinity,
          child: widget.mediaItems.isNotEmpty
              ? GestureDetector(
                  onPanDown: (_) {
                    // Mark as manually swiped if the user interacts with the carousel
                    _isUserManuallySwiped = true;
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.mediaItems.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final media = widget.mediaItems[index];
                      if (media['type'] == 'video') {
                        return _chewieController != null &&
                                _chewieController!.videoPlayerController.value.isInitialized
                            ? Chewie(controller: _chewieController!)
                            : const Center(child: CircularProgressIndicator(color: Colors.blue));
                      } else {
                        return Image.network(
                          media['url']!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.domain,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
        // Dot Indicators
        if (widget.mediaItems.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.mediaItems.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 10 : 6,
                  height: _currentIndex == index ? 10 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    boxShadow: [
                      if (_currentIndex == index)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
