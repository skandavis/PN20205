import 'package:NagaratharEvents/createNotificationButton.dart';
import 'package:NagaratharEvents/loadingScreen.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:NagaratharEvents/notificationBubble.dart';
import 'utils.dart' as utils;
import 'package:NagaratharEvents/notification.dart';

class notificationsPage extends StatefulWidget {
  final ValueNotifier<int> isVisible;
  const notificationsPage({super.key, required this.isVisible});

  @override
  State<notificationsPage> createState() => _notificationsPageState();
}

class _notificationsPageState extends State<notificationsPage> {
  ScrollController scrollController = ScrollController();
  static List<Notification>? messages;
  static Set<String> newMessageIds = {};
  User user = User.instance;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    widget.isVisible.addListener(_onVisibilityChanged);
  }

  @override
  void dispose() {
    widget.isVisible.removeListener(_onVisibilityChanged);
    super.dispose();
  }

  void _onVisibilityChanged() {
    if (widget.isVisible.value == 1) {
      loadMessages();
    } else if(widget.isVisible.value == 0){
      clearMessages();
    }
  }

  void clearMessages() {
    messages = null;
  }

  void loadMessages() {
    NetworkService().getMultipleRoute('notifications').then((value) {
      if (value == null) return;
      setState(() {
        messages = value.map((item) => Notification.fromJson(item)).toList();
      });
    });
  }

  void sendMessage(Response response) async {
    if(response.statusCode != 200) return;
    final newNotification = Notification.fromJson(response.data);
    setState(() {
      if(messages == null){
        messages = [newNotification];
      }else{
        messages!.add(newNotification);
      }
      newMessageIds.add(newNotification.id); // Mark as new
    });
  }

  void loadNewMessages() async{
    final fetched = await NetworkService().getMultipleRoute('notifications', forceRefresh: true);
    if (fetched == null) return;

    final fetchedList = fetched
        .map((item) => Notification.fromJson(item))
        .toList();

    final currentIds = messages!.map((m) => m.id).toSet();
    final newOnes = fetchedList
        .where((f) => !currentIds.contains(f.id))
        .toList();

    setState(() {
      newMessageIds.clear();
      newMessageIds.addAll(newOnes.map((n) => n.id));
      messages = fetchedList;
    });

    if (newOnes.isNotEmpty) {
      utils.snackBarMessage(
        "${newOnes.length} new message${newOnes.length > 1 ? 's' : ''}",
        color: Colors.blue,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        messages!=null ? Container(
          height: MediaQuery.sizeOf(context).height,
          padding: const EdgeInsets.all(20),
          child: RefreshIndicator(
            onRefresh: () async {
              loadNewMessages();
            },
            child: ListView.builder(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: messages!.length,
              itemBuilder: (context, index) {
                index = messages!.length - index - 1;
                final message = messages!.toList()[index];
                final isNew = newMessageIds.contains(message.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: notificationBubble(
                    newMessage: isNew,
                    notification: message,
                    delete: () async {
                      setState(() {
                        isLoading = true;
                      });
                      final response = await NetworkService().deleteRoute('notifications/${messages![index].id}');
                      setState(() {
                        isLoading = false;
                      });
                      if(response.statusCode != 200) return;
                      setState(() {
                        messages!.removeAt(index);
                        newMessageIds.remove(message.id);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ):loadingScreen(),
        if (user.isAdmin)
        Positioned(
          bottom: 25,
          right:25,
          child: createNotificationButton(sendMessage: sendMessage,route: 'notifications',),
        ),
        if(isLoading)
        Container(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          color: Colors.black45,
          child: Center(
            child: const CircularProgressIndicator(color: Colors.white,)
          ),
        )
      ],
    );
  }
}