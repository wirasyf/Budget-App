import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: appWhiteDark,
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: appPrimary,
                      child: IconButton(
                        icon: Icon(Icons.person, size: 50, color: appWhite),
                        onPressed: () {
                          //
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Username",
                            style: TextStyle(fontSize: 14, color: appGrey),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Wirawrr",
                            style: TextStyle(
                              fontSize: 22,
                              color: appBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.edit, size: 38, color: appPrimary),
                          onPressed: () {
                            //
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: appWhite,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: appVioletSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.color_lens, size: 40, color: appPrimary),
                              onPressed: () {
                                //
                              },
                            ),
                          ),
                          SizedBox(width: 5),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Theme",
                              style: TextStyle(
                                fontSize: 20,
                                color: appBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    //Export Data Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: appVioletSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_upward_rounded, size: 40, color: appPrimary),
                              onPressed: () {
                                //
                              },
                            ),
                          ),
                          SizedBox(width: 5),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Export Data",
                              style: TextStyle(
                                fontSize: 20,
                                color: appBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Import Data Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: appVioletSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_downward_outlined, size: 40, color: appPrimary),
                              onPressed: () {
                                //
                              },
                            ),
                          ),
                          SizedBox(width: 5),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Import Data",
                              style: TextStyle(
                                fontSize: 20,
                                color: appBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    //Lougout Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: appBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.logout, size: 40, color: appPrimary),
                              onPressed: () {
                                //
                              },
                            ),
                          ),
                          SizedBox(width: 5),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Log Out",
                              style: TextStyle(
                                fontSize: 20,
                                color: appBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
