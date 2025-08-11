import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String _apiKey = 'AIzaSyBQKmLLGV8I3PxV-g0Oif6M3LBHo7Od1JI';
  
  static final YoutubeExplode _yt = YoutubeExplode();
  
  static Future<List<Map<String, dynamic>>> searchVideos(String query, {int maxResults = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?part=snippet&type=video&q=${Uri.encodeComponent(query)}&maxResults=$maxResults&key=$_apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> videos = [];
        
        for (final item in data['items']) {
          videos.add({
            'id': item['id']['videoId'],
            'title': item['snippet']['title'],
            'channel': item['snippet']['channelTitle'],
            'thumbnail': item['snippet']['thumbnails']['high']['url'],
            'description': item['snippet']['description'],
            'publishedAt': item['snippet']['publishedAt'],
            'url': 'https://www.youtube.com/watch?v=${item['id']['videoId']}',
          });
        }
        
        return videos;
      } else {
        print('Search API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching videos: $e');
      Fluttertoast.showToast(msg: 'Search failed: $e');
      return [];
    }
  }
  
  static Future<Map<String, dynamic>?> getVideoInfo(String videoUrl) async {
    try {
      // Extract video ID from URL
      final videoId = extractVideoId(videoUrl);
      if (videoId == null) {
        print('Invalid YouTube URL: $videoUrl');
        return null;
      }
      
      print('Fetching video info for ID: $videoId');
      
      // Try YouTube Explode first
      try {
        final video = await _yt.videos.get(videoId);
        
        return {
          'id': video.id.value,
          'title': video.title,
          'channel': video.author,
          'artist': video.author,
          'thumbnail': video.thumbnails.highResUrl,
          'duration': video.duration?.inSeconds ?? 0,
          'description': video.description,
          'url': videoUrl,
          'viewCount': video.engagement.viewCount,
          'likeCount': video.engagement.likeCount,
        };
      } catch (explodeError) {
        print('YouTube Explode failed: $explodeError');
        
        // Fallback to YouTube API if available
        try {
          final response = await http.get(
            Uri.parse('$_baseUrl/videos?part=snippet,contentDetails,statistics&id=$videoId&key=$_apiKey'),
          );
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['items'] != null && data['items'].isNotEmpty) {
              final item = data['items'][0];
              final snippet = item['snippet'];
              final contentDetails = item['contentDetails'];
              final statistics = item['statistics'];
              
              // Parse duration from ISO 8601 format
              int durationSeconds = 0;
              if (contentDetails['duration'] != null) {
                durationSeconds = _parseDuration(contentDetails['duration']);
              }
              
              return {
                'id': videoId,
                'title': snippet['title'] ?? 'Unknown Title',
                'channel': snippet['channelTitle'] ?? 'Unknown Channel',
                'artist': snippet['channelTitle'] ?? 'Unknown Artist',
                'thumbnail': snippet['thumbnails']['high']['url'] ?? 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                'duration': durationSeconds,
                'description': snippet['description'] ?? '',
                'url': videoUrl,
                'viewCount': int.tryParse(statistics['viewCount'] ?? '0') ?? 0,
                'likeCount': int.tryParse(statistics['likeCount'] ?? '0') ?? 0,
              };
            }
          }
        } catch (apiError) {
          print('YouTube API also failed: $apiError');
        }
        
        // Last resort - create basic info from video ID
        return {
          'id': videoId,
          'title': 'YouTube Video',
          'channel': 'Unknown Channel',
          'artist': 'Unknown Artist',
          'thumbnail': 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
          'duration': 0,
          'description': '',
          'url': videoUrl,
          'viewCount': 0,
          'likeCount': 0,
        };
      }
    } catch (e) {
      print('Error fetching video info: $e');
      return null;
    }
  }
  
  static Future<List<Map<String, dynamic>>> getTrendingVideos({int maxResults = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/videos?part=snippet,statistics&chart=mostPopular&regionCode=US&videoCategoryId=10&maxResults=$maxResults&key=$_apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> videos = [];
        
        for (final item in data['items']) {
          videos.add({
            'id': item['id'],
            'title': item['snippet']['title'],
            'channel': item['snippet']['channelTitle'],
            'thumbnail': item['snippet']['thumbnails']['high']['url'],
            'description': item['snippet']['description'],
            'viewCount': int.tryParse(item['statistics']['viewCount'] ?? '0') ?? 0,
            'likeCount': int.tryParse(item['statistics']['likeCount'] ?? '0') ?? 0,
            'url': 'https://www.youtube.com/watch?v=${item['id']}',
          });
        }
        
        return videos;
      } else {
        print('Trending API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting trending videos: $e');
      return [];
    }
  }
  
  static Future<String?> getAudioStreamUrl(String videoUrl) async {
    try {
      final videoId = extractVideoId(videoUrl);
      if (videoId == null) return null;
      
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly
          .where((stream) => stream.codec.mimeType.contains('mp4'))
          .withHighestBitrate();
      
      return audioStream.url.toString();
    } catch (e) {
      print('Error getting audio stream: $e');
      return null;
    }
  }
  
  static String? extractVideoId(String url) {
    // Updated regex to handle YouTube Shorts URLs as well
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|shorts\/|\S*?[?\&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
  
  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final secs = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
  
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  // Parse ISO 8601 duration format (PT1H2M10S) to seconds
  static int _parseDuration(String isoDuration) {
    try {
      final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
      final match = regex.firstMatch(isoDuration);
      
      if (match != null) {
        final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
        final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
        final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
        
        return hours * 3600 + minutes * 60 + seconds;
      }
    } catch (e) {
      print('Error parsing duration: $e');
    }
    return 0;
  }
  
  static void dispose() {
    _yt.close();
  }
}
