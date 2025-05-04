import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harmoni/services/emotion_store.dart';
import 'package:harmoni/services/user_store.dart';
import 'package:harmoni/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  void initState() {
    // Fetch emotions when the widget is initialized
    Provider.of<EmotionStore>(context, listen: false).getEmotions();

    // Fetch user data if user is logged in
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      Provider.of<UserStore>(context, listen: false)
          .fetchUser(firebaseUser.uid);
    }
    super.initState();
  }

  // Map to translate emotions names to emojis
  Map<String, String> emotions = {
    'joy': '\u{1F600}',
    'sadness': '\u{1F614}',
    'anger': '\u{1F621}',
    'love': '\u{1F60D}',
    'surprise': '\u{1F62E}',
    'fear': '\u{1F628}'
  };

  // Currently selected day in the calendar, defaults to today
  DateTime _selectedDay = DateTime.now();

// Currently focused day, changes when the user navigates between months
  DateTime _focusedDay = DateTime.now();

  // Filter and map emotions for a specific day
  List<Map<String, dynamic>> _getEmojisForDay(DateTime day, List userEmotions) {
    return userEmotions
        .where((emotion) =>
            emotion.date.year == day.year &&
            emotion.date.month == day.month &&
            emotion.date.day == day.day)
        .map<Map<String, dynamic>>((emotion) =>
            {'date': emotion.date, 'emoji': emotions[emotion.name] ?? ''})
        .toList();
  }

  // Build visual representation of a single day cell
  Widget _buildDailyCell(
      {required DateTime day,
      required bool isSelected,
      required List<String> emojis,
      required VoidCallback? onEmojiTap}) {
    // Get the most recent emoji for the day if any
    final String? latestEmoji = emojis.isNotEmpty ? emojis.last : null;

    // Style for the day, changes based on whether the day is selected
    final TextStyle dayNumberStyle = TextStyle(
        color: isSelected ? AppColors.offWhite : AppColors.darkGray,
        fontSize: 16,
        fontWeight: FontWeight.bold);

    // Content of day cell
    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${day.day}', style: dayNumberStyle),
        if (latestEmoji != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              latestEmoji,
              style: const TextStyle(fontSize: 26),
            ),
          )
      ],
    );

    // Container for day cell
    return Container(
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            color: isSelected ? AppColors.mainColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0)),
        // Make the cell tappable
        child: InkWell(
          onTap: isSelected && latestEmoji != null ? onEmojiTap : null,
          borderRadius: BorderRadius.circular(8.0),
          child: Center(child: content),
        ));
  }

  // Dialog displaying all the emotions for a specific day
  void _showEmotionDialog(List<Map<String, dynamic>> dayEmotions) {
    // Sort emotions by date in desc order
    dayEmotions.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Emotions for this day'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dayEmotions.map((e) {
                final time = (e['date'] as DateTime);
                final formattedTime = DateFormat('HH:mm').format(time);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '$formattedTime: ${e['emoji']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              }).toList(),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Close'),
                child: const Text('Close'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // Consumer widget to listen for changes in EmotionStore
    return Consumer<EmotionStore>(builder: (context, emotionStore, child) {
      // Get list of emotions from EmotionStore
      final userEmotions = emotionStore.emotions;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Calendar'),
        ),
        body: Center(
          child: TableCalendar(
            rowHeight: 90,
            daysOfWeekHeight: 30,
            calendarFormat: CalendarFormat.month,
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2022, 12, 31),
            lastDay: DateTime.utc(2050, 12, 31),

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },

            onPageChanged: (focusedDay) => _focusedDay = focusedDay,

            calendarBuilders: CalendarBuilders(
              // Builder for the default calendar day cells
              defaultBuilder: (context, day, _focusedDay) {
                final dayEmotions = _getEmojisForDay(day, userEmotions);
                return _buildDailyCell(
                    day: day,
                    isSelected: false,
                    emojis:
                        dayEmotions.map((e) => e['emoji'] as String).toList(),
                    onEmojiTap: null);
              },
              // Builder for the selected day
              selectedBuilder: (context, day, _focusedDay) {
                final dayEmotions = _getEmojisForDay(day, userEmotions);
                return _buildDailyCell(
                    day: day,
                    isSelected: true,
                    emojis:
                        dayEmotions.map((e) => e['emoji'] as String).toList(),
                    onEmojiTap: dayEmotions.isEmpty
                        ? null
                        : () => _showEmotionDialog(dayEmotions));
              },
            ),
            // Styling calendar header
            headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left,
                    color: Theme.of(context).primaryColor),
                rightChevronIcon: Icon(Icons.chevron_right,
                    color: Theme.of(context).primaryColor)),
            // Styling weekday labels
            daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.darkGray)),
          ),
        ),
      );
    });
  }
}
