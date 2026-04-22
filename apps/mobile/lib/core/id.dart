import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a UUIDv7 — time-ordered, safe for client-side generation,
/// used for idempotent sync (same ID on client and server).
String newId() => _uuid.v7();
