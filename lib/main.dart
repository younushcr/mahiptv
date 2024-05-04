import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isDrawerOpen = false;

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    List<Channel> channels = [
      Channel(name: "Animal Planet", url: "https://example.com/animal-planet.m3u8"),
      Channel(name: "Discovery", url: "https://example.com/discovery.m3u8"),
      // Add more channels here
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('IPTV App', style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.blue, letterSpacing: .5))),
        leading: IconButton(icon: Icon(Icons.menu), onPressed: toggleDrawer),
        actions: [
          IconButton(icon: Icon(Icons.account_circle, color: Color(0xff004AAD), size: 50), onPressed: () {}),
        ],
      ),
      endDrawer: SideMenu(),
      body: Stack(
        children: [
          IPTVScreen(channels: channels),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: isDrawerOpen ? screenWidth / 2 - 50 : screenWidth,
            right: 0,
            top: 0,
            bottom: 0,
            child: SideMenu(),
          ),
        ],
      ),
    );
  }
}

class IPTVScreen extends StatelessWidget {
  final List<Channel> channels;

  IPTVScreen({required this.channels});

  @override
  Widget build(BuildContext context) {
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
                      decoration: InputDecoration(hintText: 'Search', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: channels.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(channels[index].name),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => VideoPlayerScreen(channels[index].url)),
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
              child: ChannelCarousel(channels: channels),
            ),
          ],
        ),
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        bottom: true,
        top: true,
        minimum: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade400,
            borderRadius: BorderRadius.circular(60),
          ),
          child: ListView(
            children: [
              DrawerHeader(
                child: Image.network('https://testing.macvision.global/assets/img/mahincha.com-logo.png', fit: BoxFit.contain),
              ),
              ListTile(title: Text('About'), onTap: () {
                // Show about text
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('About'),
                    content: Text('This is an IPTV application.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
                  ),
                );
              }),
              ListTile(title: Text('Services'), onTap: () {}),
              ListTile(title: Text('Info'), onTap: () {
                // Show info text
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Info'),
                    content: Text('This is some information about the app.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class ChannelCarousel extends StatefulWidget {
  final List<Channel> channels;

  ChannelCarousel({required this.channels});

  @override
  _ChannelCarouselState createState() => _ChannelCarouselState();
}

class _ChannelCarouselState extends State<ChannelCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.channels.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideoPlayerScreen(widget.channels[index].url)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChannelCard(channelNumber: index + 1, channelName: widget.channels[index].name),
            ),
          );
        },
      ),
    );
  }
}

class ChannelCard extends StatelessWidget {
  final int channelNumber;
  final String channelName;

  ChannelCard({required this.channelNumber, required this.channelName});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade200,
      elevation: 10,
      child: Center(
        child: Text('Channel $channelNumber: $channelName'),
      ),
    );
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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
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
                child: VideoPlayer(_controller),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Channel {
  String name;
  String url;

  Channel({required this.name, required this.url});
}
