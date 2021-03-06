import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vsongbook/utils/colors.dart';
import 'package:vsongbook/utils/constants.dart';
import 'package:vsongbook/views/as_favorites.dart';
import 'package:vsongbook/views/as_search_songs.dart';
import 'package:vsongbook/views/as_song_pad.dart';
import 'package:vsongbook/models/song_model.dart';
import 'package:vsongbook/helpers/app_database.dart';
import 'package:vsongbook/helpers/app_search_delegate.dart';
import 'package:vsongbook/widgets/as_nav_drawer.dart';

class DdHomeView extends StatefulWidget {
  final String bookstr;
  DdHomeView(this.bookstr);

  @override
  State<StatefulWidget> createState() {
    return DdHomeViewState(this.bookstr);
  }
}

class DdHomeViewState extends State<DdHomeView> {
  DdHomeViewState(this.bookstr);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _lastIntegerSelected;
  AsNavDrawer navDrawer;
  String bookstr;

  AppDatabase db = AppDatabase();
  List<SongModel> songList;
	int count = 0;

  void updateSongList() {
    final Future<Database> dbFuture = db.initializeDatabase();
    dbFuture.then((database) {
      Future<List<SongModel>> songListFuture = db.getSongList(0);
      songListFuture.then((songList) {
        setState(() {
          this.songList = songList;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (songList == null) {
      songList = List<SongModel>();
      updateSongList();
    }

    var books = this.bookstr.split(",");
    AsSearchSongs home = AsSearchSongs.getList(int.parse(books[0]));
    AsFavorites likes = AsFavorites();
    AsSongPad drafts = AsSongPad();
    
    final appPages = <Widget>[
      Center(child: home),
      Center(child: likes),
      Center(child: drafts),
    ];

    final appTabs = <Tab>[
      Tab(text: 'HOME'),
      Tab(text: 'LIKES'),
      Tab(text: 'DRAFTS'),
    ];

    if (navDrawer == null) navDrawer = AsNavDrawer();

    return DefaultTabController(
      length: appTabs.length,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: new IconThemeData(color: ColorUtils.white),
          title: const Text(LangStrings.appName),
          bottom: TabBar(tabs: appTabs),
          actions: <Widget>[
            IconButton(
              tooltip: LangStrings.SearchNow,
              icon: const Icon(Icons.search),
              onPressed: () async {
                final List selected = await showSearch(
                  context: context,
                  delegate: AppSearchDelegate(context, songList),
                );
                if ((selected != null) && (selected.isNotEmpty)) {
                  setState(() {
                    //query = selected;
                  });
                }
              },
            ),
            
            IconButton(
              icon: Icon(
                Theme.of(context).platform == TargetPlatform.iOS ? Icons.more_horiz : Icons.more_vert,
              ),
              onPressed: () { },
            ),
          ],
        ),
        body: TabBarView(children: appPages),
        drawer: Drawer(child: navDrawer),
      ),
    );
  }
}
