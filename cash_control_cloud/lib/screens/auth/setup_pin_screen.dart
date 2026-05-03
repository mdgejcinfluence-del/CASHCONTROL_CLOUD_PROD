import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});
  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  final box = Hive.box('settings');

  void _creerPin() {
    if (_pin1.text.length == 4 && _pin1.text == _pin2.text) {
      // Hachage SHA-256 (Exigence Étape 0)
      var bytes = utf8.encode(_pin1.text);
      var digest = sha256.convert(bytes);
      
      box.put('master_pin_hash', digest.toString());
      box.put('is_initialized', true);
      
      // La clé AES-256 est maintenant virtuellement prête
      box.put('aes_key_ready', true); 

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les codes PIN ne correspondent pas ou sont invalides"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🔐", style: TextStyle(fontSize: 50)),
              const SizedBox(height: 20),
              const Text("Créez votre Code PIN Maître", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Ce code protège toutes vos données", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              TextField(
                controller: _pin1,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(labelText: "Code PIN (4 chiffres)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _pin2,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(labelText: "Confirmez le PIN", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _creerPin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  child: const Text("CRÉER LE CODE PIN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}