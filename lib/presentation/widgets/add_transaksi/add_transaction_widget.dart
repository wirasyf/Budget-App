import 'package:budget_app/presentation/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final String selectedType;
  final String selectedCategory;
  final DateTime selectedDate;
  final List<String> types;
  final List<String> categories;
  final Map<String, IconData> categoryIcons;
  final Function(String) onTypeChanged;
  final Function(String) onCategoryChanged;
  final VoidCallback onDatePick;
  final VoidCallback onSave;

  const TransactionFormWidget({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.amountController,
    required this.descriptionController,
    required this.selectedType,
    required this.selectedCategory,
    required this.selectedDate,
    required this.types,
    required this.categories,
    required this.categoryIcons,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onDatePick,
    required this.onSave,
  });

  bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  Color themeColor(BuildContext context) =>
      isDark(context) ? appYellow : Colors.blue;
  Color cardColor(BuildContext context) =>
      isDark(context) ? const Color(0xFF161B22) : Colors.grey.shade100;
  Color primaryTextColor(BuildContext context) =>
      isDark(context) ? const Color(0xFFE6EDF3) : appBlack;
  Color borderColor(BuildContext context) =>
      isDark(context) ? const Color(0xFF30363D) : Colors.grey.shade300;

  InputDecoration _fancyInput(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryTextColor(context)),
      filled: true,
      fillColor: cardColor(context),
      prefixIcon: Icon(icon, color: themeColor(context)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: borderColor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: themeColor(context), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((cat) {
        final isSelected = selectedCategory == cat;
        return GestureDetector(
          onTap: () => onCategoryChanged(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? themeColor(context).withOpacity(0.2)
                  : cardColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? themeColor(context) : borderColor(context),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(categoryIcons[cat], size: 20, color: themeColor(context)),
                const SizedBox(width: 6),
                Text(cat, style: TextStyle(color: primaryTextColor(context))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(15),
                color: cardColor(context),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: _fancyInput(context, 'Title', Icons.title),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter title'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // -------------------------------------------------------
                      // Field Amount hanya menerima angka & titik desimal
                      // -------------------------------------------------------
                      TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: _fancyInput(
                          context,
                          'Amount',
                          Icons.attach_money,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        items: types
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        decoration: _fancyInput(
                          context,
                          'Type',
                          Icons.swap_horiz,
                        ),
                        onChanged: (val) => onTypeChanged(val!),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: onDatePick,
                        borderRadius: BorderRadius.circular(15),
                        child: InputDecorator(
                          decoration: _fancyInput(
                            context,
                            'Date',
                            Icons.calendar_today,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: primaryTextColor(context),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: _fancyInput(
                          context,
                          'Description',
                          Icons.notes,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCategorySelector(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Transaksi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                    elevation: 5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
