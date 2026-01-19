# -*- coding: utf-8 -*-
"""
CONSEC HTML Realtime Server
============================
WebSocket-Server fuer bidirektionale Echtzeit-Kommunikation zwischen
HTML-Formularen und Access-Backend.

Features:
- WebSocket fuer Echtzeit-Updates
- REST API fuer CRUD-Operationen
- Automatische Synchronisation
- Audit-Trail / Aenderungshistorie
- Datei-Upload Support

Aufruf: python html_realtime_server.py [--port 8765]
"""

import asyncio
import websockets
import json
import os
import sys
import time
import hashlib
import shutil
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Set, Any, Optional
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import threading
import pyodbc

# Konfiguration
CONFIG = {
    "WEBSOCKET_PORT": 8765,
    "HTTP_PORT": 8080,
    "BACKEND_PATH": r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_BE_N_Test_Claude_GPT.accdb",
    "HTML_PATH": r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML",
    "DATA_PATH": r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\data",
    "UPLOAD_PATH": r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\uploads",
    "LOG_PATH": r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\logs",
    "AUDIT_PATH": r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\audit",
}

# Globale Variablen
connected_clients: Set[websockets.WebSocketServerProtocol] = set()
data_cache: Dict[str, Any] = {}
last_sync: Dict[str, float] = {}


class AuditTrail:
    """Protokollierung aller Aenderungen"""

    def __init__(self, audit_path: str):
        self.audit_path = Path(audit_path)
        self.audit_path.mkdir(parents=True, exist_ok=True)
        self.current_file = None
        self.current_date = None
        self._init_daily_file()

    def _init_daily_file(self):
        """Erstellt/oeffnet die taegliche Audit-Datei"""
        today = datetime.now().strftime("%Y-%m-%d")
        if today != self.current_date:
            self.current_date = today
            self.current_file = self.audit_path / f"audit_{today}.json"
            if not self.current_file.exists():
                self._write_json([])

    def _read_json(self) -> List[Dict]:
        """Liest die aktuelle Audit-Datei"""
        try:
            with open(self.current_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except:
            return []

    def _write_json(self, data: List[Dict]):
        """Schreibt die Audit-Datei"""
        with open(self.current_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    def log(self, action: str, entity_type: str, entity_id: Any,
            user: str = "System", old_data: Dict = None, new_data: Dict = None,
            details: str = None):
        """Protokolliert eine Aenderung"""
        self._init_daily_file()

        entry = {
            "timestamp": datetime.now().isoformat(),
            "action": action,  # CREATE, UPDATE, DELETE, VIEW
            "entity_type": entity_type,  # MITARBEITER, KUNDE, AUFTRAG, etc.
            "entity_id": entity_id,
            "user": user,
            "details": details
        }

        if old_data:
            entry["old_data"] = old_data
        if new_data:
            entry["new_data"] = new_data

        # Diff berechnen wenn beide vorhanden
        if old_data and new_data:
            entry["changes"] = self._calc_diff(old_data, new_data)

        entries = self._read_json()
        entries.append(entry)
        self._write_json(entries)

        return entry

    def _calc_diff(self, old: Dict, new: Dict) -> List[Dict]:
        """Berechnet die Unterschiede zwischen zwei Datensaetzen"""
        changes = []
        all_keys = set(old.keys()) | set(new.keys())

        for key in all_keys:
            old_val = old.get(key)
            new_val = new.get(key)

            if old_val != new_val:
                changes.append({
                    "field": key,
                    "old": old_val,
                    "new": new_val
                })

        return changes

    def get_history(self, entity_type: str = None, entity_id: Any = None,
                    from_date: str = None, to_date: str = None,
                    limit: int = 100) -> List[Dict]:
        """Holt die Aenderungshistorie mit Filtern"""
        results = []

        # Alle Audit-Dateien durchsuchen
        for audit_file in sorted(self.audit_path.glob("audit_*.json"), reverse=True):
            # Datumsfilter auf Dateinamen anwenden
            file_date = audit_file.stem.replace("audit_", "")
            if from_date and file_date < from_date:
                continue
            if to_date and file_date > to_date:
                continue

            try:
                with open(audit_file, 'r', encoding='utf-8') as f:
                    entries = json.load(f)

                for entry in reversed(entries):
                    # Filter anwenden
                    if entity_type and entry.get("entity_type") != entity_type:
                        continue
                    if entity_id and str(entry.get("entity_id")) != str(entity_id):
                        continue

                    results.append(entry)

                    if len(results) >= limit:
                        return results
            except:
                pass

        return results

    def restore(self, entity_type: str, entity_id: Any, timestamp: str) -> Optional[Dict]:
        """Stellt einen alten Stand wieder her"""
        # Finde den Eintrag zum Zeitpunkt
        history = self.get_history(entity_type, entity_id)

        for entry in history:
            if entry["timestamp"] <= timestamp and entry.get("old_data"):
                return entry["old_data"]

        return None


class DatabaseConnector:
    """Verbindung zum Access-Backend"""

    def __init__(self, db_path: str):
        self.db_path = db_path
        self.conn = None

    def connect(self):
        """Stellt Verbindung her"""
        conn_str = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={self.db_path};"
        self.conn = pyodbc.connect(conn_str)
        return self.conn

    def disconnect(self):
        """Trennt Verbindung"""
        if self.conn:
            self.conn.close()
            self.conn = None

    def execute(self, sql: str, params: tuple = None, fetch: bool = True) -> Any:
        """Fuehrt SQL aus"""
        if not self.conn:
            self.connect()

        cursor = self.conn.cursor()

        if params:
            cursor.execute(sql, params)
        else:
            cursor.execute(sql)

        if fetch:
            columns = [desc[0] for desc in cursor.description]
            rows = cursor.fetchall()
            return [dict(zip(columns, row)) for row in rows]
        else:
            self.conn.commit()
            return cursor.rowcount

    def get_record(self, table: str, id_field: str, id_value: Any) -> Optional[Dict]:
        """Holt einen einzelnen Datensatz"""
        sql = f"SELECT * FROM {table} WHERE {id_field} = ?"
        results = self.execute(sql, (id_value,))
        return results[0] if results else None

    def update_record(self, table: str, id_field: str, id_value: Any, data: Dict) -> bool:
        """Aktualisiert einen Datensatz"""
        # Felder und Werte vorbereiten
        fields = []
        values = []

        for key, value in data.items():
            if key != id_field:
                fields.append(f"{key} = ?")
                values.append(value)

        values.append(id_value)

        sql = f"UPDATE {table} SET {', '.join(fields)} WHERE {id_field} = ?"

        try:
            self.execute(sql, tuple(values), fetch=False)
            return True
        except Exception as e:
            print(f"Update Error: {e}")
            return False

    def insert_record(self, table: str, data: Dict) -> Any:
        """Fuegt neuen Datensatz ein"""
        fields = list(data.keys())
        placeholders = ["?" for _ in fields]
        values = [data[f] for f in fields]

        sql = f"INSERT INTO {table} ({', '.join(fields)}) VALUES ({', '.join(placeholders)})"

        try:
            self.execute(sql, tuple(values), fetch=False)
            # ID des neuen Datensatzes holen
            result = self.execute("SELECT @@IDENTITY AS id")
            return result[0]["id"] if result else None
        except Exception as e:
            print(f"Insert Error: {e}")
            return None

    def delete_record(self, table: str, id_field: str, id_value: Any) -> bool:
        """Loescht einen Datensatz"""
        sql = f"DELETE FROM {table} WHERE {id_field} = ?"

        try:
            self.execute(sql, (id_value,), fetch=False)
            return True
        except Exception as e:
            print(f"Delete Error: {e}")
            return False


class RealtimeServer:
    """Haupt-Server fuer Echtzeit-Kommunikation"""

    # Mapping von Entity-Typen zu Tabellen
    ENTITY_MAPPING = {
        "MITARBEITER": {"table": "tbl_MA_Mitarbeiterstamm", "id": "ID"},
        "KUNDE": {"table": "tbl_KD_Kundenstamm", "id": "kun_Id"},
        "AUFTRAG": {"table": "tbl_VA_Auftragstamm", "id": "ID"},
        "SCHICHT": {"table": "tbl_VA_Start", "id": "ID"},
        "PLANUNG": {"table": "tbl_MA_VA_Planung", "id": "ID"},
        "ABWESENHEIT": {"table": "tbl_MA_NVerfuegZeiten", "id": "ID"},
    }

    def __init__(self, config: Dict):
        self.config = config
        self.db = DatabaseConnector(config["BACKEND_PATH"])
        self.audit = AuditTrail(config["AUDIT_PATH"])
        self.data_path = Path(config["DATA_PATH"])
        self.upload_path = Path(config["UPLOAD_PATH"])
        self.upload_path.mkdir(parents=True, exist_ok=True)

    async def handle_client(self, websocket: websockets.WebSocketServerProtocol, path: str):
        """Behandelt eine WebSocket-Verbindung"""
        connected_clients.add(websocket)
        client_id = id(websocket)
        print(f"[+] Client verbunden: {client_id} (Gesamt: {len(connected_clients)})")

        try:
            async for message in websocket:
                try:
                    data = json.loads(message)
                    response = await self.process_message(data, websocket)

                    if response:
                        await websocket.send(json.dumps(response, ensure_ascii=False))
                except json.JSONDecodeError:
                    await websocket.send(json.dumps({"error": "Invalid JSON"}))
                except Exception as e:
                    await websocket.send(json.dumps({"error": str(e)}))

        except websockets.exceptions.ConnectionClosed:
            pass
        finally:
            connected_clients.discard(websocket)
            print(f"[-] Client getrennt: {client_id} (Gesamt: {len(connected_clients)})")

    async def process_message(self, data: Dict, websocket) -> Dict:
        """Verarbeitet eine eingehende Nachricht"""
        action = data.get("action", "").upper()
        entity_type = data.get("type", "").upper()
        entity_id = data.get("id")
        payload = data.get("data", {})
        user = data.get("user", "HTML-Client")
        request_id = data.get("request_id")

        response = {"action": action, "type": entity_type, "success": False}
        if request_id:
            response["request_id"] = request_id

        try:
            if action == "PING":
                response["success"] = True
                response["timestamp"] = datetime.now().isoformat()

            elif action == "GET":
                result = await self.get_data(entity_type, entity_id)
                response["success"] = True
                response["data"] = result

            elif action == "LIST":
                filters = data.get("filters", {})
                result = await self.list_data(entity_type, filters)
                response["success"] = True
                response["data"] = result

            elif action == "CREATE":
                result = await self.create_data(entity_type, payload, user)
                response["success"] = result is not None
                response["id"] = result
                if result:
                    await self.broadcast_change("CREATE", entity_type, result, payload, websocket)

            elif action == "UPDATE":
                old_data = await self.get_data(entity_type, entity_id)
                result = await self.update_data(entity_type, entity_id, payload, user, old_data)
                response["success"] = result
                if result:
                    await self.broadcast_change("UPDATE", entity_type, entity_id, payload, websocket)

            elif action == "DELETE":
                old_data = await self.get_data(entity_type, entity_id)
                result = await self.delete_data(entity_type, entity_id, user, old_data)
                response["success"] = result
                if result:
                    await self.broadcast_change("DELETE", entity_type, entity_id, None, websocket)

            elif action == "HISTORY":
                result = self.audit.get_history(
                    entity_type=entity_type,
                    entity_id=entity_id,
                    from_date=data.get("from_date"),
                    to_date=data.get("to_date"),
                    limit=data.get("limit", 100)
                )
                response["success"] = True
                response["data"] = result

            elif action == "RESTORE":
                timestamp = data.get("timestamp")
                old_data = self.audit.restore(entity_type, entity_id, timestamp)
                if old_data:
                    result = await self.update_data(entity_type, entity_id, old_data, user)
                    response["success"] = result
                    response["data"] = old_data
                    if result:
                        await self.broadcast_change("RESTORE", entity_type, entity_id, old_data, websocket)

            elif action == "SEARCH":
                query = data.get("query", "")
                result = await self.search_all(query, data.get("types", []))
                response["success"] = True
                response["data"] = result

            elif action == "SYNC":
                # Client fordert Synchronisation an
                result = await self.get_sync_data(data.get("since"))
                response["success"] = True
                response["data"] = result

            elif action == "SUBSCRIBE":
                # Client abonniert bestimmte Entity-Typen
                response["success"] = True
                response["message"] = "Subscribed"

            else:
                response["error"] = f"Unknown action: {action}"

        except Exception as e:
            response["error"] = str(e)
            print(f"Error processing {action}: {e}")

        return response

    async def get_data(self, entity_type: str, entity_id: Any) -> Optional[Dict]:
        """Holt einen Datensatz"""
        mapping = self.ENTITY_MAPPING.get(entity_type)
        if not mapping:
            return None

        return self.db.get_record(mapping["table"], mapping["id"], entity_id)

    async def list_data(self, entity_type: str, filters: Dict = None) -> List[Dict]:
        """Listet Datensaetze"""
        mapping = self.ENTITY_MAPPING.get(entity_type)
        if not mapping:
            return []

        sql = f"SELECT * FROM {mapping['table']}"

        if filters:
            conditions = []
            for key, value in filters.items():
                if isinstance(value, str):
                    conditions.append(f"{key} LIKE '%{value}%'")
                else:
                    conditions.append(f"{key} = {value}")

            if conditions:
                sql += " WHERE " + " AND ".join(conditions)

        return self.db.execute(sql)

    async def create_data(self, entity_type: str, data: Dict, user: str) -> Any:
        """Erstellt einen neuen Datensatz"""
        mapping = self.ENTITY_MAPPING.get(entity_type)
        if not mapping:
            return None

        new_id = self.db.insert_record(mapping["table"], data)

        if new_id:
            self.audit.log("CREATE", entity_type, new_id, user, new_data=data)

        return new_id

    async def update_data(self, entity_type: str, entity_id: Any,
                          data: Dict, user: str, old_data: Dict = None) -> bool:
        """Aktualisiert einen Datensatz"""
        mapping = self.ENTITY_MAPPING.get(entity_type)
        if not mapping:
            return False

        success = self.db.update_record(mapping["table"], mapping["id"], entity_id, data)

        if success:
            self.audit.log("UPDATE", entity_type, entity_id, user,
                          old_data=old_data, new_data=data)

        return success

    async def delete_data(self, entity_type: str, entity_id: Any,
                          user: str, old_data: Dict = None) -> bool:
        """Loescht einen Datensatz"""
        mapping = self.ENTITY_MAPPING.get(entity_type)
        if not mapping:
            return False

        success = self.db.delete_record(mapping["table"], mapping["id"], entity_id)

        if success:
            self.audit.log("DELETE", entity_type, entity_id, user, old_data=old_data)

        return success

    async def search_all(self, query: str, types: List[str] = None) -> Dict[str, List[Dict]]:
        """Volltextsuche ueber alle Entitaeten"""
        results = {}
        search_types = types if types else list(self.ENTITY_MAPPING.keys())

        for entity_type in search_types:
            mapping = self.ENTITY_MAPPING.get(entity_type)
            if not mapping:
                continue

            # Einfache Suche in allen Text-Feldern
            # In einer echten Implementierung wuerde man hier spezifische Felder definieren
            try:
                sql = f"SELECT * FROM {mapping['table']}"
                all_records = self.db.execute(sql)

                # Client-seitig filtern
                matches = []
                query_lower = query.lower()

                for record in all_records:
                    for value in record.values():
                        if value and query_lower in str(value).lower():
                            matches.append(record)
                            break

                if matches:
                    results[entity_type] = matches[:20]  # Max 20 pro Typ
            except:
                pass

        return results

    async def get_sync_data(self, since: str = None) -> Dict:
        """Holt alle Daten fuer Synchronisation"""
        # Lade alle JSON-Dateien aus data/
        sync_data = {}

        for json_file in self.data_path.glob("*.json"):
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    sync_data[json_file.stem] = json.load(f)
            except:
                pass

        sync_data["_timestamp"] = datetime.now().isoformat()
        return sync_data

    async def broadcast_change(self, action: str, entity_type: str,
                               entity_id: Any, data: Dict,
                               exclude_client=None):
        """Sendet Aenderung an alle verbundenen Clients"""
        message = json.dumps({
            "event": "CHANGE",
            "action": action,
            "type": entity_type,
            "id": entity_id,
            "data": data,
            "timestamp": datetime.now().isoformat()
        }, ensure_ascii=False)

        for client in connected_clients:
            if client != exclude_client:
                try:
                    await client.send(message)
                except:
                    pass

    async def start(self):
        """Startet den WebSocket-Server"""
        print(f"\n{'='*60}")
        print("CONSEC REALTIME SERVER")
        print(f"{'='*60}")
        print(f"WebSocket: ws://localhost:{self.config['WEBSOCKET_PORT']}")
        print(f"Backend:   {self.config['BACKEND_PATH']}")
        print(f"Data:      {self.config['DATA_PATH']}")
        print(f"Audit:     {self.config['AUDIT_PATH']}")
        print(f"{'='*60}")
        print("Server gestartet. Druecke Strg+C zum Beenden.\n")

        try:
            self.db.connect()
            print("[OK] Datenbankverbindung hergestellt")
        except Exception as e:
            print(f"[!] Datenbankfehler: {e}")

        async with websockets.serve(
            self.handle_client,
            "localhost",
            self.config["WEBSOCKET_PORT"]
        ):
            await asyncio.Future()  # Run forever


def main():
    """Hauptfunktion"""
    import argparse

    parser = argparse.ArgumentParser(description="CONSEC Realtime Server")
    parser.add_argument("--port", type=int, default=8765, help="WebSocket Port")
    parser.add_argument("--backend", type=str, help="Pfad zur Backend-Datenbank")
    args = parser.parse_args()

    config = CONFIG.copy()
    config["WEBSOCKET_PORT"] = args.port

    if args.backend:
        config["BACKEND_PATH"] = args.backend

    server = RealtimeServer(config)

    try:
        asyncio.run(server.start())
    except KeyboardInterrupt:
        print("\n[!] Server beendet")


if __name__ == "__main__":
    main()
