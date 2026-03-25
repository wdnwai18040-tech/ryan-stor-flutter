import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/services/update_service.dart';
import 'package:ryaaans_store/screens/update_required_screen.dart';

class UpdateGate extends StatefulWidget {
  final Widget child;

  const UpdateGate({super.key, required this.child});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  bool _isChecking = true;
  bool _updateRequired = false;
  String _changelog = "";
  String _apkUrl = "";

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    final updateInfo = await UpdateService.checkForUpdate();
    final currentVersion = await UpdateService.getCurrentVersion();

    if (updateInfo != null) {
      final needsUpdate = UpdateService.isUpdateRequired(
        currentVersion,
        updateInfo.latestVersion,
      );

      if (needsUpdate && updateInfo.forceUpdate) {
        setState(() {
          _updateRequired = true;
          _changelog = updateInfo.changelog;
          _apkUrl = updateInfo.apkUrl;
          _isChecking = false;
        });
        return;
      }
    }

    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_updateRequired) {
      return UpdateRequiredScreen(
        changelog: _changelog,
        apkUrl: _apkUrl,
      );
    }

    return widget.child;
  }
}