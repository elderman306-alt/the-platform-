/// Communication feature - Chat, Voice, Video calls
/// 
/// This module provides:
/// - E2E encrypted messaging
/// - Voice and video calls (including caller pays mode)
/// - Screen sharing
/// - Group calls (up to 50 participants)
library;

// Export chat domain entities
export 'chat/domain/entities.dart';

// Export chat data layer
export 'chat/data/chat_repository.dart';

// Export chat presentation
export 'chat/presentation/chat_screens.dart';

// Export call services
export 'calls/domain/call_service.dart';

// Export call screens
export 'calls/presentation/call_screens.dart';