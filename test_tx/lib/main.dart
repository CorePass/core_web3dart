import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:web3dart_example/tests/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = CarouselController();
  int _active = 0;
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Web3 tests"),
      ),
      body: Material(
        child: Container(
          height: _height,
          width: _width,
          child: CarouselSlider.builder(
            carouselController: _controller,
            options: CarouselOptions(
              height: _height,
              aspectRatio: 1,
              viewportFraction: 1,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 10),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _active = index;
                });
              },
            ),
            itemCount: tests.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) =>
                    Padding(
              padding: const EdgeInsets.all(30.0),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: _width,
                    height: _height,
                    child: Center(
                        child: ListView(
                      children: [
                        Text(
                          tests[itemIndex].name,
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                        ...tests[itemIndex].data.map((e) => e).toList()
                      ],
                    )),
                  ),
                  Positioned(
                      bottom: 0,
                      child: Row(
                        children: tests
                            .map((e) => Container(
                                  height: 10,
                                  width: 10,
                                  margin: const EdgeInsets.only(left: 5),
                                  color: itemIndex == _active
                                      ? Colors.black
                                      : Colors.grey,
                                ))
                            .toList(),
                      ))
                ],
              ),
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
