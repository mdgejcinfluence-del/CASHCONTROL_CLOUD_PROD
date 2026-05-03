import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class BilanPatron extends StatefulWidget {
  const BilanPatron({super.key});
  @override
  State<BilanPatron> createState() => _BilanPatronState();
}

class _BilanPatronState extends State<BilanPatron> {
  final box = Hive.box('settings');
  String rapportDechiffre = "";
  Map<String, double> resultats = {"brut": 0, "net": 0, "charges": 0, "crypto_fees": 0};

  void _dechiffrerRapport(String messageBase64) {
    try {
      final key = encrypt.Key.fromUtf8(box.get('master_pin_hash').substring(0, 32));
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(messageBase64), iv: iv);
      Map<String, dynamic> data = jsonDecode(decrypted);
      _calculerRealite100(data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Erreur de déchiffrement (Clé invalide)")));
    }
  }

  void _calculerRealite100(Map<String, dynamic> data) {
    double brut = 0;
    double commissions = 0;
    double depensesJour = 0;

    // 1. Calcul des ventes et commissions
    for (var v in data['ventes']) {
      brut += v['prix'];
      commissions += v['part_employe'];
    }

    // 2. Calcul des dépenses signalées
    for (var d in data['depenses_jour']) {
      depensesJour += d['montant'];
    }

    // 3. Prorata des charges fixes (Loyer, WiFi, Salaire fixe / 30)
    double chargesFixesMensuelles = box.get('total_charges_fixes', defaultValue: 0.0);
    double prorataJournalier = chargesFixesMensuelles / 30;

    // 4. RÉALITÉ 100% : Frais de marché & Technique (Simulations Trading)
    double totalApresCharges = brut - commissions - depensesJour - prorataJournalier;
    
    // Application des déductions (Binance 0.1% + Slippage 0.15% + VPS Bug 1% = ~1.25%)
    double cryptoFees = totalApresCharges * 0.0125; 
    double netFinal = totalApresCharges - cryptoFees;

    setState(() {
      resultats = {
        "brut": brut,
        "charges": commissions + depensesJour + prorataJournalier,
        "crypto_fees": cryptoFees,
        "net": netFinal
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terminal MDGEJ-C DIGITAL")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Coller le message chiffré WhatsApp", border: OutlineInputBorder()),
              onChanged: (v) => _dechiffrerRapport(v.replaceFirst("🔒 CASHCONTROL DATA 🔒\n", "")),
            ),
            const SizedBox(height: 30),
            _buildBilanCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBilanCard() {
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _rowBilan("CHIFFRE D'AFFAIRES", "${resultats['brut']?.toInt()} F", Colors.blue),
            _rowBilan("CHARGES & COMMISSIONS", "- ${resultats['charges']?.toInt()} F", Colors.orange),
            _rowBilan("DEDUCTION RISQUES (1.25%)", "- ${resultats['crypto_fees']?.toInt()} F", Colors.red),
            const Divider(color: Colors.white),
            _rowBilan("BÉNÉFICE NET RÉEL", "${resultats['net']?.toInt()} F", Colors.green, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _rowBilan(String label, String value, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
        ],
      ),
    );
  }
}