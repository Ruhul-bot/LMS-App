import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../constants/app_constants.dart';
import '../../models/lecture_model.dart';
import '../../providers/course_provider.dart';

class LivePlayerScreen extends StatefulWidget {
  final LectureModel lecture;

  const LivePlayerScreen({super.key, required this.lecture});

  @override
  State<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends State<LivePlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  final bool _isFullScreen = false;
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you would get the actual stream URL from your backend
      // For this demo, we'll use a sample video URL
      final videoUrl = widget.lecture.videoUrl.isNotEmpty 
          ? widget.lecture.videoUrl
          : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
      
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoPlayerController.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: const Center(
          child: CircularProgressIndicator(),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryColor,
          handleColor: AppColors.accentColor,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade500,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load video: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final course = courseProvider.getCourseById(widget.lecture.courseId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          _isFullScreen
              ? null
              : AppBar(
                backgroundColor: Colors.black,
                title: Text(
                  widget.lecture.title,
                  style: AppTextStyles.heading3.copyWith(color: Colors.white),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.people),
                    onPressed: () => _showViewersDialog(),
                    tooltip: 'Viewers',
                  ),
                ],
              ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorWidget()
              : _isFullScreen
              ? _buildFullScreenPlayer()
              : _buildLivePlayerWithChat(course?.title),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading live stream',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            style: AppTextStyles.bodyText.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializePlayer,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenPlayer() {
    return Chewie(controller: _chewieController!);
  }

  Widget _buildLivePlayerWithChat(String? courseTitle) {
    return Column(
      children: [
        // Video Player
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Chewie(controller: _chewieController!),
        ),

        // Live Info Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.red,
          child: Row(
            children: [
              const Icon(Icons.live_tv, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'LIVE',
                style: AppTextStyles.smallText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.visibility, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                '${_getRandomViewerCount()}',
                style: AppTextStyles.smallText.copyWith(color: Colors.white),
              ),
              const Spacer(),
              Text(
                courseTitle ?? 'Live Class',
                style: AppTextStyles.smallText.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Chat Section
        Expanded(
          child: Container(
            color: AppColors.backgroundColor,
            child: Column(
              children: [
                // Chat Header
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade200,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat,
                        size: 16,
                        color: AppColors.textColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Chat',
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chat Messages
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _chatMessages.length,
                    reverse: false,
                    itemBuilder: (context, index) {
                      return _buildChatMessageItem(_chatMessages[index]);
                    },
                  ),
                ),

                // Chat Input
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 3,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: AppTextStyles.smallText.copyWith(
                              color: AppColors.lightTextColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _sendChatMessage,
                        icon: const Icon(
                          Icons.send,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessageItem(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                message.senderName,
                style: AppTextStyles.smallText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: message.isSystem ? Colors.red : AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(message.timestamp),
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.lightTextColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            message.message,
            style: AppTextStyles.bodyText.copyWith(
              color:
                  message.isSystem ? Colors.red.shade700 : AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _sendChatMessage() {
    if (_chatController.text.trim().isEmpty) return;

    setState(() {
      _chatMessages.add(
        ChatMessage(
          senderName: 'You',
          message: _chatController.text.trim(),
          timestamp: DateTime.now(),
        ),
      );
      _chatController.clear();
    });
  }

  void _showViewersDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Viewers (${_getRandomViewerCount()})',
              style: AppTextStyles.heading3,
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Colors.primaries[index % Colors.primaries.length],
                      child: Text(
                        _getRandomName()[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(_getRandomName()),
                    subtitle: Text(index < 2 ? 'Instructor' : 'Student'),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  int _getRandomViewerCount() {
    return 45; // In a real app, this would be the actual viewer count
  }

  String _getRandomName() {
    final names = [
      'John Doe',
      'Jane Smith',
      'Robert Johnson',
      'Emily Davis',
      'Michael Brown',
      'Sarah Wilson',
      'David Miller',
      'Lisa Taylor',
      'James Anderson',
      'Jennifer Thomas',
    ];
    return names[DateTime.now().millisecond % names.length];
  }
}

class ChatMessage {
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isSystem;

  ChatMessage({
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isSystem = false,
  });
}
