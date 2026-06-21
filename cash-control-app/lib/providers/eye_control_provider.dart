import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EyeControlProvider extends ChangeNotifier {
  bool enabled = false;
  bool calibrated = false;
  bool calibrating = false;

  Offset cursorPosition = const Offset(200, 400);

  Size screenSize = const Size(400, 800);

  String status = "Eye Control apagado";
  String direction = "Centro";

  bool clickRequested = false;
  bool backRequested = false;

  bool actionPanelOpen = false;

  final ScrollController globalScrollController =
      ScrollController();

  double horizontalSensitivity = 14.0;
  double verticalSensitivity = 13.0;
  double cursorSpeed = 5.0;
  double smoothing = 0.16;
  double scrollAmount = 260.0;

  bool blinkEnabled = true;
  bool doubleBlinkEnabled = true;

  bool invertHorizontal = false;
  bool invertVertical = false;

  Box get box => Hive.box(
        "cash_control_local",
      );

  EyeControlProvider() {
    loadSettings();
  }

  void loadSettings() {
    horizontalSensitivity =
        (box.get(
                  "eye_horizontal_sensitivity",
                  defaultValue: 14.0,
                ) as num)
            .toDouble();

    verticalSensitivity =
        (box.get(
                  "eye_vertical_sensitivity",
                  defaultValue: 13.0,
                ) as num)
            .toDouble();

    cursorSpeed =
        (box.get(
                  "eye_cursor_speed",
                  defaultValue: 5.0,
                ) as num)
            .toDouble();

    smoothing =
        (box.get(
                  "eye_smoothing",
                  defaultValue: 0.16,
                ) as num)
            .toDouble();

    scrollAmount =
        (box.get(
                  "eye_scroll_amount",
                  defaultValue: 260.0,
                ) as num)
            .toDouble();

    blinkEnabled = box.get(
      "eye_blink_enabled",
      defaultValue: true,
    );

    doubleBlinkEnabled = box.get(
      "eye_double_blink_enabled",
      defaultValue: true,
    );

    invertHorizontal = box.get(
      "eye_invert_horizontal",
      defaultValue: false,
    );

    invertVertical = box.get(
      "eye_invert_vertical",
      defaultValue: false,
    );

    notifyListeners();
  }

  Future<void> saveSettings() async {
    await box.put(
      "eye_horizontal_sensitivity",
      horizontalSensitivity,
    );

    await box.put(
      "eye_vertical_sensitivity",
      verticalSensitivity,
    );

    await box.put(
      "eye_cursor_speed",
      cursorSpeed,
    );

    await box.put(
      "eye_smoothing",
      smoothing,
    );

    await box.put(
      "eye_scroll_amount",
      scrollAmount,
    );

    await box.put(
      "eye_blink_enabled",
      blinkEnabled,
    );

    await box.put(
      "eye_double_blink_enabled",
      doubleBlinkEnabled,
    );

    await box.put(
      "eye_invert_horizontal",
      invertHorizontal,
    );

    await box.put(
      "eye_invert_vertical",
      invertVertical,
    );
  }

  void setScreenSize(Size size) {
    screenSize = size;

    if (cursorPosition.dx <= 0 ||
        cursorPosition.dy <= 0) {
      cursorPosition = Offset(
        size.width / 2,
        size.height / 2,
      );
    }
  }

  void enable() {
    enabled = true;
    status = "Eye Control activado";
    notifyListeners();
  }

  void disable() {
    enabled = false;
    calibrated = false;
    calibrating = false;
    status = "Eye Control apagado";
    direction = "Centro";
    actionPanelOpen = false;
    clickRequested = false;
    backRequested = false;
    notifyListeners();
  }

  void startCalibration() {
    calibrating = true;
    calibrated = false;
    status = "Calibrando rostro...";
    direction = "Centro";
    notifyListeners();
  }

  void finishCalibration() {
    calibrating = false;
    calibrated = true;
    status = "Calibración completada";
    direction = "Centro";
    notifyListeners();
  }

  void updateCursor(Offset position) {
    final safeX = position.dx.clamp(
      20.0,
      screenSize.width - 20,
    );

    final safeY = position.dy.clamp(
      80.0,
      screenSize.height - 80,
    );

    cursorPosition = Offset(
      safeX,
      safeY,
    );

    notifyListeners();
  }

  void updateDirection(String value) {
    direction = value;
    notifyListeners();
  }

  void updateStatus(String value) {
    status = value;
    notifyListeners();
  }

  void requestClick() {
    if (!blinkEnabled) return;

    clickRequested = true;
    actionPanelOpen = true;
    notifyListeners();
  }

  void clearClick() {
    clickRequested = false;
    notifyListeners();
  }

  void requestBack() {
    if (!doubleBlinkEnabled) return;

    backRequested = true;
    notifyListeners();
  }

  void clearBack() {
    backRequested = false;
    notifyListeners();
  }

  Future<void> scrollUp() async {
    if (!globalScrollController.hasClients) {
      return;
    }

    final position =
        globalScrollController.position;

    final target =
        position.pixels - scrollAmount;

    await globalScrollController.animateTo(
      target.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
      duration: const Duration(
        milliseconds: 320,
      ),
      curve: Curves.easeOut,
    );
  }

  Future<void> scrollDown() async {
    if (!globalScrollController.hasClients) {
      return;
    }

    final position =
        globalScrollController.position;

    final target =
        position.pixels + scrollAmount;

    await globalScrollController.animateTo(
      target.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
      duration: const Duration(
        milliseconds: 320,
      ),
      curve: Curves.easeOut,
    );
  }

  void closeActionPanel() {
    actionPanelOpen = false;
    clickRequested = false;
    notifyListeners();
  }

  void updateHorizontalSensitivity(double value) {
    horizontalSensitivity = value;
    saveSettings();
    notifyListeners();
  }

  void updateVerticalSensitivity(double value) {
    verticalSensitivity = value;
    saveSettings();
    notifyListeners();
  }

  void updateCursorSpeed(double value) {
    cursorSpeed = value;
    saveSettings();
    notifyListeners();
  }

  void updateSmoothing(double value) {
    smoothing = value;
    saveSettings();
    notifyListeners();
  }

  void updateScrollAmount(double value) {
    scrollAmount = value;
    saveSettings();
    notifyListeners();
  }

  void toggleBlink(bool value) {
    blinkEnabled = value;
    saveSettings();
    notifyListeners();
  }

  void toggleDoubleBlink(bool value) {
    doubleBlinkEnabled = value;
    saveSettings();
    notifyListeners();
  }

  void toggleInvertHorizontal(bool value) {
    invertHorizontal = value;
    saveSettings();
    notifyListeners();
  }

  void toggleInvertVertical(bool value) {
    invertVertical = value;
    saveSettings();
    notifyListeners();
  }

  void setLowSensitivityPreset() {
    horizontalSensitivity = 18.0;
    verticalSensitivity = 17.0;
    cursorSpeed = 3.0;
    smoothing = 0.12;
    scrollAmount = 180.0;
    saveSettings();
    notifyListeners();
  }

  void setMediumSensitivityPreset() {
    horizontalSensitivity = 14.0;
    verticalSensitivity = 13.0;
    cursorSpeed = 5.0;
    smoothing = 0.16;
    scrollAmount = 260.0;
    saveSettings();
    notifyListeners();
  }

  void setHighSensitivityPreset() {
    horizontalSensitivity = 10.0;
    verticalSensitivity = 9.0;
    cursorSpeed = 7.0;
    smoothing = 0.22;
    scrollAmount = 330.0;
    saveSettings();
    notifyListeners();
  }

  void resetSettings() {
    horizontalSensitivity = 14.0;
    verticalSensitivity = 13.0;
    cursorSpeed = 5.0;
    smoothing = 0.16;
    scrollAmount = 260.0;
    blinkEnabled = true;
    doubleBlinkEnabled = true;
    invertHorizontal = false;
    invertVertical = false;
    saveSettings();
    notifyListeners();
  }

  @override
  void dispose() {
    globalScrollController.dispose();
    super.dispose();
  }
}