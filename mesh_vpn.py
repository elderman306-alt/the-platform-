"""
P2P Mesh VPN - Core Module
Provides peer-to-peer mesh networking capabilities for the platform.
"""

import asyncio
import hashlib
import json
import logging
import os
import socket
import struct
import secrets
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set, Tuple
from enum import Enum

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class PeerState(Enum):
    DISCONNECTED = "disconnected"
    CONNECTING = "connecting"
    CONNECTED = "connected"
    AUTHENTICATED = "authenticated"


@dataclass
class Peer:
    """Represents a peer in the mesh network."""
    peer_id: str
    address: str
    port: int
    public_key: Optional[bytes] = None
    state: PeerState = PeerState.DISCONNECTED
    last_seen: float = field(default_factory=os.time.time)
    latency_ms: int = 0
    trusted: bool = False


@dataclass
class MeshConfig:
    """Configuration for the mesh VPN."""
    listen_port: int = 51820
    peers: List[str] = field(default_factory=list)
    auto_discover: bool = True
    max_peers: int = 50
    heartbeat_interval: int = 30
    connection_timeout: int = 10
    encryption: str = "chacha20poly1305"


class MeshNetwork:
    """Main mesh network manager."""
    
    def __init__(self, config: MeshConfig):
        self.config = config
        self.peers: Dict[str, Peer] = {}
        self.peer_id = self._generate_peer_id()
        self.running = False
        self._socket: Optional[socket.socket] = None
        
    def _generate_peer_id(self) -> str:
        """Generate a unique peer ID based on hostname and random data."""
        random_bytes = secrets.token_hex(8)
        hostname = socket.gethostname()
        raw_id = f"{hostname}-{random_bytes}"
        return hashlib.sha256(raw_id.encode()).hexdigest()[:16]
    
    async def start(self) -> bool:
        """Start the mesh network."""
        try:
            self._socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self._socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self._socket.bind(('0.0.0.0', self.config.listen_port))
            self._socket.settimeout(1.0)
            
            self.running = True
            logger.info(f"Mesh VPN started on port {self.config.listen_port}")
            logger.info(f"Peer ID: {self.peer_id}")
            
            # Start background tasks
            asyncio.create_task(self._heartbeat_loop())
            asyncio.create_task(self._peer_discovery_loop())
            asyncio.create_task(self._message_handler())
            
            return True
        except Exception as e:
            logger.error(f"Failed to start mesh network: {e}")
            return False
    
    async def stop(self):
        """Stop the mesh network."""
        self.running = False
        if self._socket:
            self._socket.close()
            self._socket = None
        logger.info("Mesh VPN stopped")
    
    async def _heartbeat_loop(self):
        """Send periodic heartbeats to connected peers."""
        while self.running:
            await asyncio.sleep(self.config.heartbeat_interval)
            await self._send_heartbeats()
    
    async def _peer_discovery_loop(self):
        """Discover new peers on the network."""
        while self.running and self.config.auto_discover:
            await asyncio.sleep(10)
            await self._discover_peers()
    
    async def _message_handler(self):
        """Handle incoming messages."""
        while self.running:
            try:
                data, addr = self._socket.recvfrom(4096)
                await self._process_message(data, addr)
            except socket.timeout:
                continue
            except Exception as e:
                logger.error(f"Error processing message: {e}")
    
    async def _send_heartbeats(self):
        """Send heartbeats to all connected peers."""
        for peer_id, peer in self.peers.items():
            if peer.state == PeerState.CONNECTED:
                message = self._create_message("heartbeat", {"peer_id": self.peer_id})
                self._send_to_peer(peer, message)
    
    async def _discover_peers(self):
        """Broadcast peer discovery messages."""
        message = self._create_message("discovery", {"peer_id": self.peer_id})
        self._broadcast(message)
    
    def _create_message(self, msg_type: str, payload: dict) -> bytes:
        """Create a structured message packet."""
        data = {
            "type": msg_type,
            "sender_id": self.peer_id,
            "payload": payload
        }
        return json.dumps(data).encode('utf-8')
    
    async def _process_message(self, data: bytes, addr: Tuple[str, int]):
        """Process incoming messages."""
        try:
            message = json.loads(data.decode('utf-8'))
            msg_type = message.get("type")
            sender_id = message.get("sender_id")
            
            if msg_type == "discovery":
                await self._handle_discovery(sender_id, addr)
            elif msg_type == "connect":
                await self._handle_connect(sender_id, message.get("payload", {}))
            elif msg_type == "heartbeat":
                await self._handle_heartbeat(sender_id)
            elif msg_type == "data":
                await self._handle_data(sender_id, message.get("payload", {}))
                
        except Exception as e:
            logger.error(f"Error processing message: {e}")
    
    async def _handle_discovery(self, sender_id: str, addr: Tuple[str, int]):
        """Handle peer discovery messages."""
        if sender_id not in self.peers:
            peer = Peer(
                peer_id=sender_id,
                address=addr[0],
                port=self.config.listen_port,
                state=PeerState.CONNECTING
            )
            self.peers[sender_id] = peer
            logger.info(f"Discovered new peer: {sender_id}")
            
            # Send response
            message = self._create_message("connect", {
                "peer_id": self.peer_id,
                "port": self.config.listen_port
            })
            self._send_to_peer(peer, message)
    
    async def _handle_connect(self, sender_id: str, payload: dict):
        """Handle peer connection requests."""
        if sender_id in self.peers:
            peer = self.peers[sender_id]
            peer.state = PeerState.CONNECTED
            logger.info(f"Peer connected: {sender_id}")
    
    async def _handle_heartbeat(self, sender_id: str):
        """Handle heartbeat messages."""
        if sender_id in self.peers:
            self.peers[sender_id].last_seen = os.time.time()
    
    async def _handle_data(self, sender_id: str, payload: dict):
        """Handle data messages."""
        logger.debug(f"Received data from {sender_id}: {payload}")
    
    def _send_to_peer(self, peer: Peer, message: bytes):
        """Send a message to a specific peer."""
        try:
            self._socket.sendto(message, (peer.address, peer.port))
        except Exception as e:
            logger.error(f"Error sending to peer {peer.peer_id}: {e}")
    
    def _broadcast(self, message: bytes):
        """Broadcast a message to all peers."""
        for peer in self.peers.values():
            self._send_to_peer(peer, message)
    
    def add_peer(self, address: str, port: int, trusted: bool = False) -> str:
        """Manually add a peer to connect to."""
        peer_id = hashlib.sha256(f"{address}:{port}".encode()).hexdigest()[:16]
        peer = Peer(
            peer_id=peer_id,
            address=address,
            port=port,
            trusted=trusted,
            state=PeerState.CONNECTING
        )
        self.peers[peer_id] = peer
        logger.info(f"Added peer: {peer_id} at {address}:{port}")
        return peer_id
    
    def remove_peer(self, peer_id: str) -> bool:
        """Remove a peer from the mesh."""
        if peer_id in self.peers:
            del self.peers[peer_id]
            logger.info(f"Removed peer: {peer_id}")
            return True
        return False
    
    def get_peers(self) -> List[Peer]:
        """Get all peers in the mesh."""
        return list(self.peers.values())
    
    def get_peer(self, peer_id: str) -> Optional[Peer]:
        """Get a specific peer."""
        return self.peers.get(peer_id)
    
    async def send_data(self, peer_id: str, data: dict) -> bool:
        """Send data to a specific peer."""
        peer = self.peers.get(peer_id)
        if peer and peer.state == PeerState.CONNECTED:
            message = self._create_message("data", data)
            self._send_to_peer(peer, message)
            return True
        return False
    
    async def broadcast_data(self, data: dict) -> int:
        """Broadcast data to all connected peers."""
        message = self._create_message("data", data)
        count = 0
        for peer in self.peers.values():
            if peer.state == PeerState.CONNECTED:
                self._send_to_peer(peer, message)
                count += 1
        return count
    
    def get_mesh_status(self) -> dict:
        """Get current mesh network status."""
        return {
            "peer_id": self.peer_id,
            "running": self.running,
            "peer_count": len(self.peers),
            "peers": [
                {
                    "peer_id": p.peer_id,
                    "address": p.address,
                    "port": p.port,
                    "state": p.state.value,
                    "trusted": p.trusted,
                    "latency_ms": p.latency_ms
                }
                for p in self.peers.values()
            ]
        }


# Example usage
async def main():
    config = MeshConfig(
        listen_port=51820,
        auto_discover=True,
        max_peers=50
    )
    
    mesh = MeshNetwork(config)
    
    if await mesh.start():
        logger.info("Mesh network running. Press Ctrl+C to stop.")
        
        # Add some example peers
        mesh.add_peer("10.0.0.1", 51820)
        mesh.add_peer("10.0.0.2", 51820)
        
        # Print status
        status = mesh.get_mesh_status()
        logger.info(f"Mesh status: {json.dumps(status, indent=2)}")
        
        # Keep running
        try:
            while True:
                await asyncio.sleep(30)
                logger.info(f"Connected peers: {len(mesh.get_peers())}")
        except KeyboardInterrupt:
            pass
        finally:
            await mesh.stop()
    else:
        logger.error("Failed to start mesh network")


if __name__ == "__main__":
    asyncio.run(main())