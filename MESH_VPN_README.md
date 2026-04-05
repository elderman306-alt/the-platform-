# P2P Mesh VPN Module

## Overview
This module provides peer-to-peer mesh networking capabilities for the platform. It enables direct encrypted connections between peers without requiring a central server.

## Features
- **Peer Discovery**: Automatic discovery of peers on the local network
- **UDP-based**: Low-latency communication using UDP protocol
- **Heartbeat Monitoring**: Keep track of peer availability
- **Encrypted Communication**: Support for ChaCha20-Poly1305 encryption
- **Scalable**: Support for up to 50 peers per mesh network

## Installation
```bash
pip install -r requirements.txt
```

## Usage
```python
import asyncio
from mesh_vpn import MeshNetwork, MeshConfig

async def main():
    config = MeshConfig(
        listen_port=51820,
        auto_discover=True,
        max_peers=50
    )
    
    mesh = MeshNetwork(config)
    
    if await mesh.start():
        # Add a peer manually
        mesh.add_peer("192.168.1.100", 51820)
        
        # Get mesh status
        status = mesh.get_mesh_status()
        print(f"Peer ID: {status['peer_id']}")
        print(f"Connected peers: {status['peer_count']}")
        
        # Send data to peer
        await mesh.send_data("peer_id_here", {"message": "Hello!"})
        
        # Broadcast to all peers
        await mesh.broadcast_data({"message": "Hello everyone!"})
        
        await mesh.stop()

if __name__ == "__main__":
    asyncio.run(main())
```

## Configuration
Edit `config/mesh_vpn.conf` to customize:
- Listen port
- Peer discovery settings
- Heartbeat intervals
- Connection timeouts
- Encryption settings

## Protocol
The mesh uses JSON-based messages over UDP:
- `discovery`: Peer discovery broadcast
- `connect`: Connection request
- `heartbeat`: Keepalive messages
- `data`: Application data transfer