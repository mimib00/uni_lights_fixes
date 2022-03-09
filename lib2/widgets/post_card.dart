import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/data_manager.dart';
import 'package:uni_lights/models/post.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/profile_image.dart';
import 'package:uni_lights/widgets/uni_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({
    required this.post,
    Key? key,
  }) : super(key: key);

  // final TextEditingController controller = TextEditingController();

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController controller = TextEditingController();
  String name = '';
  String image = '';
  String light = "";
  getPostOwnerName() async {
    var ref = await FirebaseFirestore.instance.collection("users").doc(widget.post.ownerId).get();
    var data = ref.data()!;
    if (mounted) {
      setState(() {
        name = data['name'];
        image = data['photo_url'];
        light = data["light"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPostOwnerName();
  }

  @override
  Widget build(BuildContext context) {
    var user = context.read<Authentication>().user!;
    bool liked = widget.post.likes.where((e) => e == user.uid).isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ProfileImage(
              image: image,
              width: 55,
              height: 55,
              status: light,
            ),
            const SizedBox(width: 8),
            Text(
              name != "" ? name : "Uni User",
              style: const TextStyle(fontSize: 16, fontFamily: "Roboto", fontWeight: FontWeight.w500),
            )
          ],
        ),
        Container(
          width: kWidth(context),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          padding: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
          decoration: BoxDecoration(
            color: kPostBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: kGreyColor3,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case "report":
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feature coming soon.'),
                              backgroundColor: Colors.black,
                            ),
                          );
                          break;
                        case "delete":
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Center(
                                child: Text("Warning!"),
                              ),
                              titleTextStyle: const TextStyle(color: Colors.red, fontSize: 28),
                              content: const Text("Are you sure you want to delete this post permanently?"),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                OutlinedButton(
                                  onPressed: () {
                                    context.read<DataManager>().deletePost(widget.post.id!);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Yes"),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("No"),
                                )
                              ],
                            ),
                          );
                          break;
                        default:
                      }
                    },
                    tooltip: "More",
                    itemBuilder: (context) => [
                      user.uid != widget.post.ownerId
                          ? const PopupMenuItem(
                              child: Text(
                                'Report',
                              ),
                              value: "report",
                            )
                          : const PopupMenuItem(
                              child: Text(
                                'Delete',
                              ),
                              value: "delete",
                            ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(widget.post.caption),
                ],
              ),
              const SizedBox(height: 10),
              //Images
              Visibility(
                visible: widget.post.attachment.isNotEmpty,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.post.attachment,
                    height: 300,
                    width: kWidth(context),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //Tags
              Visibility(
                visible: widget.post.tags.isNotEmpty,
                child: Row(
                  children: widget.post.tags
                      .map(
                        (e) => Text(
                          "#$e  ",
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w300,
                            color: kGreyColor3,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Leave a comment...",
                    hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 14, color: kGreyColor3),
                  ),
                  onSubmitted: (value) {
                    widget.post.postComment(user, value);
                    controller.clear();
                  },
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Wrap(
                    spacing: 10.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      MyText(
                        text: widget.post.likes.length,
                        size: 10,
                        weight: FontWeight.w500,
                        color: liked ? kRedColor : kGreyColor,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (liked) {
                            widget.post.unlike(user);
                            setState(() {
                              liked = !liked;
                            });
                          } else {
                            widget.post.like(user);
                            setState(() {
                              liked = !liked;
                            });
                          }
                        },
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? kRedColor : kGreyColor,
                        ),
                      ),
                      MyText(
                        text: widget.post.comments.length,
                        size: 10,
                        weight: FontWeight.w500,
                        color: kGreyColor,
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) {
                              return UniBottomSheet(
                                title: "Comments",
                                content: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                  stream: context.read<DataManager>().comments(widget.post.id!),
                                  builder: (_, snapshot) {
                                    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.none:
                                        return const Text('No data');
                                      case ConnectionState.waiting:
                                        return const Text('Loading...');
                                      case ConnectionState.active:
                                        var data = snapshot.data!.data()!;
                                        if (data.isNotEmpty) {
                                          var comment = data["comments"];

                                          return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: data["comments"].length,
                                            physics: const BouncingScrollPhysics(),
                                            primary: true,
                                            itemBuilder: (_, index) {
                                              return Comments(
                                                comment: comment[index],
                                                post: widget.post,
                                              );
                                            },
                                          );
                                        } else {
                                          return Container();
                                        }
                                      case ConnectionState.done:
                                        var data = snapshot.data!.data()!;
                                        if (data.isNotEmpty) {
                                          var comment = data["comments"];

                                          return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: data["comments"].length,
                                            physics: const BouncingScrollPhysics(),
                                            primary: true,
                                            itemBuilder: (_, index) {
                                              return Comments(
                                                comment: comment[index],
                                                post: widget.post,
                                              );
                                            },
                                          );
                                        } else {
                                          return Container();
                                        }
                                      default:
                                        return Container();
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(
                          Icons.messenger,
                          color: kGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Comments extends StatelessWidget {
  final Map<String, dynamic> comment;
  final Post post;

  const Comments({
    Key? key,
    required this.comment,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isOwner = comment["owner_id"] == context.read<Authentication>().user!.uid;
    Timestamp time = comment["created_at"];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: kLightGreyColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(comment["owner_name"]),
            Text(
              "${time.toDate().year}-${time.toDate().month}-${time.toDate().day}",
              style: const TextStyle(color: kGreyColor3, fontSize: 10),
            ),
          ],
        ),
        subtitle: Text(comment["comment"]),
        trailing: Visibility(
          visible: isOwner,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              post.deleteComment(comment);
            },
          ),
        ),
      ),
    );
  }
}
