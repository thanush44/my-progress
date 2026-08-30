import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AlarmModal extends StatefulWidget {
  final String challengeText;
  final VoidCallback onDismissed;

  const AlarmModal({
    Key? key,
    required this.challengeText,
    required this.onDismissed,
  }) : super(key: key);

  static void show(BuildContext context, String challengeText, VoidCallback onDismissed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlarmModal(
        challengeText: challengeText,
        onDismissed: onDismissed,
      ),
    );
  }

  @override
  State<AlarmModal> createState() => _AlarmModalState();
}

class _AlarmModalState extends State<AlarmModal> {
  final TextEditingController _inputController = TextEditingController();
  String? _errorMessage;

  void _validateAndSubmit() {
    final input = _inputController.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final target = widget.challengeText.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    if (input == target) {
      widget.onDismissed();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alarm stopped successfully ✓'),
          backgroundColor: AppTheme.primaryDark,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Paragraph does not match. Please type it correctly.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Badge Header
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⏰ DAILY ALARM',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Good Morning!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 4),

              const Text(
                'Type the paragraph below to turn off your morning alarm:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.slateMuted,
                ),
              ),
              const SizedBox(height: 16),

              // Challenge Quote Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgGreen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.lightMint),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REQUIRED PARAGRAPH:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${widget.challengeText}"',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

              // Input Field
              TextField(
                controller: _inputController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type the paragraph here...',
                  filled: true,
                  fillColor: const Color(0xFFFAFCFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.emerald, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Turn Off Button
              ElevatedButton(
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Turn Off Alarm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
