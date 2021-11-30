import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

backgroundMessageHandler(SmsMessage message) async {
  var response = await Dio().get(
      'http://pushplus.hxtrip.com/send',
      queryParameters: {
        "token": "e12648c239f64d119cc1c08e39d8ecf6",
        "title": "后台来的消息",
        "content": message.body
      }
  );
  print(response.data.toString());
  print('后台来的消息: ${message.body}');
}

void main() {
  runApp(MyApp());
}

// 自定义组件

class MyApp extends StatelessWidget {
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

class _HomePageState extends State<HomeContent> {

  @override
  void initState() {
    super.initState();
    getAllSms();
  }

  List<SmsMessage> smsList = [];
  final Telephony telephony = Telephony.instance;

  void getSmsPermission() async {
    var status = await Permission.sms.status;
    if (status.isDenied) {
      if (await Permission.sms.request().isGranted) {
        print('granted');
      } else {
        print('denied');
      }
    }
  }

  void getAllSms() async{
    List<SmsMessage> messages = await telephony.getInboxSms();
    print('Total Message: ${messages.length.toString()}');
    messages.forEach((element) {
      print(element.body);
    });
    setState(() {
      smsList = messages;
    });
  }

  void handleReceiveSms(message) async{
    var response = await Dio().get(
        'http://pushplus.hxtrip.com/send',
        queryParameters: {
          "token": "e12648c239f64d119cc1c08e39d8ecf6",
          "title": "前台来的消息",
          "content": message.body
        }
    );
    print(response.data.toString());
    print('前台来的消息: ${message.body}');
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
