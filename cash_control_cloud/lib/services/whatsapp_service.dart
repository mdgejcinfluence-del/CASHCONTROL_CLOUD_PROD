import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class WhatsAppService {
  final box = Hive.box('settings');
  final salesBox = Hive.box('daily_sales');

  Future<void> envoyerRapport(String numeroPatron) async {
    // 1. Préparation des données
    Map<String, dynamic> rapport = {
      'date': DateTime.now().toIso8601String(),
      'ventes': salesBox.get('ventes', defaultValue: []),
      'depenses_jour': salesBox.get('depenses', defaultValue: []),
      'version': '1.0.0-MDGEJ'
    };

    String jsonRapport = jsonEncode(rapport);

    // 2. Chiffrement AES-256 (Protocole MDGEJ-C DIGITAL)
    final key = encrypt.Key.fromUtf8(box.get('master_pin_hash').substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(jsonRapport, iv: iv);
    String messageFinal = "🔒 CASHCONTROL DATA 🔒\n" + encrypted.base64;

    // 3. Envoi via WhatsApp
    String url = "whatsapp://send?phone=$numeroPatron&text=${Uri.encodeComponent(messageFinal)}";
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      // Nettoyage après envoi pour sécurité
      salesBox.delete('ventes');
      salesBox.delete('depenses');
    }
  }
}