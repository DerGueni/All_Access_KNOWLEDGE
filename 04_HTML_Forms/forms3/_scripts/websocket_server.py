# -*- coding: utf-8 -*-
"""
WebSocket Server fuer CONSYS Echtzeit-Updates
Port: 5001

Starten: python websocket_server.py

Events:
- auftrag:updated - Auftrag wurde geaendert
- zuordnung:created - Neue MA-Zuordnung
- zuordnung:deleted - Zuordnung entfernt
- anfrage:sent - Anfrage gesendet
- anfrage:response - Antwort eingegangen
"""

import asyncio
import json
import logging
from datetime import datetime
from typing import Set, Dict, Any
from aiohttp import web
import aiohttp

# Logging konfigurieren
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [WS] %(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)

# Verbundene Clients
connected_clients: Set[web.WebSocketResponse] = set()

# Raeume (fuer Multi-User Updates)
rooms: Dict[str, Set[web.WebSocketResponse]] = {}


async def websocket_handler(request):
    """WebSocket Connection Handler"""
    ws = web.WebSocketResponse()
    await ws.prepare(request)

    connected_clients.add(ws)
    client_id = id(ws)
    logger.info(f"Client {client_id} verbunden. Gesamt: {len(connected_clients)}")

    try:
        async for msg in ws:
            if msg.type == aiohttp.WSMsgType.TEXT:
                try:
                    data = json.loads(msg.data)
                    await handle_message(ws, data)
                except json.JSONDecodeError:
                    logger.warning(f"Ungueltige JSON-Nachricht: {msg.data[:100]}")

            elif msg.type == aiohttp.WSMsgType.ERROR:
                logger.error(f"WebSocket Fehler: {ws.exception()}")

    finally:
        connected_clients.discard(ws)
        # Aus allen Raeumen entfernen
        for room_clients in rooms.values():
            room_clients.discard(ws)
        logger.info(f"Client {client_id} getrennt. Gesamt: {len(connected_clients)}")

    return ws


async def handle_message(ws: web.WebSocketResponse, data: Dict[str, Any]):
    """Eingehende Nachricht verarbeiten"""
    msg_type = data.get('type', '')

    if msg_type == 'ping':
        # Heartbeat beantworten
        await ws.send_json({'type': 'pong', 'timestamp': datetime.now().isoformat()})

    elif msg_type == 'join':
        # Raum beitreten
        room = data.get('data', {}).get('room')
        if room:
            if room not in rooms:
                rooms[room] = set()
            rooms[room].add(ws)
            logger.info(f"Client tritt Raum '{room}' bei")

    elif msg_type == 'leave':
        # Raum verlassen
        room = data.get('data', {}).get('room')
        if room and room in rooms:
            rooms[room].discard(ws)
            logger.info(f"Client verlaesst Raum '{room}'")

    elif msg_type == 'broadcast':
        # Nachricht an alle senden
        await broadcast(data.get('data', {}))

    elif msg_type == 'room_broadcast':
        # Nachricht an Raum senden
        room = data.get('data', {}).get('room')
        message = data.get('data', {}).get('message')
        if room and message:
            await broadcast_to_room(room, message)

    else:
        # Unbekannter Typ - loggen
        logger.debug(f"Unbekannter Nachrichtentyp: {msg_type}")


async def broadcast(message: Dict[str, Any], exclude: web.WebSocketResponse = None):
    """Nachricht an alle verbundenen Clients senden"""
    if not connected_clients:
        return

    payload = json.dumps(message)
    tasks = []

    for client in connected_clients:
        if client != exclude and not client.closed:
            tasks.append(client.send_str(payload))

    if tasks:
        await asyncio.gather(*tasks, return_exceptions=True)
        logger.info(f"Broadcast an {len(tasks)} Clients: {message.get('type', 'unknown')}")


async def broadcast_to_room(room: str, message: Dict[str, Any]):
    """Nachricht an alle Clients in einem Raum senden"""
    if room not in rooms:
        return

    payload = json.dumps(message)
    tasks = []

    for client in rooms[room]:
        if not client.closed:
            tasks.append(client.send_str(payload))

    if tasks:
        await asyncio.gather(*tasks, return_exceptions=True)
        logger.info(f"Room-Broadcast an {len(tasks)} Clients in '{room}'")


# =====================================================
# HTTP API fuer Server-seitige Events
# =====================================================

async def emit_event(request):
    """
    HTTP Endpoint zum Senden von Events
    POST /emit
    Body: { "type": "auftrag:updated", "data": { "va_id": 123 } }
    """
    try:
        data = await request.json()
        event_type = data.get('type')
        event_data = data.get('data', {})

        if not event_type:
            return web.json_response({'error': 'type required'}, status=400)

        message = {
            'type': event_type,
            'data': event_data,
            'timestamp': datetime.now().isoformat()
        }

        await broadcast(message)

        return web.json_response({
            'success': True,
            'clients': len(connected_clients)
        })

    except Exception as e:
        logger.error(f"Emit-Fehler: {e}")
        return web.json_response({'error': str(e)}, status=500)


async def health_check(request):
    """Health Check Endpoint"""
    return web.json_response({
        'status': 'ok',
        'clients': len(connected_clients),
        'rooms': list(rooms.keys()),
        'timestamp': datetime.now().isoformat()
    })


async def get_stats(request):
    """Statistik-Endpoint"""
    return web.json_response({
        'connected_clients': len(connected_clients),
        'rooms': {room: len(clients) for room, clients in rooms.items()},
        'timestamp': datetime.now().isoformat()
    })


# =====================================================
# CORS Middleware
# =====================================================

@web.middleware
async def cors_middleware(request, handler):
    """CORS Headers hinzufuegen"""
    if request.method == 'OPTIONS':
        response = web.Response()
    else:
        response = await handler(request)

    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'

    return response


# =====================================================
# App erstellen und starten
# =====================================================

def create_app():
    """App erstellen"""
    app = web.Application(middlewares=[cors_middleware])

    # Routes
    app.router.add_get('/ws', websocket_handler)
    app.router.add_get('/health', health_check)
    app.router.add_get('/stats', get_stats)
    app.router.add_post('/emit', emit_event)
    app.router.add_options('/emit', lambda r: web.Response())

    return app


if __name__ == '__main__':
    app = create_app()

    print("=" * 50)
    print("CONSYS WebSocket Server")
    print("=" * 50)
    print(f"WebSocket: ws://localhost:5001/ws")
    print(f"Health:    http://localhost:5001/health")
    print(f"Emit:      POST http://localhost:5001/emit")
    print("=" * 50)

    web.run_app(app, host='localhost', port=5001)
