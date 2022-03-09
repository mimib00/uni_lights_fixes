import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_app_bar.dart';
import 'package:uni_lights/widgets/my_text.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    Users user = context.read<Authentication>().user!;

    return Scaffold(
      appBar: const MyAppBar(
        haveBackButton: true,
      ),
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        children: [
          Center(
            child: Image.asset(
              'assets/images/rafiki.png',
              height: 163,
            ),
          ),
          MyText(
            paddingTop: 20.0,
            align: TextAlign.center,
            text: 'Manage your settings'.toUpperCase(),
            size: 14,
            fontFamily: 'Roboto Mono',
            weight: FontWeight.w700,
            color: kDarkGreyColor,
          ),
          const SizedBox(height: 30),
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: kLightGreyColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyText(
                  text: 'Personal info',
                  size: 14,
                  weight: FontWeight.w500,
                  color: kDarkGreyColor,
                ),
                GestureDetector(
                  onTap: () {
                    TextEditingController controller = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Change Your Name"),
                        content: SizedBox(
                          height: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Current Name: ${user.name!}",
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: "New Name",
                                ),
                                textCapitalization: TextCapitalization.words,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (controller.text.isEmpty) {
                                Navigator.of(context).pop();
                                return;
                              }
                              var ref = FirebaseFirestore.instance.collection("users").doc(user.uid!);
                              var _chatroom = FirebaseFirestore.instance.collection('chatroom');
                              var _products = FirebaseFirestore.instance.collection('products');

                              Map<String, dynamic> data = {
                                "name": controller.text.trim()
                              };
                              ref.update(data);
                              _chatroom
                                  .where(
                                    "users",
                                    arrayContains: {
                                      "id": user.uid!,
                                      "name": user.name!,
                                      "photo_url": user.photoURL!,
                                      "light": user.light,
                                    },
                                  )
                                  .get()
                                  .then(
                                    (snap) {
                                      for (var doc in snap.docs) {
                                        List users = doc.data()["users"];
                                        users.removeWhere((element) => element['id'] == user.uid!);
                                        users.add(
                                          {
                                            "id": user.uid!,
                                            "name": controller.text.trim(),
                                            "photo_url": user.photoURL!,
                                            "light": user.light,
                                          },
                                        );
                                        _chatroom.doc(doc.id).update(
                                          {
                                            "users": users
                                          },
                                        );
                                      }
                                    },
                                  );

                              _products
                                  .where("owner", isEqualTo: {
                                    "id": user.uid!,
                                    "name": user.name!,
                                    "photo_url": user.photoURL!,
                                    "university": user.university!,
                                  })
                                  .get()
                                  .then(
                                    (snap) {
                                      for (var doc in snap.docs) {
                                        _products.doc(doc.id).update(
                                          {
                                            "owner": {
                                              "id": user.uid!,
                                              "name": controller.text.trim(),
                                              "photo_url": user.photoURL!,
                                              "university": user.university!,
                                            },
                                          },
                                        );
                                      }
                                    },
                                  );
                              context.read<Authentication>().getUserData();
                              Navigator.pop(context);
                            },
                            child: const Text("Change"),
                          )
                        ],
                      ),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                        text: 'Name',
                        size: 12,
                        color: kGreyColor,
                      ),
                      Image.asset(
                        'assets/images/arrow_right.png',
                        height: 20,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    TextEditingController controller = TextEditingController();
                    TextEditingController password = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Change Your Email"),
                        content: SizedBox(
                          height: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Current Email: ${user.email!}",
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: "New Email",
                                ),
                                keyboardType: TextInputType.emailAddress,
                                // textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: password,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: "Password",
                                ),
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                // textCapitalization: TextCapitalization.words,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              if (controller.text.isEmpty || controller.text == user.email!) {
                                Navigator.of(context).pop();
                                return;
                              }
                              UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: user.email!, password: password.text.trim());

                              credential.user!.updateEmail(controller.text.trim());

                              var ref = FirebaseFirestore.instance.collection("users").doc(user.uid!);

                              Map<String, dynamic> data = {
                                "email": controller.text.trim()
                              };

                              ref.update(data);
                              context.read<Authentication>().getUserData();
                              Navigator.pop(context);
                            },
                            child: const Text("Change"),
                          )
                        ],
                      ),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                        text: 'Email',
                        size: 12,
                        color: kGreyColor,
                      ),
                      Image.asset(
                        'assets/images/arrow_right.png',
                        height: 20,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    DateTime? bDate;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Change Your Birthday"),
                        content: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "New Birthday",
                          ),
                          onTap: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1995),
                              lastDate: DateTime(2050),
                            ).then((value) {
                              bDate = value;
                            });
                          },
                          readOnly: true,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (bDate == null) {
                                Navigator.of(context).pop();
                                return;
                              }
                              Timestamp date = Timestamp.fromDate(bDate!);

                              var ref = FirebaseFirestore.instance.collection("users").doc(user.uid!);
                              Map<String, dynamic> data = {
                                "birth_day": date
                              };
                              ref.update(data);
                              context.read<Authentication>().getUserData();
                              Navigator.pop(context);
                            },
                            child: const Text("Change"),
                          )
                        ],
                      ),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                        text: 'Birth date',
                        size: 12,
                        color: kGreyColor,
                      ),
                      Image.asset(
                        'assets/images/arrow_right.png',
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 135,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: kLightGreyColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyText(
                  text: 'University',
                  size: 14,
                  weight: FontWeight.w500,
                  color: kDarkGreyColor,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/carbon_location-filled-red.png',
                          height: 14,
                        ),
                        MyText(
                          paddingLeft: 10.0,
                          text: user.university!,
                          size: 12,
                          color: kGreyColor,
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/images/ic_sharp-verified.png',
                      height: 20,
                    ),
                  ],
                ),
                MyText(
                  paddingTop: 5.0,
                  text: 'Add a new university',
                  size: 10,
                  weight: FontWeight.w600,
                  color: kRedColor,
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        TextEditingController controller = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Chnage Your Course"),
                            content: SizedBox(
                              height: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Current Course: ${user.courseName!}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      hintText: "New Course",
                                    ),
                                    textCapitalization: TextCapitalization.sentences,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (controller.text.isEmpty) {
                                    Navigator.of(context).pop();
                                    return;
                                  }
                                  var ref = FirebaseFirestore.instance.collection("users").doc(user.uid!);

                                  Map<String, dynamic> data = {
                                    "course_name": controller.text.trim()
                                  };
                                  ref.update(data).then((value) {
                                    context.read<Authentication>().getUserData();
                                    Navigator.pop(context);
                                  });
                                },
                                child: const Text("Change"),
                              )
                            ],
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                            text: 'Course',
                            size: 12,
                            color: kGreyColor,
                          ),
                          Image.asset(
                            'assets/images/arrow_right.png',
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ChangeYear(),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                            text: 'Year of Study',
                            size: 12,
                            color: kGreyColor,
                          ),
                          Image.asset(
                            'assets/images/arrow_right.png',
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: kLightGreyColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyText(
                  text: 'Details',
                  size: 14,
                  weight: FontWeight.w500,
                  color: kDarkGreyColor,
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ChangeLight(),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                            text: 'My Light',
                            size: 12,
                            color: kGreyColor,
                          ),
                          Image.asset(
                            'assets/images/arrow_right.png',
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ChangeIntersts(),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                            text: 'Interested in',
                            size: 12,
                            color: kGreyColor,
                          ),
                          Image.asset(
                            'assets/images/arrow_right.png',
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              TextEditingController controller = TextEditingController();
              TextEditingController password = TextEditingController();
              TextEditingController _password = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Chnage Your Password"),
                  content: SizedBox(
                    height: 212,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Current Password",
                          ),
                          keyboardType: TextInputType.emailAddress,
                          obscureText: true,
                          // textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: password,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "New Password",
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          // textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _password,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Confirm new Password",
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          // textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        if (controller.text.isEmpty || password.text.isEmpty || _password.text.isEmpty) {
                          Navigator.of(context).pop();
                          return;
                        }
                        if (password.text != _password.text) {
                          Navigator.of(context).pop();
                          return;
                        }

                        UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: user.email!, password: controller.text.trim());

                        credential.user!.updatePassword(password.text.trim()).then((value) => Navigator.pop(context));
                      },
                      child: const Text("Change"),
                    )
                  ],
                ),
              );
            },
            child: RichText(
              textAlign: TextAlign.start,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: kGreyColor,
                  fontFamily: 'Poppins',
                ),
                children: [
                  TextSpan(
                    text: 'Do you have any doubts about your password safety? If so, please ',
                  ),
                  TextSpan(
                    text: 'change your password',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kRedColor,
                    ),
                  ),
                  TextSpan(
                    text: '!',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class ChangeYear extends StatefulWidget {
  const ChangeYear({Key? key}) : super(key: key);

  @override
  _ChangeYearState createState() => _ChangeYearState();
}

class _ChangeYearState extends State<ChangeYear> {
  String current = yearOfStudy[0];
  @override
  Widget build(BuildContext context) {
    Users user = context.read<Authentication>().user!;
    return AlertDialog(
      title: const Text("Change Your Year"),
      content: DropdownButton<String>(
        value: current,
        items: yearOfStudy
            .map(
              (e) => DropdownMenuItem<String>(
                child: Text(e),
                value: e,
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            current = value!;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            var ref = FirebaseFirestore.instance.collection("users").doc(user.uid!);

            Map<String, dynamic> data = {
              "year": current
            };
            ref.update(data).then((value) {
              context.read<Authentication>().getUserData();
              Navigator.pop(context);
            });
          },
          child: const Text("Change"),
        )
      ],
    );
  }
}

class ChangeLight extends StatefulWidget {
  const ChangeLight({Key? key}) : super(key: key);

  @override
  _ChangeLightState createState() => _ChangeLightState();
}

class _ChangeLightState extends State<ChangeLight> {
  String current = light[0];
  @override
  Widget build(BuildContext context) {
    Users user = context.read<Authentication>().user!;
    return AlertDialog(
      title: const Text("Change Your Light"),
      content: DropdownButton<String>(
        value: current,
        items: light
            .map(
              (e) => DropdownMenuItem<String>(
                child: Text(e),
                value: e,
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            current = value!;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            var ref = FirebaseFirestore.instance.collection("users").doc(user.uid!);

            Map<String, dynamic> data = {
              "light": current
            };
            ref.update(data).then((value) {
              context.read<Authentication>().getUserData();
              Navigator.pop(context);
            });
          },
          child: const Text("Change"),
        )
      ],
    );
  }
}

class ChangeIntersts extends StatefulWidget {
  const ChangeIntersts({Key? key}) : super(key: key);

  @override
  _ChangeInterstsState createState() => _ChangeInterstsState();
}

class _ChangeInterstsState extends State<ChangeIntersts> {
  String current = '';
  @override
  Widget build(BuildContext context) {
    Users user = context.watch<Authentication>().user!;

    return AlertDialog(
      title: const Text("Change Interested In"),
      content: DropdownButton<String>(
        value: current == '' ? user.intrestedIn! : current,
        items: interestedIn
            .map(
              (e) => DropdownMenuItem<String>(
                child: Text(e),
                value: e,
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            current = value!;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            var ref = FirebaseFirestore.instance.collection("users").doc(user.uid!);

            Map<String, dynamic> data = {
              "intrested_in": current
            };
            ref.update(data).then((value) {
              context.read<Authentication>().getUserData();
              Navigator.pop(context);
            });
          },
          child: const Text("Change"),
        )
      ],
    );
  }
}
