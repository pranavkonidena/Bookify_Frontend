import 'dart:convert';
import 'package:book_my_spot_frontend/src/constants/constants.dart';
import 'package:book_my_spot_frontend/src/services/providers.dart';
import 'package:book_my_spot_frontend/src/state/user/user_state.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../../models/user.dart';

var finalTeams = [];

final _slotsProvider = FutureProvider<dynamic>((ref) async {
  var response = await http.get(Uri.parse("${using}amenity/getAll"));
  dynamic data = response.body;
  data = jsonDecode(response.body.toString());
  return data;
});

class MakeReservationPage extends ConsumerWidget {
  const MakeReservationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 18, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Amenities",
                      style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const SlotsListWidget(),
              const SizedBox(
                height: 30,
              ),
              Text("Events", style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(
                height: 30,
              ),
              const EventsLister(),
            ],
          ),
        ),
      ),
    );
  }
}

class SlotsListWidget extends ConsumerWidget {
  const SlotsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_slotsProvider);
    return data.when(
      data: (value) {
        if ((value as List).isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 18.0),
            child: Text(
              "Please check after some time",
              style: TextStyle(
                fontFamily: "Thasadith",
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 30,
              );
            },
            shrinkWrap: true,
            itemCount: value.length,
            itemBuilder: (context, index) {
              return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 130,
                  color: const Color.fromRGBO(247, 230, 196, 1),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                              "https://github-production-user-asset-6210df.s3.amazonaws.com/122373207/275466089-4e5a891c-8afd-4e9b-a0da-04ff0c39687c.png",
                              height: 30)
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              value[index]["name"],
                              style: const TextStyle(
                                color: Color(0xFF606C5D),
                                fontSize: 30,
                                fontFamily: 'Thasadith',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              value[index]["venue"],
                              style: const TextStyle(
                                color: Color(0xFF606C5D),
                                fontSize: 15,
                                fontFamily: 'Thasadith',
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ]),
                    ),
                    const VerticalDivider(
                      color: Color(0xFF606C5D),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context.go("/new/${value[index]["id"]}");
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB8DCE7)),
                        child: Text("Book Now",
                            style: Theme.of(context).textTheme.displayMedium),
                      ),
                    )
                  ]));
            },
          );
        }
      },
      error: (error, stackTrace) {
        return const SizedBox();
      },
      loading: () => const SpinKitFadingCircle(
        color: Color(0xff0E6BA8),
        size: 50.0,
      ),
    );
  }
}

final eventsProvider = FutureProvider<dynamic>((ref) async {
  var response = await http.get(Uri.parse("${using}event/getAll"));
  var data = jsonDecode(response.body.toString());
  return data;
});

class EventsLister extends ConsumerWidget {
  const EventsLister({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(eventsProvider);
    return data.when(
      data: (value) {
        return value.length != 0
            ? GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 5,
                  mainAxisExtent: MediaQuery.of(context).size.height / 4,
                ),
                shrinkWrap: true,
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    child: FlipCard(
                      direction: FlipDirection.HORIZONTAL,
                      autoFlipDuration: const Duration(seconds: 5),
                      front: Card(
                          color: Theme.of(context).secondaryHeaderColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.black)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(value[index]["name"])),
                          )),
                      back: Card(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            side: BorderSide(color: Colors.black)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(DateTime.parse(value[index]
                                              ["time_of_occourence_start"])
                                          .day
                                          .toString()),
                                      Text(months[DateTime.parse(value[index]
                                              ["time_of_occourence_start"])
                                          .month]!),
                                      Text(DateTime.parse(value[index]
                                              ["time_of_occourence_start"])
                                          .year
                                          .toString()),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_right_outlined),
                                  Column(
                                    children: [
                                      Text(DateTime.parse(value[index]
                                              ["time_of_occourence_end"])
                                          .day
                                          .toString()),
                                      Text(months[DateTime.parse(value[index]
                                              ["time_of_occourence_end"])
                                          .month]!),
                                      Text(DateTime.parse(value[index]
                                              ["time_of_occourence_end"])
                                          .year
                                          .toString()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  if (context.mounted) {
                                    ref
                                        .read(selectedEventProvider.notifier)
                                        .state = value[index]["id"];
                                    ref
                                        .read(finalTeamsProvider.notifier)
                                        .state = [];
                                    User? user = ref.watch(userProvider);
                                    var teamsasAdmin = await http.get(Uri.parse(
                                        "${using}teamasadmin?id=${user!.token}"));
                                    var teams = jsonDecode(teamsasAdmin.body);
                                    finalTeams.clear();
                                    for (int i = 0; i < teams.length; i++) {
                                      if (!value[index]["team"]
                                          .contains(teams[i]["id"])) {
                                        finalTeams.add(teams[i]);
                                      }
                                    }
                                    ref
                                        .read(finalTeamsProvider.notifier)
                                        .state = finalTeams;
                                    Future.microtask(
                                        () => context.go("/event/book"));
                                  }
                                },
                                child: Container(
                                  color: Theme.of(context).primaryColor,
                                  child: Center(
                                      child: Text(
                                    "Book Now",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  )),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : Center(
                child: Text("No Upcoming events found!",
                    style: Theme.of(context).textTheme.displayMedium),
              );
      },
      error: (error, stackTrace) {
        return const SizedBox();
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
