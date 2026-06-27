import 'package:flutter/material.dart';
import 'package:safe_solde/models/transaction.dart';
import 'package:safe_solde/models/debt.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Transaction> _transactions = [];
  List<Debt> _debts = [];
  DebtStatus _selectedDebtFilter = DebtStatus.pending;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // charge des transactions et creances
  Future<void> _loadData() async {
    await _loadTransactions();
    await _loadDebts();
  }

  double get _totalBalance {
    double total = 0;
    for (var tx in _transactions) {
      if (tx.isIncome) {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }

  double get _totalOwedMe {
    double total = 0;
    for (var debt in _debts) {
      if (debt.type == DebtType.owedMe && debt.status == DebtStatus.pending) {
        total += debt.amount;
      }
    }
    return total;
  }

  double get _totalIOwe {
    double total = 0;
    for (var debt in _debts) {
      if (debt.type == DebtType.iOwe && debt.status == DebtStatus.pending) {
        total += debt.amount;
      }
    }
    return total;
  }

  int get _pendingAlertCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysFromNow = today.add(const Duration(days: 7));

    int count = 0;
    for (var debt in _debts) {
      if (debt.status == DebtStatus.pending) {
        final debtDate = DateTime(debt.dueDate.year, debt.dueDate.month, debt.dueDate.day);
        // entre aujourdhui et 7 jours 
        if (debtDate.isAfter(today.subtract(const Duration(seconds: 1))) &&
            debtDate.isBefore(sevenDaysFromNow.add(const Duration(days: 1)))) {
          count++;
        }
      }
    }
    return count;
  }

  void _navigateAdd() async {
    final result = await Navigator.pushNamed(context, '/add');

    if (result != null && result is Transaction) {
      setState(() {
        _transactions.insert(0, result);
      });
      _saveTransactions();
    }
  }

  void _navigateAddDebt() async {
    final result = await Navigator.pushNamed(context, '/add-debt');

    if (result != null && result is Debt) {
      setState(() {
        _debts.insert(0, result);
      });
      _saveDebts();
    }
  }

  // Settle a debt: mark as SETTLED and automatically add a matching transaction
  void _settleDebt(Debt debt) async {
    final tx = Transaction(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      title: 'Remboursement : ${debt.contactName}',
      amount: debt.amount,
      isIncome: debt.type == DebtType.owedMe, // owedMe -> we get paid back (income); iOwe -> we pay back (expense)
      date: DateTime.now(),
    );

    setState(() {
      final index = _debts.indexWhere((d) => d.id == debt.id);
      if (index != -1) {
        _debts[index] = debt.copyWith(status: DebtStatus.settled);
      }
      _transactions.insert(0, tx);
    });

    await _saveDebts();
    await _saveTransactions();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dette de ${debt.contactName} remboursée'),
        backgroundColor: const Color(0xFF1C4D1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Persistence methods for Transactions
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_transactions.map((tx) => tx.toMap()).toList());
    await prefs.setString('user_transactions', encodedData);
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('user_transactions');
    if (savedData == null) return;
    try {
      final List<dynamic> decodedData = json.decode(savedData);
      final loaded = decodedData
          .map((item) => Transaction.fromMap(item as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() => _transactions = loaded);
    } catch (e) {
      debugPrint('Transactions corrompues, réinitialisation : $e');
      await prefs.remove('user_transactions');
    }
  }

  // Persistence methods for Debts
  Future<void> _saveDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_debts.map((d) => d.toMap()).toList());
    await prefs.setString('user_debts', encodedData);
  }

  Future<void> _loadDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('user_debts');
    if (savedData == null) return;
    try {
      final List<dynamic> decodedData = json.decode(savedData);
      final loaded = decodedData
          .map((item) => Debt.fromMap(item as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() => _debts = loaded);
    } catch (e) {
      debugPrint('Dettes corrompues, réinitialisation : $e');
      await prefs.remove('user_debts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Safe Solde' : 'Créances & Dettes'),
      ),
      body: _currentIndex == 0 ? _buildDashboard() : _buildDebtsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1C4D1E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Solde & Flux',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Créances & Dettes',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _currentIndex == 0 ? _navigateAdd : _navigateAddDebt,
        backgroundColor: const Color(0xFF1C4D1E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(_currentIndex == 0 ? 'Ajouter une transaction' : 'Ajouter Dette/pret'),
      ),
    );
  }

  // Dashboard / General balance view
  Widget _buildDashboard() {
    final alertCount = _pendingAlertCount;

    return Column(
      children: [
        // Balance Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _totalBalance >= 0
                  ? [const Color(0xFF1C4D1E), const Color(0xFF2E7D32)]
                  : [const Color(0xFF8E2A2A), const Color(0xFFB71C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Solde actuel',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                '${_totalBalance.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // 4. Alerte visuelle page d'accueil (Rappel échéances)
        if (alertCount > 0)
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 1),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.shade100.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rappel : $alertCount échéance${alertCount > 1 ? 's' : ''} de prêt${alertCount > 1 ? 's' : ''} cette semaine',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.amber.shade800),
                ],
              ),
            ),
          ),

        // Transactions list
        Expanded(
          child: _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          size: 72, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('Aucune opération',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(
                          'Appuyez sur + pour ajouter une entrée ou une dépense',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _transactions.length,
                  itemBuilder: (ctx, index) {
                    final tx = _transactions[index];
                    final color = tx.isIncome
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828);
                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        setState(() => _transactions.removeAt(index));
                        _saveTransactions();
                      },
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.12),
                            child: Icon(
                              tx.isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: color,
                            ),
                          ),
                          title: Text(tx.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy').format(tx.date),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                          trailing: Text(
                            "${tx.isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(0)} FCFA",
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 1. Écran dédié "Créances & Dettes" avec synthèse
  Widget _buildDebtsScreen() {
    // Filter debts based on selected filter status
    final filteredDebts = _debts.where((d) => d.status == _selectedDebtFilter).toList();

    return Column(
      children: [
        // Two big cards at the top
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              // Card "On me doit"
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Light green
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.call_received, color: Colors.green.shade700, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'On me doit',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_totalOwedMe.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Card "Je dois"
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE), // Light red
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.call_made, color: Colors.red.shade700, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Je dois',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_totalIOwe.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Chips de filtrage "En attente" / "Historique"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('En attente'),
                labelStyle: TextStyle(
                  color: _selectedDebtFilter == DebtStatus.pending ? Colors.white : Colors.black,
                ),
                selected: _selectedDebtFilter == DebtStatus.pending,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedDebtFilter = DebtStatus.pending);
                  }
                },
                selectedColor: const Color(0xFF1C4D1E),
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Historique'),
                labelStyle: TextStyle(
                  color: _selectedDebtFilter == DebtStatus.settled ? Colors.white : Colors.black,
                ),
                selected: _selectedDebtFilter == DebtStatus.settled,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedDebtFilter = DebtStatus.settled);
                  }
                },
                selectedColor: const Color(0xFF1C4D1E),
              ),
            ],
          ),
        ),

        // Debt list
        Expanded(
          child: filteredDebts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedDebtFilter == DebtStatus.pending
                            ? Icons.check_circle_outline
                            : Icons.history,
                        size: 72,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedDebtFilter == DebtStatus.pending
                            ? 'Aucune dette en cours'
                            : 'Aucun historique',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filteredDebts.length,
                  itemBuilder: (ctx, index) {
                    final debt = filteredDebts[index];
                    final isOwedMe = debt.type == DebtType.owedMe;
                    final isPending = debt.status == DebtStatus.pending;
                    
                    // Determine date color: if pending and date is in past, use red
                    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                    final debtDate = DateTime(debt.dueDate.year, debt.dueDate.month, debt.dueDate.day);
                    final isOverdue = isPending && debtDate.isBefore(today);

                    return Dismissible(
                      key: ValueKey(debt.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        setState(() {
                          _debts.removeWhere((d) => d.id == debt.id);
                        });
                        _saveDebts();
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isOwedMe
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    child: Icon(
                                      isOwedMe ? Icons.call_received : Icons.call_made,
                                      color: isOwedMe ? Colors.green.shade700 : Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          debt.contactName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isOwedMe ? 'Prêt de votre part' : 'Emprunt à rembourser',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${debt.amount.toStringAsFixed(0)} FCFA',
                                    style: TextStyle(
                                      color: isOwedMe ? Colors.green.shade700 : Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_outlined,
                                        size: 14,
                                        color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Échéance : ${DateFormat('dd/MM/yyyy').format(debt.dueDate)}',
                                        style: TextStyle(
                                          color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                                          fontSize: 12,
                                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      if (isOverdue)
                                        Container(
                                          margin: const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'En retard',
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  
                                  // 2. Bouton "Rembourser"
                                  if (isPending)
                                    ElevatedButton.icon(
                                      onPressed: () => _settleDebt(debt),
                                      icon: const Icon(Icons.check, size: 14),
                                      label: const Text('Rembourser', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1C4D1E),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(100, 32),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Remboursé',
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
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
                  },
                ),
        ),
      ],
    );
  }
}
