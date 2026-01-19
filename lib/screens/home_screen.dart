import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Transaction> _transactions;
  late List<Transaction> _filteredTransactions;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _transactions = [
      Transaction(
        id: '1',
        title: 'Salary',
        amount: 5000,
        category: 'Salary',
        type: TransactionType.income,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: '2',
        title: 'Lunch',
        amount: 150,
        category: 'Food',
        type: TransactionType.expense,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Transaction(
        id: '3',
        title: 'Coffee',
        amount: 80,
        category: 'Food',
        type: TransactionType.expense,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Transaction(
        id: '4',
        title: 'Transport',
        amount: 50,
        category: 'Transport',
        type: TransactionType.expense,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Transaction(
        id: '5',
        title: 'Movie',
        amount: 200,
        category: 'Entertainment',
        type: TransactionType.expense,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: '6',
        title: 'Electricity Bill',
        amount: 1020,
        category: 'Utilities',
        type: TransactionType.expense,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    _filteredTransactions = _transactions;
  }

  void _filterTransactions(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTransactions = _transactions;
      } else {
        _filteredTransactions = _transactions
            .where((t) =>
                t.title.toLowerCase().contains(query.toLowerCase()) ||
                t.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  double get _totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get _totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get _totalBalance {
    return _totalIncome - _totalExpense;
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
      _filterTransactions(_searchQuery);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction deleted')),
    );
  }

  void _editTransaction(String id) {
    final transaction = _transactions.firstWhere((t) => t.id == id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditFormScreen(
          transaction: transaction,
          onSave: _updateTransaction,
        ),
      ),
    );
  }

  void _updateTransaction(Transaction transaction) {
    setState(() {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }
    });
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      _transactions.insert(0, transaction);
      _filterTransactions(_searchQuery);
    });
  }

  void _reorderTransactions(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _transactions.removeAt(oldIndex);
      _transactions.insert(newIndex, item);
    });
  }

  void _openAddTransactionForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditFormScreen(
          onSave: _addTransaction,
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          totalIncome: _totalIncome,
          totalExpense: _totalExpense,
          totalBalance: _totalBalance,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expenses'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedIconButton(
              icon: Icons.settings,
              onPressed: _openSettings,
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: _filterTransactions,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // Balance Card
          Padding(
            padding: const EdgeInsets.all(12),
            child: AnimatedBalanceCard(
              totalBalance: _totalBalance,
            ),
          ),
          // Transaction List
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView(
                    onReorder: _reorderTransactions,
                    children: _filteredTransactions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final transaction = entry.value;

                      return Dismissible(
                        key: ValueKey(transaction.id),
                        child: TransactionListItem(
                          transaction: transaction,
                          onEdit: () => _editTransaction(transaction.id),
                        ),
                        background: Container(
                          color: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerLeft,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            // Edit (right to left)
                            _editTransaction(transaction.id);
                          } else {
                            // Delete (left to right)
                            _deleteTransaction(transaction.id);
                          }
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransitionButton(
        onPressed: _openAddTransactionForm,
        icon: Icons.add,
        label: 'Add',
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;

  const TransactionListItem({
    required this.transaction,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.red;
    final amountPrefix = isIncome ? '+' : '-';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Colors.grey,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.drag_handle,
          color: Colors.grey[400],
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          transaction.category,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          '$amountPrefix฿${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: onEdit,
      ),
    );
  }
}

class AddEditFormScreen extends StatefulWidget {
  final Transaction? transaction;
  final Function(Transaction) onSave;

  const AddEditFormScreen({
    this.transaction,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  State<AddEditFormScreen> createState() => _AddEditFormScreenState();
}

class _AddEditFormScreenState extends State<AddEditFormScreen> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  late TransactionType _selectedType;

  final List<String> _categories = ['Food', 'Transport', 'Salary', 'Entertainment', 'Utilities', 'Other'];

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _titleController = TextEditingController(text: widget.transaction?.title ?? '');
    _amountController = TextEditingController(text: widget.transaction?.amount.toString() ?? '');
    _selectedType = widget.transaction?.type ?? TransactionType.expense;
    
    // Set category based on transaction type, ensure it's in the list
    String initialCategory = widget.transaction?.category ?? _categories.first;
    _selectedCategory = _categories.contains(initialCategory) ? initialCategory : _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: widget.transaction?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        type: _selectedType,
        timestamp: widget.transaction?.timestamp ?? DateTime.now(),
      );

      widget.onSave(transaction);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.transaction == null ? 'Transaction added' : 'Transaction updated'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g., Lunch',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  if (value!.length < 2) {
                    return 'Title must be at least 2 characters';
                  }
                  if (value.length > 50) {
                    return 'Title must not exceed 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  hintText: '0.00',
                  prefixText: '฿ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an amount';
                  }
                  final parsedValue = double.tryParse(value!);
                  if (parsedValue == null) {
                    return 'Please enter a valid number';
                  }
                  if (parsedValue <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type Selection (Radio Buttons)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type *',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<TransactionType>(
                            title: const Text('Income'),
                            value: TransactionType.income,
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() => _selectedType = value!);
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<TransactionType>(
                            title: const Text('Expense'),
                            value: TransactionType.expense,
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() => _selectedType = value!);
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
                decoration: InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;

  const SettingsScreen({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Mode Toggle
            Card(
              child: ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: context.watch<ThemeProvider>().isDarkMode,
                  onChanged: (value) {
                    context.read<ThemeProvider>().toggleDarkMode();
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Summary Section
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Total Income
            Card(
              color: Colors.green[50],
              child: ListTile(
                leading: Icon(Icons.trending_up, color: Colors.green[600]),
                title: const Text('Total Income'),
                trailing: Text(
                  '+ ฿${widget.totalIncome.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Total Expense
            Card(
              color: Colors.red[50],
              child: ListTile(
                leading: Icon(Icons.trending_down, color: Colors.red[600]),
                title: const Text('Total Expense'),
                trailing: Text(
                  '- ฿${widget.totalExpense.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Balance
            Card(
              color: Colors.blue[50],
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet, color: Colors.blue[600]),
                title: const Text('Balance'),
                trailing: Text(
                  '${widget.totalBalance > 0 ? '+' : ''} ฿${widget.totalBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated Scale Transition Button
class ScaleTransitionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const ScaleTransitionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  State<ScaleTransitionButton> createState() => _ScaleTransitionButtonState();
}

class _ScaleTransitionButtonState extends State<ScaleTransitionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton.extended(
        onPressed: () {
          _controller.forward().then((_) {
            _controller.reverse();
          });
          widget.onPressed();
        },
        icon: Icon(widget.icon),
        label: Text(widget.label),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Animated Balance Card
class AnimatedBalanceCard extends StatefulWidget {
  final double totalBalance;

  const AnimatedBalanceCard({
    required this.totalBalance,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedBalanceCard> createState() => _AnimatedBalanceCardState();
}

class _AnimatedBalanceCardState extends State<AnimatedBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.totalBalance >= 0 ? '+' : ''} ฿${widget.totalBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const AnimatedIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(widget.icon),
        onPressed: () {
          _controller.forward().then((_) {
            _controller.reverse();
          });
          widget.onPressed();
        },
        tooltip: widget.tooltip,
      ),
    );
  }
}
