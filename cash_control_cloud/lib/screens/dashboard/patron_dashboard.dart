import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../../services/security_service.dart';

class PatronDashboard extends StatefulWidget {
  const PatronDashboard({super.key});

  @override
  State<PatronDashboard> createState() => _PatronDashboardState();
}

class _PatronDashboardState extends State<PatronDashboard> {
  final _reportController = TextEditingController();
  Map? decodedData;
  double netProfit = 0;

  void _analyserRapport() {
    try {
      // Extraction de la partie DATA du message WhatsApp
      String rawInput = _reportController.text;
      String encryptedPart = rawInput.split("DATA: ")[1].trim();
      
      // DECRYPTAGE AES-256
      String decryptedJson = SecurityService.decryptData(encryptedPart);
      setState(() {
        decodedData = jsonDecode(decryptedJson);
        _calculerRealite100();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code invalide ou corrompu")));
    }
  }

  void _calculerRealite100() {
    if (decodedData == null) return;

    List ventes = decodedData!['ventes'];
    double CA = ventes.fold(0, (sum, item) => sum + item['price']);
    
    // Récupération des paramètres de ta stratégie "Réalité 100%"
    double binanceFee = 0.001; // 0.1%
    double slippage = 0.0015; // 0.15%
    double vpsBugProb = 0.01;  // 1%
    
    // Simulation des déductions réelles
    double totalFees = CA * (binanceFee + slippage + vpsBugProb);
    
    // Calcul Commissions Employés (Si payés au service)
    double commissions = 0;
    final settingsBox = Hive.box('settings');
    List emps = settingsBox.get('employes_list', defaultValue: []);
    
    for (var v in ventes) {
      var emp = emps.firstWhere((e) => e['name'] == v['employe'], orElse: () => null);
      if (emp != null && emp['type'] == 'Service') {
        commissions += emp['amount'];
      }
    }

    setState(() {
      netProfit = CA - totalFees - commissions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("🔑 DECRYPTAGE & BILAN NET", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _reportController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Collez ici le code reçu sur WhatsApp...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _analyserRapport,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            child: const Text("ANALYSER LE RAPPORT"),
          ),
          
          if (decodedData != null) ...[
            const Divider(height: 40),
            _buildResultCard("CHIFFRE D'AFFAIRES", "${decodedData!['ventes'].length} services effectués", "green"),
            _buildResultCard("DÉDUCTIONS (Réalité 100%)", "Frais, Slippage, Bugs VPS inclus", "red"),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black,
              child: Column(
                children: [
                  const Text("BÉNÉFICE NET RÉEL", style: TextStyle(color: Colors.white70)),
                  Text("${netProfit.toInt()} FCFA", style: const TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String sub, String color) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
      trailing: Icon(Icons.info_outline, color: color == "green" ? Colors.green : Colors.red),
    );
  }
}