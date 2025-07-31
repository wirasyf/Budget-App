import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_app/presentation/theme/color.dart';
import 'package:budget_app/main.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  late final Stream<Map<String, dynamic>> transactionSummaryStream;

  bool isSelecting = false;
  Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();
    transactionSummaryStream = getTransactionSummary();
  }

  String _formatCurrency(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(value);
  }

  DateTime getStartDateByFilter() {
    final now = DateTime.now();
    switch (selectedIndex) {
      case 0:
        return DateTime(now.year, now.month, now.day);
      case 1:
        return now.subtract(Duration(days: now.weekday - 1));
      case 2:
        return DateTime(now.year, now.month);
      case 3:
        return DateTime(now.year);
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }

  Stream<Map<String, dynamic>> getTransactionSummary() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          double income = 0.0;
          double expense = 0.0;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final amountRaw = data['amount'] ?? 0;
            final amount = amountRaw is int ? amountRaw.toDouble() : amountRaw;
            final type = data['type']?.toString();

            if (type == 'Income') {
              income += amount;
            } else if (type == 'Expense') {
              expense += amount;
            }
          }

          return {
            'income': income,
            'expense': expense,
            'balance': income - expense,
          };
        });
  }

  Stream<QuerySnapshot> getTransactions() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final startDate = getStartDateByFilter();

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date', descending: true)
        .snapshots();
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'transportation':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
      case 'salary':
        return Icons.attach_money;
      case 'gift':
        return Icons.card_giftcard;
      case 'investment':
        return Icons.trending_up;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.category;
    }
  }

  void _showEditTransactionDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;

    TextEditingController titleController = TextEditingController(
      text: data['title'],
    );
    TextEditingController amountController = TextEditingController(
      text: data['amount'].toString(),
    );

    String selectedEditCategory = data['category'];
    String selectedEditType = data['type'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Judul'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nominal'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedEditType,
                      items: ['Income', 'Expense']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setModalState(() => selectedEditType = val!),
                      decoration: const InputDecoration(labelText: 'Tipe'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedEditCategory,
                      items:
                          [
                                'Food',
                                'Transportation',
                                'Shopping',
                                'Bills',
                                'Entertainment',
                                'Salary',
                                'Gift',
                                'Investment',
                                'Health',
                                'Other',
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (val) =>
                          setModalState(() => selectedEditCategory = val!),
                      decoration: const InputDecoration(labelText: 'Kategori'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appRed,
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('transactions')
                                  .doc(id)
                                  .delete();
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text('Hapus'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appGreen,
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('transactions')
                                  .doc(id)
                                  .update({
                                    'title': titleController.text,
                                    'amount':
                                        int.tryParse(amountController.text) ??
                                        0,
                                    'type': selectedEditType,
                                    'category': selectedEditCategory,
                                  });
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color get backgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0D1117) : Colors.white;
  }

  Color get cardBackgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF161B22) : appPrimary;
  }

  Color get primaryTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE6EDF3) : appBlack;
  }

  Color get secondaryTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF8B949E) : appBlackSoft;
  }

  Color get appBarBackgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0D1117) : appPrimary;
  }

  Color get appBarTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE6EDF3) : appBlack;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        elevation: 0,
        title: Text(
          "Beranda",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: appBarTextColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => themeNotifier.toggleTheme(),
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            color: appBarTextColor,
          ),
        ],
      ),
      floatingActionButton: isSelecting
          ? FloatingActionButton.extended(
              backgroundColor: appRed,
              icon: const Icon(Icons.delete),
              label: Text('Hapus (${selectedIds.length})'),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Hapus Transaksi'),
                    content: Text(
                      'Yakin ingin menghapus ${selectedIds.length} transaksi?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appRed,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final batch = FirebaseFirestore.instance.batch();
                  for (final id in selectedIds) {
                    batch.delete(
                      FirebaseFirestore.instance
                          .collection('transactions')
                          .doc(id),
                    );
                  }
                  await batch.commit();
                  setState(() {
                    isSelecting = false;
                    selectedIds.clear();
                  });
                }
              },
            )
          : null,
      body: SafeArea(
        child: Container(
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                StreamBuilder<Map<String, dynamic>>(
                  stream: transactionSummaryStream,
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? {};
                    final balance = (data['balance'] ?? 0.0) as double;
                    final income = (data['income'] ?? 0.0) as double;
                    final expense = (data['expense'] ?? 0.0) as double;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: isDark
                            ? Border.all(
                                color: const Color(0xFF30363D),
                                width: 1,
                              )
                            : null,
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Total Balance",
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Text(
                              _formatCurrency(balance),
                              key: ValueKey(balance),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  income,
                                  "Income",
                                  appGreen,
                                  Icons.arrow_downward_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  expense,
                                  "Expense",
                                  appRed,
                                  Icons.arrow_upward_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFilterButton("Hari Ini", 0),
                      _buildFilterButton("Minggu", 1),
                      _buildFilterButton("Bulan", 2),
                      _buildFilterButton("Tahun", 3),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 18,
                          color: primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? const Color(0xFF58A6FF) : appPrimary,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Tidak ada transaksi.",
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final isExpense = data['type'] == 'Expense';
                          final icon = getCategoryIcon(data['category'] ?? '');
                          final date = (data['date'] as Timestamp?)?.toDate();
                          final dateText = date != null
                              ? DateFormat('d MMM yy').format(date)
                              : '';

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                            child: Material(
                              color: cardBackgroundColor,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onLongPress: () {
                                  setState(() {
                                    isSelecting = true;
                                    selectedIds.add(doc.id);
                                  });
                                },
                                onTap: () {
                                  if (isSelecting) {
                                    setState(() {
                                      if (selectedIds.contains(doc.id)) {
                                        selectedIds.remove(doc.id);
                                      } else {
                                        selectedIds.add(doc.id);
                                      }
                                      if (selectedIds.isEmpty) {
                                        isSelecting = false;
                                      }
                                    });
                                  } else {
                                    _showEditTransactionDialog(doc);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: isDark
                                        ? Border.all(
                                            color: const Color(0xFF30363D),
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        if (isSelecting)
                                          Checkbox(
                                            value: selectedIds.contains(doc.id),
                                            onChanged: (val) {
                                              setState(() {
                                                if (val == true) {
                                                  selectedIds.add(doc.id);
                                                } else {
                                                  selectedIds.remove(doc.id);
                                                }
                                                if (selectedIds.isEmpty) {
                                                  isSelecting = false;
                                                }
                                              });
                                            },
                                          ),
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: isExpense
                                                ? (isDark
                                                      ? appRed.withOpacity(0.2)
                                                      : appRedSoft)
                                                : (isDark
                                                      ? appGreen.withOpacity(
                                                          0.2,
                                                        )
                                                      : appGreenSoft),
                                          ),
                                          child: Icon(
                                            icon,
                                            color: isExpense
                                                ? appRed
                                                : appGreen,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['title'] ?? '',
                                                style: TextStyle(
                                                  color: primaryTextColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${data['category'] ?? ''} • $dateText',
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "${isExpense ? '-' : '+'}${_formatCurrency(data['amount'])}",
                                          style: TextStyle(
                                            color: isExpense
                                                ? appRed
                                                : appGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    double value,
    String label,
    Color color,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.3 : 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, int index) {
    final bool isSelected = selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? appYellow : const Color(0xFF58A6FF))
            : (isDark ? const Color(0xFF21262D) : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        border: isDark && !isSelected
            ? Border.all(color: const Color(0xFF30363D), width: 1)
            : null,
      ),
      child: TextButton(
        onPressed: () => setState(() => selectedIndex = index),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(70, 36),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected
                ? Colors.white
                : (isDark ? secondaryTextColor : appBlackSoft),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
