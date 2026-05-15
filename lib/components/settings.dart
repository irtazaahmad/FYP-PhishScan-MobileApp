import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/sms_controller.dart';
import '../main.dart';
import '../provider/setting_provider.dart';
import '../provider/user_provider.dart';
import 'Bottom.dart';

final pushNotificationProvider = StateProvider<bool>((ref) => true);
final emailNotificationProvider = StateProvider<bool>((ref) => false);
final permissionProvider = StateProvider<bool>((ref) => false);
final notificationToggleProvider = StateProvider<bool>((ref) => true);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png", height: 30,color: Colors.black,),
            const Text(
              'Phish Scan',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(width: 27,)
          ],
        ),
        elevation: 0,
        leading: Container(),
        centerTitle: true,
        bottom: PreferredSize( preferredSize: const Size.fromHeight(0),
            child: Divider(
                color: Colors.grey
            )),
      ),      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: Text("Setting", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Row(
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? "No Name",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "@${user?.username ?? "No Username"}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () => _showEditDialog(context, ref, user),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Notifications",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSwitchTile(
              "Push Notifications",
              "Alerts About Phishing Messages",
              ref,
              pushNotificationProvider,
              Colors.purple,
            ),
       ] ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildSwitchTile(
      String title,
      String subtitle,
      WidgetRef ref,
      StateProvider<bool> provider,
      Color activeColor,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Switch(
            value: ref.watch(notificationPermissionProvider),
            onChanged: (bool newValue) async {
              if (newValue) {
                await requestNotificationPermission(ref); // Request permission if enabling
              } else {
                ref.read(notificationPermissionProvider.notifier).state = false; // Disable manually
              }
              ref.read(smsProvider.notifier).toggleNotifications(newValue);
            },
            activeColor: activeColor,
          ),

        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, User? user) {
    TextEditingController nameController = TextEditingController();
    TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name", hintText: "Kamran Ali", hintStyle: TextStyle(color: Colors.grey))),
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: "Username", hintText: "@KamranAli", hintStyle: TextStyle(color: Colors.grey))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(userProvider.notifier).updateUser(nameController.text, usernameController.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
