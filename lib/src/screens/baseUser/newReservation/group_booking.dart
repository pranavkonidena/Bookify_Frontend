// ignore_for_file: unused_result

import 'dart:convert';
import 'package:book_my_spot_frontend/src/screens/baseUser/newReservation/check_slots.dart';
import 'package:book_my_spot_frontend/src/screens/baseUser/newReservation/confirm_booking.dart';
import 'package:book_my_spot_frontend/src/screens/baseUser/newReservation/group_creation.dart';
import 'package:book_my_spot_frontend/src/services/storage_manager.dart';
import 'package:book_my_spot_frontend/src/state/bookings/booking_state.dart';
import 'package:book_my_spot_frontend/src/state/navbar/navbar_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../constants/constants.dart';

final groupNameProvider = StateProvider<String>((ref) {
  return "";
});

class GroupBookingFinalPage extends ConsumerWidget {
  const GroupBookingFinalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupName = ref.watch(groupNameProvider);
    final date = ref.watch(selectedDateProvider);
    final data = ref.watch(slotsProviderAmenity);
    var initialPostData = {
      "date": "${date.year}-${date.month}-${date.day}",
      "amenity_id": data[0]["amenity_id"].toString(),
      "start_time": data[ref.read(indexProvider)]["start_time"].toString(),
      "end_time": data[ref.read(indexProvider)]["end_time"].toString(),
    };
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 12,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              ref.refresh(groupNameProvider);
              context.go("/grpcreate/checkSlots");
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color,
            )),
        backgroundColor: const Color.fromARGB(168, 35, 187, 233),
        title: const Text(
          "New Group  ",
          style: TextStyle(
            color: Colors.black,
            fontSize: 40,
            fontFamily: 'Thasadith',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                List grpMembers = [];
                for (int i = 0;
                    i < ref.read(groupselectedProvider.notifier).state.length;
                    i++) {
                  var id = ref.read(groupselectedProvider)[i]["id"];
                  debugPrint(id);
                  grpMembers.add(id);
                }
                debugPrint(grpMembers.toString());
                grpMembers.add(StorageManager.getToken().toString());
                var groupData = {
                  "name": groupName,
                  "id": jsonEncode(grpMembers).toString(),
                };
                debugPrint(groupData.toString());
                var groupResponse = await http
                    .post(Uri.parse("${using}group/add"), body: groupData);
                var grpId = jsonDecode(groupResponse.body.toString());
                debugPrint(data.toString());
                initialPostData["group_id"] = grpId.toString();
                var response = await http.post(
                    Uri.parse("${using}booking/group/bookSlot"),
                    body: initialPostData);
                if (response.statusCode == 200) {
                  ref.refresh(groupNameProvider);
                  ref.refresh(groupselectedProvider);
                  ref.refresh(userBookingsProvider);
                  ref.refresh(currentIndexProvider);
                  Future.microtask(() => context.go("/"));
                }
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 3.0),
                child: Text(
                  "Reserve",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontFamily: 'Thasadith',
                  ),
                ),
              ))
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration:
                const InputDecoration(label: Center(child: Text("Enter group name"))),
            onChanged: (value) {
              ref.read(groupNameProvider.notifier).state = value;
            },
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
