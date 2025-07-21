import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/blocs/notification_bloc/notification_bloc.dart';
import '../core/blocs/notification_bloc/notification_event.dart';
import '../core/blocs/notification_bloc/notification_state.dart';
import '../core/repositories/notification/notification_repository.dart';
import '../widget/notification_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return BlocProvider(
      create: (_) => NotificationBloc(notificationRepository: NotificationRepository())
        ..add(ListenNotifications(user!.uid)),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(child: Text('Aucune notification', style: TextStyle(color: Colors.white70)));
              }
              return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  return NotificationWidget(notification: state.notifications[index]);
                },
              );
            } else if (state is NotificationError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
} 