import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/security_service.dart';

class EmployeScreen extends StatefulWidget {
  const EmployeScreen({super.key});

  @override
  State<EmployeScreen> createState() => _EmployeScreenState();
}

class _EmployeScreenState extends State<EmployeScreen> {
  final settingsBox = Hive.box('settings');
  final dataBox = Hive.box('data');

  String? selectedEmploye;
  Map? selectedService;
  List dailyVentes = [];
  List dailyDepenses = [];

  List get _employes => settingsBox.get('employes_list', defaultValue: []);
  List get _services => settingsBox.get('services_list', defaultValue: []);

  void _validerVente() {
    if (selectedEmploye != null && selectedService != null) {
      setState(() {
        dailyVentes.add({
          'employe': selectedEmploye,
          'service': selectedService!['name'],
          'price': selectedService!['price'],
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
    }
  }

  double get totalVentes => dailyVentes.fold(0, (sum, item) => sum + item['price']);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("👤 ESPACE EMPLOYÉ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // Sélection Employé
          const Text("Qui êtes-vous ?"),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedEmploye,
            items: _employes.map<DropdownMenuItem<String>>((e) => DropdownMenuItem(value: e['name'] as String, child: Text(e['name']))).toList(),
            onChanged: (v) => setState(() => selectedEmploye = v),
          ),

          const SizedBox(height: 20),

          // Sélection Service
          const Text("Service effectué :"),
          DropdownButton<Map>(
            isExpanded: true,
            hint: const Text("Choisir un service"),
            value: selectedService,
            items: _services.map<DropdownMenuItem<Map>>((s) => DropdownMenuItem(value: s as Map, child: Text("${s['name']} - ${s['price']} F"))).toList(),
            onChanged: (v) => setState(() => selectedService = v),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validerVente,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              child: const Text("VALIDER LA VENTE"),
            ),
          ),

          const Divider(height: 40),

          // Résumé Rapide
          Text("📊 ${dailyVentes.length} services | Total : ${totalVentes.toInt()} FCFA", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

          const SizedBox(height: 30),

          // Bouton Envoi (Lien vers Étape 3)
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: dailyVentes.isEmpty ? null : () => _showRapportDialog(),
              icon: const Icon(Icons.send),
              label: const Text("ENVOYER LE RAPPORT (WHATSAPP)"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showRapportDialog() {
    // Cette fonction appellera le chiffrement AES-256 dans l'étape suivante
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Prêt pour l'envoi ?"),
        content: Text("Le rapport contient ${dailyVentes.length} ventes pour un total de ${totalVentes.toInt()} FCFA. Il sera chiffré avant l'envoi."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("CHIFFRER & ENVOYER")),
        ],
      ),
    );
  }
}