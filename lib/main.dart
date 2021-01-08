import 'dart:async';
import 'dart:math';

import 'package:firework_counter/Particle.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Color> colors = [

    Colors.yellowAccent,
    Colors.deepPurple,
    Colors.orangeAccent,
    Colors.blue,
    Colors.deepOrangeAccent,
    Colors.pinkAccent
  ];
  final GlobalKey _boxKey = GlobalKey();
  final Random random = new Random();
  dynamic counterText = {'count': 1, 'color': Colors.yellow};
  Rect boxSize = Rect.zero;
  List<Particle> particles = [];
  final double fps = 1/60;
  Timer timer;
  final double gravity = 9.81, dragCof = 0.47, airDensity = 1.1644;


  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Size size = _boxKey.currentContext.size;
      boxSize = Rect.fromLTRB(0, 0, size.width, size.height);

    });
    timer = Timer.periodic(Duration(milliseconds: (fps*1000).floor()), frameBuilder);
    super.initState();
  }

  frameBuilder(dynamic timer){
    particles.forEach((pt) {
      double dragForceX = 0.5 * airDensity * pow(pt.velocity.x, 2) * dragCof * pt.area;
      double dragForceY = 0.5 * airDensity * pow(pt.velocity.y, 2) * dragCof * pt.area;

      // Handle infinity case
      dragForceX = dragForceX.isInfinite ? 0.0 : dragForceX;
      dragForceY = dragForceY.isInfinite ? 0.0 : dragForceY;

      double accX = dragForceX/pt.mass;
      double accY = dragForceY/pt.mass + gravity;

      pt.velocity.x += accX * fps;
      pt.velocity.y += accY * fps;

      pt.position.x += pt.velocity.x * fps * 100;
      pt.position.y += pt.velocity.y *fps * 100;
      boxCollision(pt);
    });

    setState(() {

    });
  }

  boxCollision(Particle pt){
    if(pt.position.x > boxSize.width - pt.radius){
      pt.position.x = boxSize.width - pt.radius;
      pt.velocity.x *= pt.jumpFactor;
    }
    if(pt.position.x < pt.radius){
      pt.position.x = pt.radius;
      pt.velocity.x *= pt.jumpFactor;
    }

    if(pt.position.y > boxSize.height - pt.radius){
      pt.position.y = boxSize.height - pt.radius;
      pt.velocity.y *= pt.jumpFactor;
    }
  }

  burstParticle() {
    if(particles.length > 200){
      particles.removeRange(0, 75);
    }
    Color color = colors[random.nextInt(colors.length)];
    counterText['color'] = color;
    counterText['count'] = counterText['count'] + 1;

    int count = random.nextInt(25).clamp(7, 25);
    for(int x = 0; x < count; x++){
      Particle p = new Particle();
      p.position = PVector(boxSize.center.dx, boxSize.center.dy);
      double randomX = random.nextDouble() * 4.0;
      if(x%2 == 0){
        randomX = -randomX;
      }
      double randomY = random.nextDouble() * -7.0;
      p.velocity = PVector(randomX, randomY);
      p.radius = (random.nextDouble() * 10.0).clamp(2.0 , 10.0);
      p.color = color;
      particles.add(p);
    }
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: counterText['color'],
        title: Text("Animated counter"),
      ),
      body: Container(
        key: _boxKey,
        child: Stack(
          children: [
            Center(
              child: Text(
                "${counterText['count']}",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: counterText['color']
                ),
              ),
            ),
            ...particles.map((pt) => Positioned(
              top: pt.position.y,
              left: pt.position.x,
              child: Container(
                width: pt.radius * 2,
                height: pt.radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pt.color
                ),
              ),
            )).toList()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: burstParticle,
        tooltip: 'Increment',
        backgroundColor: counterText['color'],
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
