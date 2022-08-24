import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

const token = "801cd6939d594813a15f2d1d28c4b58b";

backgroundMessageHandler(SmsMessage message) async {
  var response = await Dio().get(
      'http://www.pushplus.plus/send',
      queryParameters: {
        "token": token,
        "title": "后台来的消息",
        "content": message.body
      }
  );
  debugPrint(response.data.toString());
  debugPrint('后台来的消息: ${message.body}');
}

void main() {
  runApp(const MyApp());
}

// 自定义组件

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('信息检测上报')),
        body: HomeContent(),
      ),
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomeContent> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    getAllSms();
    // 监听生命周期
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      getAllSms();
    }
  }

  List<SmsMessage> smsList = [];
  final Telephony telephony = Telephony.instance;

  void getSmsPermission() async {
    var status = await Permission.sms.status;
    if (status.isDenied) {
      if (await Permission.sms.request().isGranted) {
        debugPrint('granted');
      } else {
        debugPrint('denied');
      }
    }
  }

  void getAllSms() async{
    List<SmsMessage> messages = await telephony.getInboxSms();
    debugPrint('Total Message: ${messages.length.toString()}');
    for (var element in messages) {
      debugPrint(element.body);
    }
    setState(() {
      smsList = messages;
    });
  }

  void handleReceiveSms(message) async{
    var response = await Dio().get(
        'http://www.pushplus.plus/send',
        queryParameters: {
          "token": token,
          "title": "前台来的消息",
          "content": message.body
        }
    );
    debugPrint(response.data.toString());
    debugPrint('前台来的消息: ${message.body}');
    // 刷新 state
    getAllSms();
  }

  @override
  Widget build(BuildContext context) {

    getSmsPermission();

    telephony.listenIncomingSms(
        onNewMessage: handleReceiveSms,
        onBackgroundMessage: backgroundMessageHandler
    );

    return ListView.builder(
      itemCount: smsList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(smsList[index].address.toString()),
          subtitle: Text(smsList[index].body ?? ''),
        );
      },
    );
  }

}
