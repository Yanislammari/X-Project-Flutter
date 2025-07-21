import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/blocs/user_data_bloc/user_data_bloc.dart';
import 'package:x_project_flutter/screens/home_screen.dart';
import 'package:x_project_flutter/screens/search_screen.dart';
import 'package:x_project_flutter/screens/notifications_screen.dart';
import 'package:x_project_flutter/screens/messages_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:x_project_flutter/core/repositories/user_data/user_repository.dart';
import 'core/models/user.dart';
import 'screens/profile_screen.dart';
import 'core/repositories/user_data/firebase_user_data_source.dart';
import 'globals.dart';
import 'package:x_project_flutter/core/blocs/notification_bloc/notification_bloc.dart';
import 'package:x_project_flutter/core/blocs/notification_bloc/notification_state.dart';
import 'package:x_project_flutter/core/blocs/notification_bloc/notification_event.dart';
import 'package:x_project_flutter/core/repositories/notification/notification_repository.dart';
import 'core/models/notification.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  final Set<String> _seenNotificationIds = {};
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    context.read<UserDataBloc>().add(UserDataFetch());
    _screens = [
      const HomeScreen(),
      const SearchScreen(),
      const NotificationsScreen(),
      const MessagesScreen(),
    ];
  }

  String getDynamicTitle(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return "Home";
      case 1:
        return "Search";
      case 2:
        return "Notifications";
      case 3:
        return "Messages";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return BlocProvider(
      create: (_) => NotificationBloc(notificationRepository: NotificationRepository())
        ..add(ListenNotifications(user!.uid)),
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationLoaded && state.notifications.isNotEmpty) {
            final user = FirebaseAuth.instance.currentUser;
            if (!_initialLoadDone) {
              _seenNotificationIds.addAll(state.notifications.map((n) => n.id));
              _initialLoadDone = true;
              return;
            }
            for (final notif in state.notifications) {
              if (notif.toUserId == user?.uid && _currentIndex != 2 && !_seenNotificationIds.contains(notif.id)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vous avez reçu une notification')),
                );
                _seenNotificationIds.add(notif.id);
              }
            }
          }
        },
        child: _buildScaffold(context, user),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, User? user) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          getDynamicTitle(_currentIndex),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (user?.uid != null)
            FutureBuilder(
              future: UserRepository(userDataSource: FirebaseUserDataSource()).getUserById(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CircleAvatar(radius: 18, backgroundColor: Colors.grey),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox(width: 36);
                }
                final firebaseUser = snapshot.data as FirebaseUser;
                final imageUrl = firebaseUser.imagePath;
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(userId: user!.uid),
                      ),
                    );
                    if (result == 'refresh') {
                      shouldRefetchTweets.value = true;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                          ? NetworkImage(imageUrl)
                          : null,
                      backgroundColor: Colors.grey[900],
                      child: (imageUrl == null || imageUrl.isEmpty)
                          ? const Icon(Icons.person, size: 18, color: Colors.white)
                          : null,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          bool hasUnread = false;
          if (state is NotificationLoaded) {
            hasUnread = state.hasUnread;
          }
          return Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white54,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined, size: 24),
                      activeIcon: Icon(Icons.home, size: 24),
                      label: "Home",
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.search_outlined, size: 24),
                      activeIcon: Icon(Icons.search, size: 24),
                      label: "Search",
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(
                        children: [
                          const Icon(Icons.notifications_outlined, size: 24),
                          if (hasUnread)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      activeIcon: Stack(
                        children: [
                          const Icon(Icons.notifications, size: 24),
                          if (hasUnread)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      label: "Notifications",
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.mail_outline, size: 24),
                      activeIcon: Icon(Icons.mail, size: 24),
                      label: "Messages",
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 