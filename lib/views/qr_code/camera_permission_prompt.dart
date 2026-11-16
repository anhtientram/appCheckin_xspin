import 'package:checkin/app/app_language.dart';
import 'package:flutter/material.dart';

class CameraPermissionPrompt extends StatelessWidget {
  const CameraPermissionPrompt({
    super.key,
    required this.onRetry,
    required this.onOpenSettings,
    this.showRetry = true,
  });

  final Future<void> Function() onRetry;
  final Future<void> Function() onOpenSettings;
  final bool showRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.no_photography_outlined,
                  color: Colors.white,
                  size: 54,
                ),
                const SizedBox(height: 18),
                Text(
                  AppLanguage.getText('KhongTheTruyCapCamera'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLanguage.getText('CapQuyenCameraDeQuetQR'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (showRetry)
                      OutlinedButton(
                        onPressed: () => onRetry(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        child: Text(AppLanguage.getText('ThuLai')),
                      ),
                    FilledButton(
                      onPressed: () => onOpenSettings(),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(AppLanguage.getText('MoCaiDat')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
