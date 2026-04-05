"""
Communication Service Module
AI #4 - Communication Component

This module provides real-time communication capabilities for the platform.
"""

import json
from datetime import datetime
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, field
from enum import Enum


class MessageType(Enum):
    TEXT = "text"
    IMAGE = "image"
    FILE = "file"
    VOICE = "voice"
    VIDEO = "video"
    SYSTEM = "system"


class ChannelType(Enum):
    DIRECT = "direct"
    GROUP = "group"
    BROADCAST = "broadcast"
    CHANNEL = "channel"


@dataclass
class Message:
    message_id: str
    sender_id: str
    channel_id: str
    message_type: MessageType
    content: str
    timestamp: datetime = field(default_factory=datetime.now)
    metadata: Dict[str, Any] = field(default_factory=dict)
    reactions: List[str] = field(default_factory=list)
    reply_to: Optional[str] = None
    is_edited: bool = False
    is_deleted: bool = False


@dataclass
class Channel:
    channel_id: str
    name: str
    channel_type: ChannelType
    created_at: datetime = field(default_factory=datetime.now)
    members: List[str] = field(default_factory=list)
    description: str = ""
    is_private: bool = False
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class User:
    user_id: str
    username: str
    display_name: str
    email: str
    status: str = "offline"
    avatar_url: Optional[str] = None
    last_seen: Optional[datetime] = None


class CommunicationService:
    """
    Main communication service for handling messages and channels.
    """

    def __init__(self):
        self.messages: Dict[str, Message] = {}
        self.channels: Dict[str, Channel] = {}
        self.users: Dict[str, User] = {}
        self.message_counter = 0
        self.channel_counter = 0

    def create_user(self, user_id: str, username: str, display_name: str, email: str) -> User:
        """Create a new user."""
        user = User(
            user_id=user_id,
            username=username,
            display_name=display_name,
            email=email
        )
        self.users[user_id] = user
        return user

    def create_channel(
        self,
        name: str,
        channel_type: ChannelType,
        members: List[str],
        description: str = "",
        is_private: bool = False
    ) -> Channel:
        """Create a new channel."""
        self.channel_counter += 1
        channel = Channel(
            channel_id=f"ch_{self.channel_counter}",
            name=name,
            channel_type=channel_type,
            members=members,
            description=description,
            is_private=is_private
        )
        self.channels[channel.channel_id] = channel
        return channel

    def send_message(
        self,
        sender_id: str,
        channel_id: str,
        message_type: MessageType,
        content: str,
        metadata: Optional[Dict[str, Any]] = None,
        reply_to: Optional[str] = None
    ) -> Message:
        """Send a message to a channel."""
        if channel_id not in self.channels:
            raise ValueError(f"Channel {channel_id} does not exist")

        if sender_id not in self.users:
            raise ValueError(f"User {sender_id} does not exist")

        self.message_counter += 1
        message = Message(
            message_id=f"msg_{self.message_counter}",
            sender_id=sender_id,
            channel_id=channel_id,
            message_type=message_type,
            content=content,
            metadata=metadata or {},
            reply_to=reply_to
        )
        self.messages[message.message_id] = message
        return message

    def get_channel_messages(self, channel_id: str, limit: int = 50) -> List[Message]:
        """Get messages from a channel."""
        if channel_id not in self.channels:
            raise ValueError(f"Channel {channel_id} does not exist")

        messages = [
            msg for msg in self.messages.values()
            if msg.channel_id == channel_id and not msg.is_deleted
        ]
        messages.sort(key=lambda m: m.timestamp, reverse=True)
        return messages[:limit]

    def edit_message(self, message_id: str, new_content: str) -> Message:
        """Edit an existing message."""
        if message_id not in self.messages:
            raise ValueError(f"Message {message_id} does not exist")

        message = self.messages[message_id]
        message.content = new_content
        message.is_edited = True
        return message

    def delete_message(self, message_id: str) -> None:
        """Mark a message as deleted."""
        if message_id not in self.messages:
            raise ValueError(f"Message {message_id} does not exist")

        self.messages[message_id].is_deleted = True

    def add_reaction(self, message_id: str, emoji: str) -> None:
        """Add a reaction to a message."""
        if message_id not in self.messages:
            raise ValueError(f"Message {message_id} does not exist")

        if emoji not in self.messages[message_id].reactions:
            self.messages[message_id].reactions.append(emoji)

    def get_user_status(self, user_id: str) -> Optional[str]:
        """Get user's online status."""
        user = self.users.get(user_id)
        return user.status if user else None

    def set_user_status(self, user_id: str, status: str) -> None:
        """Set user's online status."""
        if user_id in self.users:
            self.users[user_id].status = status

    def to_json(self) -> str:
        """Export service data as JSON."""
        data = {
            "users": {
                uid: {
                    "user_id": u.user_id,
                    "username": u.username,
                    "display_name": u.display_name,
                    "email": u.email,
                    "status": u.status,
                    "avatar_url": u.avatar_url
                }
                for uid, u in self.users.items()
            },
            "channels": {
                cid: {
                    "channel_id": c.channel_id,
                    "name": c.name,
                    "channel_type": c.channel_type.value,
                    "members": c.members,
                    "description": c.description,
                    "is_private": c.is_private
                }
                for cid, c in self.channels.items()
            },
            "message_count": self.message_counter
        }
        return json.dumps(data, indent=2, default=str)


# Demo usage
if __name__ == "__main__":
    service = CommunicationService()

    # Create users
    user1 = service.create_user("u1", "alice", "Alice Smith", "alice@example.com")
    user2 = service.create_user("u2", "bob", "Bob Johnson", "bob@example.com")

    # Create channel
    channel = service.create_channel(
        "General",
        ChannelType.GROUP,
        members=["u1", "u2"],
        description="General discussion channel"
    )

    # Send messages
    msg1 = service.send_message("u1", channel.channel_id, MessageType.TEXT, "Hello everyone!")
    msg2 = service.send_message("u2", channel.channel_id, MessageType.TEXT, "Hi Alice!")

    # Add reaction
    service.add_reaction(msg1.message_id, "👋")

    # Print results
    print("Communication Service Demo")
    print("=" * 40)
    print(f"Users: {len(service.users)}")
    print(f"Channels: {len(service.channels)}")
    print(f"Messages: {service.message_counter}")
    print("\nJSON Export:")
    print(service.to_json())