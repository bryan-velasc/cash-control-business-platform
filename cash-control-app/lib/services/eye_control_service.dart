import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/eye_control_provider.dart';

class EyeControlService {
  static final EyeControlService instance =
      EyeControlService._internal();

  EyeControlService._internal();

  factory EyeControlService() {
    return instance;
  }

  CameraController? cameraController;
  FaceDetector? faceDetector;

  bool running = false;
  bool processing = false;

  double centerX = 0;
  double centerY = 0;

  double calibrationSumX = 0;
  double calibrationSumY = 0;
  int calibrationFrames = 0;

  bool eyesClosed = false;
  int blinkCount = 0;

  Timer? blinkTimer;

  DateTime? eyesClosedAt;

  DateTime lastScrollTime =
      DateTime.fromMillisecondsSinceEpoch(0);

  DateTime lastStatusUpdate =
      DateTime.fromMillisecondsSinceEpoch(0);

  DateTime lastBlinkActionTime =
      DateTime.fromMillisecondsSinceEpoch(0);

  double lastSmoothedX = 0;
  double lastSmoothedY = 0;

  Future<void> initialize(
    EyeControlProvider provider,
  ) async {
    if (running) {
      provider.updateStatus(
        "Eye Control ya está activo",
      );
      return;
    }

    final permission =
        await Permission.camera.request();

    if (!permission.isGranted) {
      provider.updateStatus(
        "Permiso de cámara denegado",
      );

      provider.disable();

      return;
    }

    provider.enable();
    provider.startCalibration();

    calibrationSumX = 0;
    calibrationSumY = 0;
    calibrationFrames = 0;

    eyesClosed = false;
    blinkCount = 0;
    eyesClosedAt = null;

    lastSmoothedX = provider.cursorPosition.dx;
    lastSmoothedY = provider.cursorPosition.dy;

    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) =>
          camera.lensDirection ==
          CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    cameraController = CameraController(
      frontCamera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await cameraController!.initialize();

    running = true;
    processing = false;

    provider.updateStatus(
      "Calibrando rostro...",
    );

    await cameraController!.startImageStream(
      (image) {
        processFrame(
          image,
          provider,
        );
      },
    );
  }

  Future<void> processFrame(
    CameraImage image,
    EyeControlProvider provider,
  ) async {
    if (processing ||
        !running ||
        !provider.enabled ||
        faceDetector == null) {
      return;
    }

    processing = true;

    try {
      final inputImage =
          _cameraImageToInputImage(
        image,
      );

      if (inputImage == null) {
        processing = false;
        return;
      }

      final faces =
          await faceDetector!.processImage(
        inputImage,
      );

      if (faces.isEmpty) {
        _safeStatus(
          provider,
          "No se detecta rostro",
        );

        processing = false;
        return;
      }

      final face = faces.first;

      final rawX =
          face.headEulerAngleX ?? 0;

      final rawY =
          face.headEulerAngleY ?? 0;

      if (provider.calibrating ||
          !provider.calibrated) {
        _calibrate(
          rawX,
          rawY,
          provider,
        );

        processing = false;
        return;
      }

      _moveCursor(
        rawX,
        rawY,
        provider,
      );

      _detectBlink(
        face.leftEyeOpenProbability,
        face.rightEyeOpenProbability,
        provider,
      );
    } catch (e) {
      provider.updateStatus(
        "Error Eye Control",
      );

      print("EYE CONTROL ERROR:");
      print(e);
    }

    processing = false;
  }

  InputImage? _cameraImageToInputImage(
    CameraImage image,
  ) {
    final format =
        InputImageFormatValue.fromRawValue(
      image.format.raw,
    );

    if (format == null) {
      return null;
    }

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation:
            InputImageRotation.rotation0deg,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void _calibrate(
    double rawX,
    double rawY,
    EyeControlProvider provider,
  ) {
    calibrationSumX += rawX;
    calibrationSumY += rawY;
    calibrationFrames++;

    final progress =
        ((calibrationFrames / 55) * 100)
            .clamp(
              0,
              100,
            )
            .toInt();

    _safeStatus(
      provider,
      "Calibrando rostro $progress%",
    );

    if (calibrationFrames >= 55) {
      centerX =
          calibrationSumX / calibrationFrames;

      centerY =
          calibrationSumY / calibrationFrames;

      lastSmoothedX =
          provider.screenSize.width / 2;

      lastSmoothedY =
          provider.screenSize.height / 2;

      provider.finishCalibration();

      provider.updateCursor(
        Offset(
          lastSmoothedX,
          lastSmoothedY,
        ),
      );

      provider.updateDirection(
        "Centro",
      );

      provider.updateStatus(
        "Eye Control activo",
      );
    }
  }

  void _moveCursor(
    double rawX,
    double rawY,
    EyeControlProvider provider,
  ) {
    double headX = rawX - centerX;
    double headY = rawY - centerY;

    if (provider.invertHorizontal) {
      headY = -headY;
    }

    if (provider.invertVertical) {
      headX = -headX;
    }

    final horizontalSensitivity =
        provider.horizontalSensitivity;

    final verticalSensitivity =
        provider.verticalSensitivity;

    final speed = provider.cursorSpeed;

    final smoothing = provider.smoothing;

    String direction = "Centro";

    double targetX =
        provider.cursorPosition.dx;

    double targetY =
        provider.cursorPosition.dy;

    bool wantsScrollDown = false;
    bool wantsScrollUp = false;

    if (headY > horizontalSensitivity) {
      targetX -= speed;
      direction = "Izquierda";
    } else if (headY < -horizontalSensitivity) {
      targetX += speed;
      direction = "Derecha";
    }

    if (headX > verticalSensitivity) {
      targetY += speed;
      direction = "Abajo";
      wantsScrollDown = true;
    } else if (headX < -verticalSensitivity) {
      targetY -= speed;
      direction = "Arriba";
      wantsScrollUp = true;
    }

    final nearBottom =
        provider.cursorPosition.dy >
            provider.screenSize.height - 150;

    final nearTop =
        provider.cursorPosition.dy < 160;

    if (wantsScrollDown || nearBottom) {
      _requestScrollSafe(
        provider,
        down: true,
      );
    }

    if (wantsScrollUp || nearTop) {
      _requestScrollSafe(
        provider,
        down: false,
      );
    }

    lastSmoothedX =
        provider.cursorPosition.dx +
            ((targetX -
                    provider.cursorPosition.dx) *
                smoothing);

    lastSmoothedY =
        provider.cursorPosition.dy +
            ((targetY -
                    provider.cursorPosition.dy) *
                smoothing);

    provider.updateDirection(
      direction,
    );

    provider.updateCursor(
      Offset(
        lastSmoothedX,
        lastSmoothedY,
      ),
    );

    _safeStatus(
      provider,
      "Eye Control activo",
    );
  }

  void _requestScrollSafe(
    EyeControlProvider provider, {
    required bool down,
  }) {
    final now = DateTime.now();

    if (now.difference(lastScrollTime)
            .inMilliseconds <
        1000) {
      return;
    }

    lastScrollTime = now;

    if (down) {
      provider.scrollDown();
    } else {
      provider.scrollUp();
    }
  }

  void _detectBlink(
    double? left,
    double? right,
    EyeControlProvider provider,
  ) {
    if (!provider.blinkEnabled &&
        !provider.doubleBlinkEnabled) {
      return;
    }

    if (left == null || right == null) {
      return;
    }

    final closed =
        left < 0.18 && right < 0.18;

    final open =
        left > 0.72 && right > 0.72;

    if (closed && !eyesClosed) {
      eyesClosed = true;
      eyesClosedAt = DateTime.now();
      return;
    }

    if (open && eyesClosed) {
      eyesClosed = false;

      if (eyesClosedAt == null) {
        return;
      }

      final closedDuration =
          DateTime.now().difference(
        eyesClosedAt!,
      );

      if (closedDuration.inMilliseconds < 130 ||
          closedDuration.inMilliseconds > 480) {
        return;
      }

      final now = DateTime.now();

      if (now.difference(lastBlinkActionTime)
              .inMilliseconds <
          750) {
        return;
      }

      lastBlinkActionTime = now;

      blinkCount++;

      blinkTimer?.cancel();

      blinkTimer = Timer(
        const Duration(
          milliseconds: 1250,
        ),
        () {
          if (blinkCount >= 2) {
            blinkCount = 0;

            if (provider.doubleBlinkEnabled) {
              provider.requestBack();
            }
          } else if (blinkCount == 1) {
            blinkCount = 0;

            if (provider.blinkEnabled) {
              provider.requestClick();
            }
          }
        },
      );
    }
  }

  void _safeStatus(
    EyeControlProvider provider,
    String status,
  ) {
    final now = DateTime.now();

    if (now.difference(lastStatusUpdate)
            .inMilliseconds <
        500) {
      return;
    }

    lastStatusUpdate = now;

    provider.updateStatus(
      status,
    );
  }

  Future<void> dispose() async {
    running = false;
    processing = false;

    blinkTimer?.cancel();

    try {
      if (cameraController != null &&
          cameraController!.value.isInitialized &&
          cameraController!
              .value.isStreamingImages) {
        await cameraController!
            .stopImageStream();
      }
    } catch (_) {}

    await cameraController?.dispose();

    cameraController = null;

    await faceDetector?.close();

    faceDetector = null;
  }
}