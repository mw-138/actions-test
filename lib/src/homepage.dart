import 'package:auto_update/auto_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<dynamic, dynamic> _packageUpdateUrl = {};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void _openUpdateDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Update Available'),
              content: const Text('There is a new update available!'),
              actions: [
                MaterialButton(
                    child: const Text('Update'),
                    onPressed: () async {
                      await AutoUpdate.downloadAndUpdate(
                          _packageUpdateUrl['assetUrl']);
                    })
              ]);
        });
  }

  Future<void> initPlatformState() async {
    Map<dynamic, dynamic> updateUrl;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      updateUrl = await AutoUpdate.fetchGithub('mw-138', 'actions-test');
    } on PlatformException {
      updateUrl = {'assetUrl': 'Failed to get the url of the new release.'};
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() async {
      _packageUpdateUrl = updateUrl;

      if (_packageUpdateUrl['assetUrl'] == '') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("App is up-to-date"),
        ));
      } else if (_packageUpdateUrl['assetUrl'].isEmpty()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Package or user not found"),
        ));
      } else {
        _openUpdateDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Action Test'),
        actions: [
          IconButton(
              onPressed: initPlatformState, icon: const Icon(Icons.update))
        ],
      ),
      drawer: Drawer(),
      body: SafeArea(
          child: Container(
        height: 150,
        color: Theme.of(context).colorScheme.primaryContainer,
      )),
    );
  }
}
