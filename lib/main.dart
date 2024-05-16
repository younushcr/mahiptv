import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mahincha IPTV'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon tap
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Handle profile icon tap
            },
          ),
        ],
      ),
      drawer: SideMenu(),
      body: IPTVScreen(),
    );
  }
}

class IPTVScreen extends StatelessWidget {




  final List<Map<String, String>> channels = [];

  Future<void> fetchChannelUrls() async {

      final data = await http.get(Uri.parse('http://192.168.29.139/adminuxpro-10/HTML/pages/API/ip_data.php'));
      print("dsfsdfsdfsdfsdfsdf2");


      // print(response1['data']['ipdata']);
        print(data.body);
        final m3u=json.decode(data.body);
        // print(response.body);
        // print(response.statusCode);
        // final Map<String, dynamic> data = json.decode(response1.body);

        var id = m3u['data']['id'];
        var  ipdata =m3u['data']['ipdata'];
        print(ipdata);
        print("loaded");



    print("kkkkk");
    final response = await http.get(Uri.parse(ipdata));
    print(response.body);
    if (response.statusCode == 200) {
      final List<String> lines = LineSplitter.split(response.body).toList();
      String channelName = '';
      lines.forEach((line) {
        if (line.startsWith('#EXTINF')) {
          final RegExpMatch? match = RegExp(r'#EXTINF:.*,(.*)').firstMatch(line);
          if (match != null) {
            channelName = match.group(1)!;
            // Only add channels with text titles, not just numbers
            if (!RegExp(r'^\d+$').hasMatch(channelName)) {
              channels.add({'name': channelName, 'url': ''});
            }
          }
        } else if (line.startsWith('http') && channels.isNotEmpty) {
          channels.last['url'] = line;
        }
      });
    } else {
      throw Exception('Failed to fetch channel URLs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:fetchChannelUrls() ,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: channels.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(channels[index]['name']!),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(channels[index]['url']!),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ChannelCarousel(channels),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.network(
              'https://testing.macvision.global/assets/img/mahincha.com-logo.png',
              fit: BoxFit.contain,
            ),
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              // Show about text
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('About'),
                    content: Text('This is an IPTV application.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('Services'),
            onTap: () {
              // Navigate to services screen
            },
          ),
          ListTile(
            title: Text('Info'),
            onTap: () {
              // Show info text
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Info'),
                    content: Text('This is some information about the app.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChannelCarousel extends StatefulWidget {
  final List<Map<String, String>> channels;

  ChannelCarousel(this.channels);

  @override
  _ChannelCarouselState createState() => _ChannelCarouselState();
}

class _ChannelCarouselState extends State<ChannelCarousel> {
  final List<String> imageUrls = [
    'https://media.maalaimalar.com/h-upload/2024/03/14/500x300_2023649-whatsappimage2024-03-14at61501pm.webp',
    'https://i.guim.co.uk/img/media/7158435d8423a83ab4f8de87d26de9398baa0a77/0_0_2560_1536/500.jpg?quality=85&auto=format&fit=max&s=6bbc8223d9302945afe2fa9d1132314c',
    'https://media-cache.cinematerial.com/p/500x/um3yvebh/junglee-indian-movie-poster.jpg?v=1678972107',
    'https://media-cache.cinematerial.com/p/500x/xvbz4vvf/irumbu-thirai-indian-movie-poster.jpg?v=1514991989',
    'https://media-cache.cinematerial.com/p/500x/yjpjgvpt/mahanati-indian-movie-poster.jpg?v=1544730490',
    'https://media-cache.cinematerial.com/p/500x/0ra5dlcm/doddmane-hudga-indian-movie-poster.jpg?v=1468955517',
    'https://assets.thehansindia.com/h-upload/2020/01/04/500x300_251294-trip.webp',
    'https://assets.thehansindia.com/h-upload/2023/05/05/500x300_1349956-hanu.jpg',
    'https://assets.thehansindia.com/h-upload/2020/04/14/500x300_961781-theri.webp',
    'https://assets.thehansindia.com/h-upload/2019/12/11/500x300_244217-vijays-bigil.jpg',
  ];

  late PageController _pageController;
  int _currentPage = 0;
  late List<Future<String>> _preloadFutures;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.8,
    );
    _preloadFutures = List.generate(widget.channels.length, (_) => fetchRandomImage());
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    Future.delayed(Duration(seconds: 3), () {
      if (_currentPage < widget.channels.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
      );
      _startAutoSlide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.channels.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(widget.channels[index]['url']!),
              ),
            );
          },
          child: FutureBuilder(
            future: _preloadFutures[index],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return Image.network(
                  snapshot.data.toString(),
                  fit: BoxFit.contain,
                );
              }
            },
          ),
        );
      },
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
        if (_currentPage == widget.channels.length - 1) {
          _currentPage = 0;
          _pageController.jumpToPage(0);
        }
      },
    );
  }

  Future<String> fetchRandomImage() async {
    final int randomIndex = Random().nextInt(imageUrls.length);
    return imageUrls[randomIndex];
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen(this.videoUrl);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.videoUrl,
    );
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: Center(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  children: [
                    VideoPlayer(_controller),
                    if (!_isFullScreen)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              _isFullScreen = true;
                            });
                          },
                          child: Icon(Icons.fullscreen),
                        ),
                      ),
                    if (_isFullScreen)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFullScreen = false;
                          });
                        },
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          child: Center(
                            child: Icon(
                              Icons.fullscreen_exit,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: !_isFullScreen
          ? FloatingActionButton(
        onPressed: () {
          // Your logic to go to the next channel
        },
        child: Icon(Icons.navigate_next),
      )
          : null,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}