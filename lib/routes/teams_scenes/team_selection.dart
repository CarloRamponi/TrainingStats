/*
 *
 * Training Stats: mobile app that helps collecting data during
 * trainings of team sports.
 * Copyright (C) 2020 Carlo Ramponi, magocarlos1999@gmail.com
  * This program is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
  * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
  * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:training_stats/datatypes/team.dart';

class SelectTeam extends StatelessWidget {

  SelectTeam() : teams = TeamProvider.getAll();

  final Future<List<Team>> teams;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a team"),
      ),
      body: FutureBuilder(
        future: teams,
        builder: (context, AsyncSnapshot<List<Team>> snap) {
          if(snap.hasData) {
            if(snap.data.length > 0) {
              return ListView.separated(
                  itemBuilder: (context, index) {
                    Team t = snap.data[index];
                    return ListTile(
                      title: Text(t.teamName),
                      subtitle: FutureBuilder(
                        builder: (context, playersSnap) {
                          if (playersSnap.hasData) {
                            if (playersSnap.data.length > 0) {
                              return Text(playersSnap.data.map((p) => p.name).toList().join(", "),
                                  overflow: TextOverflow.ellipsis);
                            } else {
                              return Text('No players added yet',
                                  overflow: TextOverflow.ellipsis);
                            }
                          } else {
                            return Container(
                              height: 10.0,
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  right: MediaQuery.of(context).size.width / 4.0),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.4))
                            );
                          }
                        },
                        future: TeamProvider.getPlayers(t.id),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(t);
                      },
                    );
                  },
                  separatorBuilder: (_, __) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Divider(),
                  ),
                  itemCount: snap.data.length
              );
            } else {
              return Center(
                child: Text("You shoud first create a team!"),
              );
            }
          } else {
            return ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Container(
                      height: 10.0,
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width / 2.0),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.6)),
                      child: null,
                    ),
                    subtitle: Container(
                      height: 10.0,
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width / 4.0),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4)),
                      child: null,
                    ),
                  );
                },
                separatorBuilder: (_, __) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(),
                ),
                itemCount: 3);
          }
        },
      )
    );
  }

}