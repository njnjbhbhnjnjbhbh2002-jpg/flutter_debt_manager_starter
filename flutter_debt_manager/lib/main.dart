import 'package:flutter/material.dart';

void main() => runApp(const DebtManagerApp());

const blue = Color(0xFF0878F9);
const green = Color(0xFF13B886);
const ink = Color(0xFF202938);
const bg = Color(0xFFF6F8FC);

class DebtManagerApp extends StatelessWidget {
  const DebtManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'المتخصص للديون',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: blue, primary: blue),
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          backgroundColor: bg, foregroundColor: ink, centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}

class DebtPerson {
  DebtPerson({
    required this.name,
    required this.phone,
    required this.total,
    this.note = '',
    List<Payment>? payments,
  }) : payments = payments ?? [];

  String name;
  String phone;
  double total;
  String note;
  final List<Payment> payments;
  final List<DebtAddition> additions = [];

  double get paid => payments.fold(0, (sum, p) => sum + p.amount);
  double get remaining => (total - paid).clamp(0, double.infinity);
}

class Payment {
  Payment(this.amount, this.date, this.note);
  final double amount;
  final DateTime date;
  final String note;
}

class DebtAddition {
  DebtAddition(this.amount, this.date, this.note);
  final double amount;
  final DateTime date;
  final String note;
}

String money(double n) {
  final rounded = n.round().toString();
  final out = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    if (i > 0 && (rounded.length - i) % 3 == 0) out.write(',');
    out.write(rounded[i]);
  }
  return '$out د.ع';
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<DebtPerson> people = [
    DebtPerson(name: 'ذو الفقار صادق', phone: '07712345678', total: 3400000),
    DebtPerson(name: 'محمد حسن', phone: '07700000000', total: 2800000),
    DebtPerson(name: 'علي حسين', phone: '07500000000', total: 5000000),
  ];
  String search = '';
  int tab = 0;

  double get totalDebt => people.fold(0, (s, p) => s + p.total);
  double get totalPaid => people.fold(0, (s, p) => s + p.paid);
  double get totalRemaining => people.fold(0, (s, p) => s + p.remaining);

  @override
  Widget build(BuildContext context) {
    final filtered = people.where((p) =>
      p.name.contains(search) || p.phone.contains(search)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المتخصص للديون', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'الإحصائيات',
            onPressed: () => setState(() => tab = 1),
            icon: const Icon(Icons.bar_chart_rounded),
          ),
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () => _showInfo('الإعدادات', 'يمكن إضافة النسخ الاحتياطي وقفل التطبيق في الخطوة التالية.'),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: tab == 1
          ? _statsPage()
          : Column(
              children: [
                _summaryCard(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: TextField(
                    onChanged: (v) => setState(() => search = v.trim()),
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن اسم أو رقم هاتف...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      const Expanded(child: Text('قائمة الأشخاص', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      Text('${filtered.length} أشخاص', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('لا توجد نتائج مطابقة'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _personCard(filtered[i]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPerson,
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('إضافة شخص'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'الإحصائيات'),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [blue, Color(0xFF05B6D9)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: blue.withOpacity(.18), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('إجمالي الديون المتبقية', style: TextStyle(color: Colors.white70, fontSize: 15)),
        const SizedBox(height: 8),
        Text(money(totalRemaining), style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _miniStat('إجمالي الدين', money(totalDebt))),
          const SizedBox(width: 10),
          Expanded(child: _miniStat('المسدّد', money(totalPaid))),
        ]),
      ]),
    );
  }

  Widget _miniStat(String label, String value) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );

  Widget _personCard(DebtPerson p) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
        Directionality(textDirection: TextDirection.rtl, child: PersonPage(person: p)))).then((_) => setState(() {})),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFE7F2FF),
            child: Text(p.name.isEmpty ? '?' : p.name.substring(0, 1), style: const TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(p.phone, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('المتبقي: ${money(p.remaining)}', style: TextStyle(color: p.remaining == 0 ? green : const Color(0xFFD04D55), fontWeight: FontWeight.bold)),
          ])),
          const Icon(Icons.chevron_left, color: Colors.grey),
        ]),
      ),
    ),
  );

  Widget _statsPage() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('الإحصائيات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    _statTile('إجمالي الديون المسجلة', totalDebt, Icons.account_balance_wallet_outlined, blue),
    _statTile('إجمالي المبالغ المسددة', totalPaid, Icons.check_circle_outline, green),
    _statTile('إجمالي المبالغ المتبقية', totalRemaining, Icons.pending_actions, const Color(0xFFD04D55)),
    _statTile('عدد الأشخاص', people.length.toDouble(), Icons.people_outline, const Color(0xFF7C62D9), isCount: true),
  ]);

  Widget _statTile(String title, double value, IconData icon, Color color, {bool isCount = false}) => Card(
    elevation: 0, color: Colors.white, margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(backgroundColor: color.withOpacity(.12), child: Icon(icon, color: color)),
      title: Text(title),
      subtitle: Padding(padding: const EdgeInsets.only(top: 8), child: Text(isCount ? value.toInt().toString() : money(value), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color))),
    ),
  );

  Future<void> _addPerson() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final amount = TextEditingController();
    final note = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('إضافة شخص جديد'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم')),
        const SizedBox(height: 10),
        TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
        const SizedBox(height: 10),
        TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مبلغ الدين بالدينار العراقي')),
        const SizedBox(height: 10),
        TextField(controller: note, decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
      ],
    ));
    if (ok == true) {
      final n = name.text.trim();
      final a = double.tryParse(amount.text.replaceAll(',', '').trim()) ?? 0;
      if (n.isNotEmpty && a >= 0) {
        setState(() => people.insert(0, DebtPerson(name: n, phone: phone.text.trim(), total: a, note: note.text.trim())));
      } else {
        _showInfo('بيانات غير مكتملة', 'يرجى إدخال اسم صحيح ومبلغ رقمي.');
      }
    }
    name.dispose(); phone.dispose(); amount.dispose(); note.dispose();
  }

  void _showInfo(String title, String message) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(title: Text(title), content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً'))]),
  );
}

class PersonPage extends StatefulWidget {
  const PersonPage({super.key, required this.person});
  final DebtPerson person;
  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  DebtPerson get p => widget.person;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [blue, Color(0xFF05B6D9)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: blue.withOpacity(.16), blurRadius: 18, offset: const Offset(0, 7))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 27, backgroundColor: Colors.white.withOpacity(.2),
              child: Text(p.name.isEmpty ? '?' : p.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(p.phone.isEmpty ? 'لا يوجد رقم هاتف' : p.phone, style: const TextStyle(color: Colors.white70)),
            ])),
          ]),
          const SizedBox(height: 22),
          _whiteLine('إجمالي الدين', money(p.total)),
          _whiteLine('المبلغ المسدّد', money(p.paid)),
          const Divider(color: Colors.white38, height: 25),
          _whiteLine('المبلغ المتبقي', money(p.remaining), bold: true),
        ]),
      ),
      const SizedBox(height: 20),
      _actionButton(
        color: const Color(0xFFE53935), icon: Icons.add_circle_outline,
        title: 'إضافة دين', subtitle: 'إضافة مبلغ جديد إلى حساب هذا الشخص', onTap: _addDebt,
      ),
      const SizedBox(height: 12),
      _actionButton(
        color: const Color(0xFF16A34A), icon: Icons.payments_outlined,
        title: 'تسديد الدين', subtitle: 'تسجيل دفعة وخصمها من المبلغ المتبقي', onTap: _addPayment,
      ),
      const SizedBox(height: 24),
      const Text('سجل العمليات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      if (p.additions.isEmpty && p.payments.isEmpty)
        const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('لا توجد عمليات مسجلة بعد')))),
      ...p.additions.reversed.map((entry) => _historyTile(
        icon: Icons.add_circle_outline, color: const Color(0xFFE53935),
        title: 'إضافة دين · ${money(entry.amount)}', date: entry.date, note: entry.note,
      )),
      ...p.payments.reversed.map((payment) => _historyTile(
        icon: Icons.check_circle_outline, color: green,
        title: 'تسديد · ${money(payment.amount)}', date: payment.date, note: payment.note,
      )),
      if (p.note.isNotEmpty) ...[
        const SizedBox(height: 12),
        Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Text('ملاحظات: ${p.note}'))),
      ],
    ]),
  );

  Widget _actionButton({required Color color, required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) =>
    Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18), onTap: onTap,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          child: Row(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: Colors.white, size: 29)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ])),
            const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          ]),
        ),
      ),
    );

  Widget _historyTile({required IconData icon, required Color color, required String title, required DateTime date, required String note}) => Card(
    elevation: 0, color: Colors.white, margin: const EdgeInsets.only(bottom: 9),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(.12), child: Icon(icon, color: color)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      subtitle: Text('${date.year}/${date.month}/${date.day}${note.isEmpty ? '' : '\n$note'}'),
    ),
  );

  Widget _whiteLine(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
      Text(value, style: TextStyle(color: Colors.white, fontWeight: bold ? FontWeight.bold : FontWeight.w500, fontSize: bold ? 19 : 15)),
    ]),
  );

  Future<void> _addDebt() async {
    final amount = TextEditingController();
    final note = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('إضافة دين جديد'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('الدين الحالي: ${money(p.total)}'),
        const SizedBox(height: 12),
        TextField(controller: amount, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'مبلغ الدين الجديد', prefixIcon: Icon(Icons.money))),
        const SizedBox(height: 10),
        TextField(controller: note, decoration: const InputDecoration(labelText: 'تفاصيل أو ملاحظة (اختياري)', prefixIcon: Icon(Icons.notes))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE53935)), onPressed: () => Navigator.pop(ctx, true), child: const Text('إضافة الدين')),
      ],
    ));
    if (ok == true) {
      final a = double.tryParse(amount.text.replaceAll(',', '').trim());
      if (a != null && a > 0) {
        setState(() {
          p.total += a;
          p.additions.add(DebtAddition(a, DateTime.now(), note.text.trim()));
        });
      } else if (mounted) {
        _showError('أدخل مبلغاً صحيحاً أكبر من صفر.');
      }
    }
    amount.dispose(); note.dispose();
  }

  Future<void> _addPayment() async {
    if (p.remaining <= 0) {
      _showError('هذا الشخص لا يملك مبلغاً متبقياً للتسديد.');
      return;
    }
    final amount = TextEditingController();
    final note = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('تسديد الدين'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('المبلغ المتبقي: ${money(p.remaining)}'),
        const SizedBox(height: 12),
        TextField(controller: amount, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'مبلغ التسديد', prefixIcon: Icon(Icons.payments_outlined))),
        const SizedBox(height: 10),
        TextField(controller: note, decoration: const InputDecoration(labelText: 'ملاحظة (اختياري)', prefixIcon: Icon(Icons.notes))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)), onPressed: () => Navigator.pop(ctx, true), child: const Text('تأكيد التسديد')),
      ],
    ));
    if (ok == true) {
      final a = double.tryParse(amount.text.replaceAll(',', '').trim());
      if (a != null && a > 0 && a <= p.remaining) {
        setState(() => p.payments.add(Payment(a, DateTime.now(), note.text.trim())));
      } else if (mounted) {
        _showError('أدخل مبلغاً أكبر من صفر ولا يتجاوز الدين المتبقي.');
      }
    }
    amount.dispose(); note.dispose();
  }

  void _showError(String message) => showDialog<void>(context: context, builder: (ctx) => AlertDialog(
    title: const Text('تنبيه'), content: Text(message),
    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً'))],
  ));
}
