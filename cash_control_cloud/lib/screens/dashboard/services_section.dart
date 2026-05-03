import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ServicesSection extends StatefulWidget {
  const ServicesSection({super.key});
  @override
  State<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  final box = Hive.box('settings');

  void _ajouterService(String nom, double prix, double partEmploye) {
    List services = box.get('services', defaultValue: []);
    services.add({
      'nom': nom,
      'prix': prix,
      'part_employe': partEmploye, // 0 si aucun employé n'est à la commission
    });
    box.put('services', services);
    setState(() {});
  }

  bool get _hasCommissionEmployee {
    List employes = box.get('employes', defaultValue: []);
    return employes.any((e) => e['mode'] == 'service');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("C. MES SERVICES", style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildListServices(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showAddServiceDialog(context),
              child: const Text("[ + AJOUTER UN SERVICE ]"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    String nom = "";
    double prix = 0;
    double part = 0;
    bool hasComm = _hasCommissionEmployee;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouveau Service"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(onChanged: (v) => nom = v, decoration: const InputDecoration(labelText: "Nom du service (ex: Lavage Complet)")),
            TextField(
              onChanged: (v) => prix = double.tryParse(v) ?? 0,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Prix (FCFA)"),
            ),
            if (hasComm) 
              TextField(
                onChanged: (v) => part = double.tryParse(v) ?? 0,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Part employé (FCFA)"),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          ElevatedButton(
            onPressed: () {
              _ajouterService(nom, prix, part);
              Navigator.pop(context);
            },
            child: const Text("VALIDER"),
          ),
        ],
      ),
    );
  }

  Widget _buildListServices() {
    List services = box.get('services', defaultValue: []);
    return Column(
      children: services.map((s) => ListTile(
        leading: const Icon(Icons.build_circle_outlined),
        title: Text(s['nom']),
        subtitle: Text("Prix: ${s['prix']} FCFA" + (s['part_employe'] > 0 ? " | Part: ${s['part_employe']} F" : "")),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            services.remove(s);
            box.put('services', services);
            setState(() {});
          }
        ),
      )).toList(),
    );
  }
}