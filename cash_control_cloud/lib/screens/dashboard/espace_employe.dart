import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class EspaceEmploye extends StatefulWidget {
  const EspaceEmploye({super.key});
  @override
  State<EspaceEmploye> createState() => _EspaceEmployeState();
}

class _EspaceEmployeState extends State<EspaceEmploye> {
  final box = Hive.box('settings');
  final salesBox = Hive.box('daily_sales'); // Stockage temporaire de la journée
  
  String? selectedEmploye;
  Map<String, dynamic>? selectedService;
  
  void _enregistrerVente() {
    if (selectedEmploye != null && selectedService != null) {
      List ventes = salesBox.get('ventes', defaultValue: []);
      ventes.add({
        'employe': selectedEmploye,
        'service': selectedService!['nom'],
        'prix': selectedService!['prix'],
        'part_employe': selectedService!['part_employe'],
        'heure': DateTime.now().toString(),
      });
      salesBox.put('ventes', ventes);
      setState(() { selectedService = null; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Vente validée")));
    }
  }

  void _ajouterDepense(String libelle, double montant) {
    List depenses = salesBox.get('depenses', defaultValue: []);
    depenses.add({'libelle': libelle, 'montant': montant});
    salesBox.put('depenses', depenses);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List employes = box.get('employes', defaultValue: []);
    List services = box.get('services', defaultValue: []);
    List ventesEnCours = salesBox.get('ventes', defaultValue: []);
    double totalVentes = ventesEnCours.fold(0, (sum, item) => sum + item['prix']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("👤 ESPACE EMPLOYÉ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          const Text("Qui êtes-vous ?"),
          DropdownButtonFormField<String>(
            value: selectedEmploye,
            items: employes.map<DropdownMenuItem<String>>((e) => DropdownMenuItem(value: e['nom'], child: Text(e['nom']))).toList(),
            onChanged: (v) => setState(() => selectedEmploye = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          
          const SizedBox(height: 20),
          const Text("Service effectué :"),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedService,
            items: services.map<DropdownMenuItem<Map<String, dynamic>>>((s) => DropdownMenuItem(value: Map<String, dynamic>.from(s), child: Text("${s['nom']} - ${s['prix']} F"))).toList(),
            onChanged: (v) => setState(() => selectedService = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _enregistrerVente, child: const Text("VALIDER"))),
          
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _showDepenseDialog(context),
            icon: const Icon(Icons.receipt_long),
            label: const Text("🧾 DEPENSE"),
          ),
          
          const Divider(height: 40),
          Text("📊 ${ventesEnCours.length} services | Total : ${totalVentes.toInt()} FCFA", style: const TextStyle(fontWeight: FontWeight.bold)),
          
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/envoi_rapport'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text("📤 ENVOYER LE RAPPORT", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDepenseDialog(BuildContext context) {
    String libelle = "";
    double montant = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouvelle Dépense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(onChanged: (v) => libelle = v, decoration: const InputDecoration(labelText: "Libellé (ex: Savon)")),
            TextField(onChanged: (v) => montant = double.tryParse(v) ?? 0, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Montant (FCFA)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          ElevatedButton(onPressed: () { _ajouterDepense(libelle, montant); Navigator.pop(context); }, child: const Text("AJOUTER")),
        ],
      ),
    );
  }
}