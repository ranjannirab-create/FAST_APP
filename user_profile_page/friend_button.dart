
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

class FriendButton extends StatelessWidget {
  final String targetUserId;
  const FriendButton({super.key, required this.targetUserId});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    const Color primaryColor = Color(0xFF2FA089); // আপনার অ্যাপের গ্রিন পেস্ট কালার

    return StreamBuilder<DocumentSnapshot>(
      stream: db.getRequestStatus(targetUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 44,
            child: Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }

        String? status;
        if (snapshot.hasData && snapshot.data!.exists) {
          status = (snapshot.data!.data() as Map<String, dynamic>?)?['status'];
        }

        // =========================================================
        // ১. কোনো রিকোয়েস্ট নেই (status == null) -> Show Add Friend
        // =========================================================
        if (status == null) {
          return ElevatedButton.icon(
            icon: const Icon(Icons.person_add_alt_1_outlined, size: 18, color: primaryColor),
            label: const Text('Add Friend', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              side: BorderSide(color: primaryColor.withOpacity(0.6), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                await db.sendFriendRequest(targetUserId, friendType: '');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request sent ✉️')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          );
        }

        // =========================================================
        // ২. পেন্ডিং রিকোয়েস্ট (status == 'pending')
        // =========================================================
        if (status == 'pending') {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final isSender = data['senderId'] == FirebaseAuth.instance.currentUser?.uid;

          if (isSender) {
            // আমি রিকোয়েস্ট পাঠিয়েছি -> Cancel Request বাটন
            return OutlinedButton.icon(
              icon: const Icon(Icons.close_rounded, size: 18, color: primaryColor),
              label: const Text('Cancel Request', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                side: BorderSide(color: primaryColor.withOpacity(0.6), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                try {
                  await db.cancelFriendRequest(targetUserId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request cancelled')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            );
          } else {
            // অন্য কেউ রিকোয়েস্ট পাঠিয়েছে -> Accept / Decline বাটন (পাশাপাশি)
            return Row(
              children: [
                // Accept Button
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      label: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, // সলিড গ্রিন পেস্ট ব্যাকগ্রাউন্ড
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await db.acceptFriendRequest(targetUserId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Friend added 🎉')),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Decline Button
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close_rounded, size: 16, color: primaryColor),
                      label: const Text('Decline', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        side: BorderSide(color: primaryColor.withOpacity(0.6), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await db.declineFriendRequest(targetUserId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request declined')),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        }

        // =========================================================
        // ৩. অলরেডি ফ্রেন্ড (status == 'accepted') -> সলিড গ্রিন পেস্ট ও আনফ্রেন্ড লজিক
        // =========================================================
        if (status == 'accepted') {
          return ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
            label: const Text('Friends', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor, // সবুজের বদলে আপনার গ্রিন পেস্ট কালার
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // ফ্রেন্ড কাটার পপ-আপ ডায়ালগ ওপেন হবে
              _showUnfriendDialog(context, db, primaryColor);
            },
          );
        }

        // =========================================================
        // ৪. রিকোয়েস্ট ডিক্লাইনড থাকলে আবার Add Friend দেখাবে
        // =========================================================
        if (status == 'declined') {
          return ElevatedButton.icon(
            icon: const Icon(Icons.person_add_alt_1_outlined, size: 18, color: primaryColor),
            label: const Text('Add Friend', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              side: BorderSide(color: primaryColor.withOpacity(0.6), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await db.sendFriendRequest(targetUserId, friendType: '');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New request sent')),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  // =========================================================
  // ফ্রেন্ড কাটার (Unfriend) প্রিমিয়াম অ্যালার্ট ডায়ালগ
  // =========================================================
  void _showUnfriendDialog(BuildContext context, DatabaseService db, Color primaryColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Unfriend?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          content: const Text(
            "Are you sure you want to remove this user from your friends list?",
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Unfriend",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.pop(context); // ডায়ালগ বন্ধ হবে
                try {
                  // ফ্রেন্ড কানেকশন কাটতে ফায়ারবেসের ক্যানসেল মেথডটিকেই ব্যবহার করা হলো
                  await db.cancelFriendRequest(targetUserId); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from friends list ❌')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}