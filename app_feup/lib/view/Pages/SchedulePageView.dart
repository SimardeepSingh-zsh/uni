import 'package:app_feup/model/entities/Lecture.dart';
import 'package:app_feup/view/Widgets/PageTitle.dart';
import 'package:app_feup/view/Widgets/RequestDependentWidgetBuilder.dart';
import 'package:flutter/material.dart';
import '../Pages/SecondaryPageView.dart';
import 'package:app_feup/model/AppState.dart';
import 'package:app_feup/view/Widgets/ScheduleSlot.dart';
import 'package:flutter_redux/flutter_redux.dart';


class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey),
        ),
      ),
      constraints: BoxConstraints(maxHeight: 150.0),
      child: new Material(
        color: Colors.white,
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class SchedulePageView extends SecondaryPageView  {

  SchedulePageView(
    {Key key,
      @required this.tabController,
      @required this.scrollViewController,
      @required this.daysOfTheWeek,
      @required this.aggLectures});

  final List<String> daysOfTheWeek;
  final List<List<Lecture>> aggLectures;
  final TabController tabController;
  final ScrollController scrollViewController;

  @override
  Widget getBody(BuildContext context) {
    final MediaQueryData queryData = MediaQuery.of(context);
    Color labelColor = Color.fromARGB(255, 0x50, 0x50, 0x50);

    return new Column(
      children: <Widget>[
        new PageTitle(name: 'Schedule'),
        new Expanded(
          child: 
              NestedScrollView(
                controller: scrollViewController,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget> [
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        new TabBar(
                          controller: tabController,
                          isScrollable: true,
                          unselectedLabelColor: labelColor,
                          labelColor: labelColor,
                          indicatorWeight: 3.0,
                          indicatorColor: Theme.of(context).primaryColor,
                          labelPadding: EdgeInsets.all(0.0),
                          tabs: createTabs(queryData, context),
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                }, body: new TabBarView(
                controller: tabController,
                children: createSchedule(context),
              ),
              ),
        ),
      ],
    );
  }

  List<Widget> createTabs(queryData, BuildContext context) {
    List<Widget> tabs = List<Widget>();
    for( var i = 0; i < daysOfTheWeek.length; i++) {
      tabs.add(
          new Container(
            color: Theme.of(context).backgroundColor,
            width:  queryData.size.width * 1/3,
            child: new Tab(text: daysOfTheWeek[i]),
          )
      );
    }
    return tabs;
  }

  List<Widget> createSchedule(context) {
    List<Widget> tabBarViewContent = List<Widget>();
    for(int i = 0; i < daysOfTheWeek.length; i++) {
      tabBarViewContent.add(createScheduleByDay(context, i));
    }
    return tabBarViewContent;
  }

  List<Widget> createScheduleRows(lectures, BuildContext context){
    List<Widget> scheduleContent = List<Widget>();
    for(int i = 0; i < lectures.length; i++) {
      Lecture lecture = lectures[i];
      scheduleContent.add(new ScheduleSlot(
      subject: lecture.subject,
      typeClass: lecture.typeClass,
      rooms: lecture.room,
      begin: lecture.startTime,
      end: lecture.endTime,
      teacher: lecture.teacher,
      ));
    }
    return scheduleContent;
  }

  Widget createDayColumn(dayContent, BuildContext context) {
    return Container(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: createScheduleRows(dayContent, context),
                )
    );
  }

  Widget createScheduleByDay(BuildContext context, day) {
    return StoreConnector<AppState, RequestStatus>(
      converter: (store) => store.state.content['scheduleStatus'],
      builder: (context, status) => RequestDependentWidgetBuilder(
          context: context,
          status: status,
          contentGenerator: createDayColumn,
          content: aggLectures[day],
          contentChecker: aggLectures[day].length >= 1,
          onNullContent: Center(child: Text("Não possui aulas à " + daysOfTheWeek[day] + ".")),
        )
    );
  }
}