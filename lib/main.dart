

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
      // scaffoldMessengerKey: _scaffoldKey,
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
    return Scaffold(

      appBar: AppBar(
        title: Text(
          'IPTV App',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(color: Colors.blue, letterSpacing: .5),
          ),
        ),
        leading:  Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu), // Icon for the button
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // Opens the end drawer
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle,color: Color(0xff004AAD),size: 50,),
            onPressed: () {
              // Handle profile icon tap
            },
          ),
        ],
      ),
      endDrawer: SideMenu(),
      body: Stack(
        children: [
          IPTVScreen(),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            right: isDrawerOpen ? screenWidth / 2-120  : screenWidth, // Adjust 120 based on your drawer's width
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
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Channel ${index + 1}'),
                          onTap: () {
                            // Handle channel tap
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
              child: ChannelCarousel(),
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
        bottom: true,top: true,minimum: EdgeInsets.all(20),
        child: Container(
          decoration:  BoxDecoration(
            color: Colors.blueGrey.shade400,  // Set the color of the Drawer
            borderRadius:  BorderRadius.circular(60),
          ),
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
        ),
      ),
    );
  }
}
//-----------------------------------------------------------------------------------------------------
class ChannelCarousel extends StatefulWidget {
  @override
  _ChannelCarouselState createState() => _ChannelCarouselState();
}

class _ChannelCarouselState extends State<ChannelCarousel> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.8,
    );
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    Future.delayed(Duration(seconds: 3), () {
      if (_currentPage < 4) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
      _startAutoSlide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      height: 400,
      width: 100,
      child: PageView.builder(

        controller: _pageController,
        itemCount: 5,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Play video from URL
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen('https://iptv-org.github.io/iptv/languages/mal.m3u'),
                ),
              );
            },
            child:Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChannelCard(index + 1),
                ),
          );
        },
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
      ),
    );
  }
}
//-----------------------------------------------------------------------------------------------
class ChannelCard extends StatelessWidget {
  final int channelNumber;

  ChannelCard(this.channelNumber);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade200,
      elevation: 10,
      child: Center(
        child: Text('Channel $channelNumber'),
      ),
    );
  }
}
//-------------------------------------------------------------------------------------------------
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
    _controller = VideoPlayerController.networkUrl(Uri.parse(
      widget.videoUrl,));
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
    super.dispose();
    _controller.dispose();
  }
}