import 'package:chaldea/components/components.dart';

import 'filter_page.dart';

class ProfileLangSwitch extends StatefulWidget {
  final Language? primary;
  final ValueChanged<Language> onChanged;
  final bool showCn;
  final bool showJp;
  final bool showEn;

  const ProfileLangSwitch({
    Key? key,
    required this.primary,
    required this.onChanged,
    this.showCn = true,
    this.showJp = true,
    this.showEn = true,
  })  : assert(showCn || showJp || showEn, 'At least show one language'),
        super(key: key);

  @override
  _ProfileLangSwitchState createState() => _ProfileLangSwitchState();
}

class _ProfileLangSwitchState extends State<ProfileLangSwitch> {
  late FilterGroupData data;

  @override
  void initState() {
    super.initState();
    data = FilterGroupData(options: {
      (widget.primary ?? Language.current).code: true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilterGroup(
      values: data,
      options: [
        if (widget.showCn) Language.chs.code,
        if (widget.showJp) Language.jpn.code,
        if (widget.showEn) Language.eng.code,
      ],
      optionBuilder: (code) {
        return SizedBox(
          width: 32,
          height: 32,
          child: Center(
              child: Text({
            Language.chs.code: '中',
            Language.jpn.code: '日',
            Language.eng.code: 'EN',
          }[code]!)),
        );
      },
      padding: const EdgeInsets.symmetric(horizontal: 1),
      combined: true,
      useRadio: true,
      shrinkWrap: true,
      onFilterChanged: (v) {
        String? code =
            v.options.entries.firstWhereOrNull((e) => e.value == true)?.key;
        if (code == null) return;
        Language? lang = Language.getLanguage(code);
        if (lang != null) {
          widget.onChanged(lang);
        }
      },
    );
  }
}
