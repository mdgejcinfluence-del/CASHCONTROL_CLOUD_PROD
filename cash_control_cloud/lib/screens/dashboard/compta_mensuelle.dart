import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ComptaMensuelle extends StatelessWidget {
  const ComptaMensuelle({super.key});

  @override
  Widget build(BuildContext context) {
    final archiveBox = Hive.box('archives'); // Stocke les rapports déchiffrés
    final reports = archiveBox.values.toList();
    
    // Calcul des cumuls mensuels
    double recettesTotales = 0;
    double depensesTotales = 0;
    double salairesTotaux = 0;
    double commissionsTotales = 0;
    double fraisFixesTotaux = 0;

    for (var report in reports) {
      recettesTotales += report['recettes'] ?? 0;
      depensesTotales += report['depenses_jour'] ?? 0;
      salairesTotaux += report['salaires_j'] ?? 0;
      commissionsTotales += report['commissions'] ?? 0;
      fraisFixesTotaux += report['frais_j'] ?? 0;
    }

    double beneficeNet = recettesTotales - depensesTotales - salairesTotaux - commissionsTotales - fraisFixesTotaux;
    bool isPositive = beneficeNet >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📊 COMPTABILITÉ – ${DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase()}", 
               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("${reports.length} jours enregistrés", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          
          _buildRow("💰 Recettes totales", recettesTotales),
          _buildRow("🧾 Dépenses totales", depensesTotales),
          _buildRow("👤 Salaires totaux", salairesTotaux),
          _buildRow("💸 Commissions", commissionsTotales),
          _buildRow("🏠 Frais totaux", fraisFixesTotaux),
          
          const Divider(thickness: 2, height: 40),
          
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              border: Border.all(color: isPositive ? Colors.green : Colors.red),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("💎 BÉNÉFICE NET MENSUEL", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${isPositive ? '+' : ''}${beneficeNet.toInt()} FCFA", 
                     style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          const Text("DÉTAILS JOURNALIERS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          // Liste des rapports individuels
          ...reports.reversed.map((r) => ListTile(
            leading: const Icon(Icons.calendar_today, size: 18),
            title: Text("${DateFormat('dd/MM').format(DateTime.parse(r['date']))} – ${r['employe_principal']}"),
            trailing: Text("${(r['profit_net']).toInt()} F", 
                           style: TextStyle(color: r['profit_net'] >= 0 ? Colors.green : Colors.red)),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text("${value.toInt()} FCFA", style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}