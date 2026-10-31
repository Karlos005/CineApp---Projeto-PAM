import 'dart:convert';

import 'package:flutter/material.dart';

/// A foto de perfil é guardada no Firestore como Base64 (data URI), por isso
/// aqui convertemos essa string para bytes para conseguirmos mostrar a imagem.
ImageProvider? resolvePhotoImage(String? photoUrl) {
  if (photoUrl == null || photoUrl.isEmpty) return null;
  if (photoUrl.startsWith('data:image')) {
    final base64Data = photoUrl.substring(photoUrl.indexOf(',') + 1);
    return MemoryImage(base64Decode(base64Data));
  }
  return NetworkImage(photoUrl);
}

/// Avatar do utilizador: mostra a foto de perfil quando existe, ou a
/// inicial do nome como fallback.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.radius,
    required this.photoUrl,
    required this.displayName,
  });

  final double radius;
  final String? photoUrl;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: cs.surfaceContainerHighest,
      backgroundImage: resolvePhotoImage(photoUrl),
      child: (photoUrl?.isNotEmpty == true)
          ? null
          : Text(
              (displayName?.isNotEmpty == true)
                  ? displayName![0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: radius * 0.82,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
    );
  }
}