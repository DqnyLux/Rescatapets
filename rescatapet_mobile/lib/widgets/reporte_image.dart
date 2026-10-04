import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/reporte.dart';
import '../theme/app_theme.dart';

class ReporteImage extends StatelessWidget {
  final String imagenData;
  final double width;
  final double height;
  final BoxFit fit;

  const ReporteImage({
    super.key,
    required this.imagenData,
    this.width = double.infinity,
    this.height = 200,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imagenData.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.withValues(alpha: 0.2),
        child: const Icon(Icons.pets, size: 50, color: Colors.grey),
      );
    }

    if (imagenData.startsWith('data:image') || imagenData.length > 500) {
      try {
        final pureBase64 = imagenData.contains(',')
            ? imagenData.split(',').last
            : imagenData;
        return Image.memory(
          base64Decode(pureBase64),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (c, e, s) => _errorFallback(),
        );
      } catch (e) {
        return _errorFallback();
      }
    }

    if (imagenData.startsWith('http')) {
      return Image.network(
        imagenData,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (c, e, s) => _errorFallback(),
      );
    }

    if (imagenData.startsWith('/') || imagenData.startsWith('C:')) {
      return Image.file(
        File(imagenData),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (c, e, s) => _errorFallback(),
      );
    }

    return _errorFallback();
  }

  Widget _errorFallback() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.alertCoral.withValues(alpha: 0.1),
      child: const Icon(Icons.broken_image_rounded, color: AppTheme.alertCoral),
    );
  }
}
