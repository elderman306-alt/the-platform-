import 'dart:math';
import 'dart:typed_data';

/// Kademlia DHT - Distributed Hash Table for peer discovery
class KademliaDHT {
  final String nodeId;
  final Map<String, dynamic> _storage = {};
  final List<String> _peers = [];
  
  KademliaDHT(this.nodeId);

  /// Find peers closest to key
  Future<List<String>> findPeers(String key) async {
    // Calculate distance to all known peers
    final distances = _peers.map((peer) => MapEntry(
      peer,
      _xorDistance(key, peer),
    )).toList();
    
    // Sort by distance (closest first)
    distances.sort((a, b) => a.value.compareTo(b.value));
    
    // Return top K closest peers
    return distances.take(3).map((e) => e.key).toList();
  }

  /// Store key-value in DHT
  Future<void> store(String key, String value) async {
    _storage[key] = value;
  }

  /// Retrieve value by key
  Future<String?> retrieve(String key) async {
    return _storage[key];
  }

  /// Add peer to routing table
  Future<void> addPeer(String peerId) async {
    if (!_peers.contains(peerId)) {
      _peers.add(peerId);
    }
  }

  /// Remove peer from routing table
  Future<void> removePeer(String peerId) async {
    _peers.remove(peerId);
  }

  /// XOR distance between two keys
  int _xorDistance(String key1, String key2) {
    final hash1 = key1.hashCode;
    final hash2 = key2.hashCode;
    return hash1 ^ hash2;
  }

  /// Get all known peers
  List<String> get peers => List.unmodifiable(_peers);

  /// Get storage size
  int get storageSize => _storage.length;
}

/// Peer node in Kademlia network
class PeerNode {
  final String id;
  final String address;
  final int port;
  final DateTime lastSeen;

  PeerNode({
    required this.id,
    required this.address,
    required this.port,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'address': address,
    'port': port,
    'lastSeen': lastSeen.toIso8601String(),
  };

  factory PeerNode.fromJson(Map<String, dynamic> json) => PeerNode(
    id: json['id'],
    address: json['address'],
    port: json['port'],
    lastSeen: DateTime.parse(json['lastSeen']),
  );
}