import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class QuestEfficiencyTab extends StatefulWidget {
  final GLPKSolution? solution;

  const QuestEfficiencyTab({Key? key, required this.solution})
      : super(key: key);

  @override
  _QuestEfficiencyTabState createState() => _QuestEfficiencyTabState();
}

class _QuestEfficiencyTabState extends State<QuestEfficiencyTab> {
  late ScrollController _scrollController;

  Set<String> allItems = {};
  Set<String> filterItems = {};
  bool matchAll = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    allItems.clear();
    widget.solution?.weightVars.forEach((variable) {
      variable.detail.forEach((key, value) {
        if (value > 0) {
          allItems.add(key);
        }
      });
    });
    filterItems.removeWhere((element) => !allItems.contains(element));

    List<Widget> children = [];
    widget.solution?.weightVars.forEach((variable) {
      final String questKey = variable.name;
      final Map<String, double> drops = variable.detail as Map<String, double>;
      final Quest? quest = db.gameData.freeQuests[questKey];
      if (filterItems.isEmpty ||
          (matchAll &&
              filterItems.every((e) => variable.detail.containsKey(e))) ||
          (!matchAll &&
              filterItems.any((e) => variable.detail.containsKey(e)))) {
        children.add(Container(
          decoration: BoxDecoration(
              border: Border(bottom: Divider.createBorderSide(context))),
          child: ValueStatefulBuilder<bool>(
            initValue: false,
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomTile(
                    title: Text(quest?.localizedKey ??
                        Quest.getDailyQuestName(questKey)),
                    subtitle: buildRichText(drops.entries),
                    trailing: Text(sum(drops.values).toStringAsFixed(3)),
                    onTap: quest == null
                        ? null
                        : () {
                            state.value = !state.value;
                            state.updateState();
                          },
                  ),
                  if (state.value && quest != null) QuestCard(quest: quest),
                ],
              );
            },
          ),
        ));
      }
    });
    return Column(
      children: [
        ListTile(
          title: Text(S.of(context).quest),
          trailing: Text(S.of(context).efficiency),
        ),
        kDefaultDivider,
        Expanded(
            child: ListView(controller: _scrollController, children: children)),
        kDefaultDivider,
        _buildButtonBar(),
      ],
    );
  }

  Widget buildRichText(Iterable<MapEntry<String, double>> entries) {
    List<InlineSpan> children = [];
    for (final entry in entries) {
      String v = entry.value.toStringAsFixed(3);
      while (v.contains('.') && v[v.length - 1] == '0') {
        v = v.substring(0, v.length - 1);
      }
      children.add(WidgetSpan(
        child: Opacity(
          opacity: 0.75,
          child: db.getIconImage(entry.key, height: 18),
        ),
      ));
      children.add(TextSpan(text: '*$v '));
    }
    final textTheme = Theme.of(context).textTheme;
    return RichText(
      text: TextSpan(
        children: children,
        style: textTheme.bodyText2?.copyWith(color: textTheme.caption?.color),
      ),
    );
  }

  Widget _buildButtonBar() {
    double height = Theme.of(context).iconTheme.size ?? 48;
    List<String> items = Item.sortListById(allItems.toList());
    List<Widget> children = [];
    items.forEach((itemKey) {
      children.add(GestureDetector(
        onTap: () {
          setState(() {
            if (filterItems.contains(itemKey))
              filterItems.remove(itemKey);
            else
              filterItems.add(itemKey);
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              db.getIconImage(itemKey, height: height),
              if (filterItems.contains(itemKey))
                Icon(Icons.circle, size: height * 0.53, color: Colors.white),
              if (filterItems.contains(itemKey))
                Icon(Icons.check_circle,
                    size: height * 0.5,
                    color: Theme.of(context).colorScheme.primary)
            ],
          ),
        ),
      ));
    });
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(matchAll ? Icons.add_box : Icons.add_box_outlined),
          color: Theme.of(context).buttonTheme.colorScheme?.secondary,
          tooltip: matchAll ? 'Contains All' : 'Contains Any',
          onPressed: () {
            setState(() {
              matchAll = !matchAll;
            });
          },
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            height: height,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: children,
            ),
          ),
        )
      ],
    );
  }
}
