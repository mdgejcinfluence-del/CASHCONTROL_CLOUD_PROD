import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmployesSection extends StatefulWidget {
  const EmployesSection({super.key});
  @override
  State<EmployesSection> createState() => _EmployesSectionState();
}

class _EmployesSectionState extends State<EmployesSection> {
  final box = Hive.box('settings');
  bool _isSalaireFixe = true; // Toggle pour le choix du mode de paie

  void _ajouterEmploye(String nom, double montant, bool isFixe) {
    List employes = box.get('employes', defaultValue: []);
    employes.add({
      'nom': nom,
      'mode': isFixe ? 'fixe' : 'service',
      'valeur': montant,
    });
    box.put('employes', employes);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("B. MES EMPLOYÉS", style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            // Liste des employés existants (Amina, Kofi, Fatima...)
            _buildListEmployes(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showAddDialog(context),
              child: const Text("[ + AJOUTER UN EMPLOYÉ ]"),
            ),
          ],
        ),
      ),
    );
  }

  // Dialogue respectant l'architecture : un champ apparaît selon le mode choisi
  void _showAddDialog(BuildContext context) {
    String nom = "";
    double montant = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Nouvel Employé"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(onChanged: (v) => nom = v, decoration: const InputDecoration(labelText: "Nom")),
              Row(
                children: [
                  const Text("Salaire Fixe"),
                  Switch(value: !_isSalaireFixe, onChanged: (v) => setDialogState(() => _isSalaireFixe = !v)),
                  const Text("Au Service"),
                ],
              ),
              TextField(
                onChanged: (v) => montant = double.tryParse(v) ?? 0,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _isSalaireFixe ? "Salaire mensuel (FCFA)" : "Sa part par service (FCFA)"
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
            ElevatedButton(
              onPressed: () {
                _ajouterEmploye(nom, montant, _isSalaireFixe);
                Navigator.pop(context);
              },
              child: const Text("VALIDER"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListEmployes() {
    List employes = box.get('employes', defaultValue: []);
    return Column(
      children: employes.map((e) => ListTile(
        leading: const Icon(Icons.person),
        title: Text(e['nom']),
        subtitle: Text(e['mode'] == 'fixe' 
            ? "Salaire fixe : ${e['valeur']} FCFA/mois" 
            : "Payé au service : ${e['valeur']} FCFA/acte"),
        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
          employes.remove(e);
          box.put('employes', employes);
          setState(() {});
        }),
      )).toList(),
    );
  }
}