import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../src/core/providers/auth.dart';
import '../../constant.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    required this.authProvider,
  }) : super(key: key);

  final AuthProvider authProvider;

  @override
  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      backgroundColor: chatRoomBackgroundColor,
      elevation: 0.0,
      title: Container(
        padding: const EdgeInsets.only(left: 6),
        child: Text(
          "Contacts",
          style: TextStyle(
            color: chatRoomColor,
            fontSize: 20,
            fontFamily: primaryFontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 3.5),
      //     child: TextButton(
      //       onPressed: () {
      //         authProvider.logout();
      //       },
      //       child: Text(
      //         "LOG OUT ${authProvider.getUser.full_name}",
      //         style: TextStyle(
      //             fontSize: 14.0,
      //             fontFamily: primaryFontFamily,
      //             fontStyle: FontStyle.normal,
      //             fontWeight: FontWeight.w700,
      //             color: logoutButtonColor,
      //             letterSpacing: 0.90),
      //       ),
      //     ),
      //   ),
      //   //       //SvgPicture.asset('assets/plus.svg',
      //   //       // height: 15.26,
      //   //       // width: 15.26,
      //   //       //),
      //   //       //Image.asset('assets/plus.png'),
      //   //       // const Icon(
      //   //       //   Icons.add,
      //   //       //   size: 24,
      //   //       //   color: chatRoomColor,
      //   //       // ),

      //   //       // onPressed: () {
      //   //       //     Navigator.pushNamed(context, '/creategroup',
      //   //       //     arguments: groupListProvider);
      //   //       // },
      //   //     ),
      // ]
    );
  }
}
