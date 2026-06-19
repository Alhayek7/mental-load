// lib/screens/settings_api_key.dart
import 'package:flutter/material.dart';
import '../services/key_service.dart';

class SettingsApiKeyScreen extends StatefulWidget {
  const SettingsApiKeyScreen({super.key});

  @override
  State<SettingsApiKeyScreen> createState() => _SettingsApiKeyScreenState();
}

class _SettingsApiKeyScreenState extends State<SettingsApiKeyScreen> {
  final KeyService _keyService = KeyService();
  final TextEditingController _keyController = TextEditingController();
  bool _hasKey = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkKey();
  }

  Future<void> _checkKey() async {
    final key = await _keyService.getOpenAIKey();
    setState(() {
      _hasKey = key != null && key.isNotEmpty;
      _isLoading = false;
    });
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isNotEmpty && key.startsWith('sk-')) {
      await _keyService.saveOpenAIKey(key);
      setState(() => _hasKey = true);
      _keyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ API Key saved securely!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter a valid API Key')),
      );
    }
  }

  Future<void> _deleteKey() async {
    await _keyService.deleteOpenAIKey();
    setState(() => _hasKey = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑️ API Key deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Key Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OpenAI API Key',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Used for voice-to-text transcription with Whisper API.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B6B7A)),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_hasKey)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2D6A4F).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2D6A4F)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'API Key is set',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: _deleteKey,
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFE76F51)),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  TextField(
                    controller: _keyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'sk-...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.key),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveKey,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E35B1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save API Key'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}