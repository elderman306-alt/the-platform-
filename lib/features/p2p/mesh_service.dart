import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Message types for P2P communication
enum P2PMessageType {
  discovery,
  connect,
  heartbeat,
  data,
  ack,
  disconnect,
}

/// Peer connection state
enum PeerState {
  disconnected,
  connecting,
  connected,
  authenticated,
}

/// Represents a peer in the mesh network
class Peer {
  final String peerId;
  final String address;
  final int port;
  PeerState state;
  DateTime lastSeen;
  int latencyMs;
  bool trusted;
  Uint8List? publicKey;

  Peer({
    required this.peerId,
    required this.address,
    required this.port,
    this.state = PeerState.disconnected,
    DateTime? lastSeen,
    this.latencyMs = 0,
    this.trusted = false,
    this.publicKey,
  }) : lastSeen = lastSeen ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'peerId': peerId,
        'address': address,
        'port': port,
        'state': state.name,
        'lastSeen': lastSeen.toIso8601String(),
        'latencyMs': latencyMs,
        'trusted': trusted,
      };

  factory Peer.fromJson(Map<String, dynamic> json) => Peer(
        peerId: json['peerId'] as String,
        address: json['address'] as String,
        port: json['port'] as int,
        state: PeerState.values.firstWhere(
          (e) => e.name == json['state'],
          orElse: () => PeerState.disconnected,
        ),
        lastSeen: DateTime.parse(json['lastSeen'] as String),
        latencyMs: json['latencyMs'] as int? ?? 0,
        trusted: json['trusted'] as bool? ?? false,
      );
}

/// Configuration for mesh networking
class MeshConfig {
  final int listenPort;
  final bool autoDiscover;
  final int maxPeers;
  final int heartbeatIntervalSeconds;
  final int connectionTimeoutSeconds;
  final String encryption;

  const MeshConfig({
    this.listenPort = 51820,
    this.autoDiscover = true,
    this.maxPeers = 50,
    this.heartbeatIntervalSeconds = 30,
    this.connectionTimeoutSeconds = 10,
    this.encryption = 'chacha20poly1305',
  });
}

/// P2P Mesh Network Service
class MeshService {
  final MeshConfig config;
  final String _selfId;
  final Map<String, Peer> _peers = {};
  bool _running = false;
  Timer? _heartbeatTimer;
  Timer? _discoveryTimer;
  
  final _peerController = StreamController<List<Peer>>.broadcast();
  final _messageController = StreamController<P2PMessage>.broadcast();

  MeshService({MeshConfig? config})
      : config = config ?? const MeshConfig(),
        _selfId = _generateId();

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random(timestamp).nextInt(999999);
    final input = 'mesh-$timestamp-$random';
    return sha256.convert(utf8.encode(input)).toString().substring(0, 16);
  }

  String get selfId => _selfId;
  bool get isRunning => _running;
  int get peerCount => _peers.length;

  Stream<List<Peer>> get peerStream => _peerController.stream;
  Stream<P2PMessage> get messageStream => _messageController.stream;

  List<Peer> get peers => _peers.values.toList();

  Peer? getPeer(String peerId) => _peers[peerId];

  /// Start the mesh network
  Future<bool> start() async {
    if (_running) return true;
    
    _running = true;
    _startHeartbeatLoop();
    _startDiscoveryLoop();
    
    return true;
  }

  /// Stop the mesh network
  Future<void> stop() async {
    _running = false;
    _heartbeatTimer?.cancel();
    _discoveryTimer?.cancel();
    _peers.clear();
  }

  void _startHeartbeatLoop() {
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: config.heartbeatIntervalSeconds),
      (_) => _sendHeartbeats(),
    );
  }

  void _startDiscoveryLoop() {
    if (config.autoDiscover) {
      _discoveryTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _broadcastDiscovery(),
      );
    }
  }

  Future<void> _sendHeartbeats() async {
    for (final peer in _peers.values) {
      if (peer.state == PeerState.connected) {
        await _sendMessage(peer, P2PMessage(
          type: P2PMessageType.heartbeat,
          senderId: _selfId,
          payload: {'timestamp': DateTime.now().toIso8601String()},
        ));
      }
    }
  }

  Future<void> _broadcastDiscovery() async {
    // Broadcast discovery to discover new peers
    debugPrint('Broadcasting peer discovery...');
  }

  Future<void> _sendMessage(Peer peer, P2PMessage message) async {
    // Simulate sending message
    debugPrint('Sending ${message.type.name} to ${peer.peerId}');
  }

  /// Add a peer manually
  String addPeer(String address, int port, {bool trusted = false}) {
    final peerId = sha256.convert(utf8.encode('$address:$port')).toString().substring(0, 16);
    final peer = Peer(
      peerId: peerId,
      address: address,
      port: port,
      state: PeerState.connecting,
      trusted: trusted,
    );
    _peers[peerId] = peer;
    _peerController.add(peers);
    return peerId;
  }

  /// Remove a peer
  bool removePeer(String peerId) {
    final removed = _peers.remove(peerId);
    if (removed != null) {
      _peerController.add(peers);
    }
    return removed != null;
  }

  /// Send data to a specific peer
  Future<bool> sendData(String peerId, Map<String, dynamic> data) async {
    final peer = _peers[peerId];
    if (peer == null || peer.state != PeerState.connected) {
      return false;
    }

    await _sendMessage(peer, P2PMessage(
      type: P2PMessageType.data,
      senderId: _selfId,
      payload: data,
    ));
    return true;
  }

  /// Broadcast data to all connected peers
  Future<int> broadcastData(Map<String, dynamic> data) async {
    int count = 0;
    for (final peer in _peers.values) {
      if (peer.state == PeerState.connected) {
        await sendData(peer.peerId, data);
        count++;
      }
    }
    return count;
  }

  /// Get mesh status
  Map<String, dynamic> getMeshStatus() => {
    'peerId': _selfId,
    'running': _running,
    'peerCount': _peers.length,
    'config': {
      'listenPort': config.listenPort,
      'autoDiscover': config.autoDiscover,
      'maxPeers': config.maxPeers,
    },
    'peers': peers.map((p) => p.toJson()).toList(),
  };
}

/// P2P Message structure
class P2PMessage {
  final P2PMessageType type;
  final String senderId;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  P2PMessage({
    required this.type,
    required this.senderId,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'senderId': senderId,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
  };

  factory P2PMessage.fromJson(Map<String, dynamic> json) => P2PMessage(
    type: P2PMessageType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => P2PMessageType.data,
    ),
    senderId: json['senderId'] as String,
    payload: json['payload'] as Map<String, dynamic>,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}