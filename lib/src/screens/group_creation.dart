import 'dart:convert';

import 'package:book_my_spot_frontend/src/screens/check_slots.dart';
import 'package:book_my_spot_frontend/src/screens/teams_detail.dart';
import 'package:book_my_spot_frontend/src/screens/teams_page.dart';
import 'package:book_my_spot_frontend/src/services/storageManager.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

final groupselectedProvider = StateProvider<List<Map>>((ref) {
  List<Map> l = [];
  return l;
});

final currentStringProvider = StateProvider<String>((ref) {
  return "";
});

final filtereditemsProvider = StateProvider<List<Map>>((ref) {
  return ref.read(itemsProvider);
});

final itemsProvider = StateProvider<List<Map>>((ref) {
  List<Map> l = [];
  return l;
});

final usersAllProvider = FutureProvider<dynamic>((ref) async {
  var response = await http.get(Uri.parse(using + "user"));
  var data = jsonDecode(response.body.toString());
  for (int i = 0; i < data.length; i++) {
    var entry = {};
    entry["name"] = data[i]["name"];
    entry["dp"] = data[i]["profile_pic"];
    entry["id"] = data[i]["id"];
    if (entry["id"] != getToken()) {
      ref.read(itemsProvider.notifier).state.add(entry);
    }
  }

  return data;
});

class GroupCreatePage extends ConsumerStatefulWidget {
  GroupCreatePage(this.fallbackRoute, {super.key});
  String fallbackRoute;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupCreatePageState();
}

class _GroupCreatePageState extends ConsumerState<GroupCreatePage> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(usersAllProvider);
    return data.when(
      data: (data) {
        return Scaffold(
            appBar: AppBar(
              toolbarHeight: MediaQuery.of(context).size.height / 12,
              elevation: 0,
              backgroundColor: const Color.fromARGB(168, 35, 187, 233),
              leading: IconButton(
                  onPressed: () {
                    ref.refresh(currentStringProvider);
                    ref.refresh(filtereditemsProvider);
                    ref.refresh(groupselectedProvider);
                    context.go(widget.fallbackRoute);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey[700],
                  )),
              title: Text(
                "Add Participants",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontFamily: 'Thasadith',
                  fontWeight: FontWeight.w400,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: TextButton(
                      onPressed: () async {
                        if (widget.fallbackRoute.contains('/checkSlots')) {
                          SnackBar snackBarNew = const SnackBar(
                              content:
                                  Text("Group must have atleast 2 members"));
                          if (ref
                                  .read(groupselectedProvider.notifier)
                                  .state
                                  .length <
                              2) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBarNew);
                          } else {
                            context.go("/grpbooking");
                          }
                        } else if (widget.fallbackRoute
                            .contains("teamDetails")) {
                          var id = ref.watch(teamIDProvider);
                          var response = await http
                              .get(Uri.parse(using + "team/i?id=$id"));
                          var data = jsonDecode(response.body.toString());
                          var team_name = data[0]["name"];
                          for (int i = 0;
                              i <
                                  ref
                                      .watch(groupselectedProvider.notifier)
                                      .state
                                      .length;
                              i++) {
                            var entry = ref.watch(groupselectedProvider)[i];
                            var member_id = entry["id"];
                            var admin = entry["admin"];

                            var post_data = {
                              "id": getToken(),
                              "name": team_name,
                              "member_id": member_id,
                              "admin": admin,
                            };

                            var response = await http.post(
                                Uri.parse(using + "team/add"),
                                body: post_data);
                            var data = jsonDecode(response.body.toString());
                            print(data);
                           
                          }
                           ref.refresh(groupselectedProvider);
                            ref.refresh(teamdetailsProvider);
                          context.go("/teamDetails$id");
                        }
                      },
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Thasadith',
                          fontWeight: FontWeight.w400,
                          height: 0.05,
                        ),
                      )),
                )
              ],
            ),
            body: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Search name",
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    var all_players = ref.read(itemsProvider);
                    List<Map> filtered_players = [];

                    if (value.isEmpty) {
                      filtered_players = all_players;
                    } else {
                      filtered_players = all_players
                          .where((element) => element["name"]
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    }
                    ref.read(filtereditemsProvider.notifier).state =
                        filtered_players;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                Visibility(
                    visible: ref
                            .watch(groupselectedProvider.notifier)
                            .state
                            .length !=
                        0,
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: [
                        for (int i = 0;
                            i <
                                ref
                                    .read(groupselectedProvider.notifier)
                                    .state
                                    .length;
                            i++)
                          ref
                                  .read(groupselectedProvider.notifier)
                                  .state[i]["dp"]
                                  .contains("github")
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image.network(
                                        ref
                                            .read(
                                                groupselectedProvider.notifier)
                                            .state[i]["dp"],
                                        height: 56,
                                        width: 56,
                                      ),
                                      Text(ref.read(groupselectedProvider)[i]
                                          ["name"])
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        clipBehavior: Clip.antiAlias,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.network(
                                          "https://channeli.in" +
                                              ref
                                                  .read(groupselectedProvider
                                                      .notifier)
                                                  .state[i]["dp"],
                                          height: 56,
                                          width: 56,
                                        ),
                                      ),
                                      Text(ref.read(groupselectedProvider)[i]
                                          ["name"])
                                    ],
                                  ),
                                )
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: ref.watch(filtereditemsProvider).length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              if (widget.fallbackRoute.contains("checkSlots")) {
                                var entry = {};
                                entry["name"] = ref
                                    .read(filtereditemsProvider)[index]["name"];
                                entry["dp"] = ref
                                    .read(filtereditemsProvider)[index]["dp"];
                                entry["id"] = ref
                                    .read(filtereditemsProvider.notifier)
                                    .state[index]["id"];
                                bool isNamePresent = ref
                                    .read(groupselectedProvider)
                                    .any((map) => map['name'] == entry["name"]);
                                if (isNamePresent) {
                                  ref
                                      .read(groupselectedProvider.notifier)
                                      .state
                                      .removeWhere((map) =>
                                          map["name"] == entry["name"]);
                                } else {
                                  ref
                                      .read(groupselectedProvider.notifier)
                                      .state
                                      .add(entry);
                                }
                                setState(() {});
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Visibility(
                                      visible: true,
                                      child: Dialog(
                                        child: Container(
                                            height: 100,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text("Select Role"),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          var entry = {};
                                                          entry[
                                                              "name"] = ref.read(
                                                                  filtereditemsProvider)[
                                                              index]["name"];
                                                          entry[
                                                              "dp"] = ref.read(
                                                                  filtereditemsProvider)[
                                                              index]["dp"];
                                                          entry["id"] = ref
                                                              .read(
                                                                  filtereditemsProvider
                                                                      .notifier)
                                                              .state[index]["id"];
                                                          entry["admin"] =
                                                              "True";
                                                          bool isNamePresent = ref
                                                              .read(
                                                                  groupselectedProvider)
                                                              .any((map) =>
                                                                  map['name'] ==
                                                                  entry[
                                                                      "name"]);
                                                          if (isNamePresent) {
                                                            ref
                                                                .read(groupselectedProvider
                                                                    .notifier)
                                                                .state
                                                                .removeWhere((map) =>
                                                                    map["name"] ==
                                                                    entry[
                                                                        "name"]);
                                                          } else {
                                                            ref
                                                                .read(groupselectedProvider
                                                                    .notifier)
                                                                .state
                                                                .add(entry);
                                                          }

                                                          Navigator.of(context)
                                                              .pop();
                                                          setState(() {});
                                                        },
                                                        child: Text("Admin")),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          var entry = {};
                                                          entry[
                                                              "name"] = ref.read(
                                                                  filtereditemsProvider)[
                                                              index]["name"];
                                                          entry[
                                                              "dp"] = ref.read(
                                                                  filtereditemsProvider)[
                                                              index]["dp"];
                                                          entry["id"] = ref
                                                              .read(
                                                                  filtereditemsProvider
                                                                      .notifier)
                                                              .state[index]["id"];
                                                          entry["admin"] =
                                                              "False";
                                                          bool isNamePresent = ref
                                                              .read(
                                                                  groupselectedProvider)
                                                              .any((map) =>
                                                                  map['name'] ==
                                                                  entry[
                                                                      "name"]);
                                                          if (isNamePresent) {
                                                            ref
                                                                .read(groupselectedProvider
                                                                    .notifier)
                                                                .state
                                                                .removeWhere((map) =>
                                                                    map["name"] ==
                                                                    entry[
                                                                        "name"]);
                                                          } else {
                                                            ref
                                                                .read(groupselectedProvider
                                                                    .notifier)
                                                                .state
                                                                .add(entry);
                                                          }

                                                          setState(() {});
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("Member"))
                                                  ],
                                                )
                                              ],
                                            )),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ref
                                        .watch(filtereditemsProvider)[index]
                                            ["dp"]
                                        .contains("github")
                                    ? Image.network(
                                        ref.watch(filtereditemsProvider)[index]
                                            ["dp"],
                                        height: 56,
                                        width: 56,
                                      )
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.network(
                                          "https://channeli.in" +
                                              ref.watch(filtereditemsProvider)[
                                                  index]["dp"],
                                        ),
                                      ),
                              ],
                            ),
                            title: Row(
                              children: [
                                Text(ref.watch(filtereditemsProvider)[index]
                                    ["name"]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ))
              ],
            ));
      },
      error: (error, stackTrace) {
        return SizedBox();
      },
      loading: () {
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}