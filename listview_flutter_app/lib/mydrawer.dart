import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        // DrawerHeader consumes top MediaQuery padding.
        removeTop: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 38.0),
              child: Column(
                children: <Widget>[
                  Center(
                    //padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipOval(
                      child: Image.asset(
                        "images/flower.png",
                        //width: 100,
                        height: 150,
                      ),
                    ),
                  ),
                  Text(
                    "Shawn",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "快乐学习版",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.assignment),
                    title: const Text('随机开始'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.assessment),
                    title: const Text('最新开始'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
