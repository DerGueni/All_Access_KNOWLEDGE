"""Smoke-Tests fuer die Abwesenheiten-API.

Fuehrt einen kompletten CRUD-Durchlauf gegen das laufende Flask-Backend durch.

Voraussetzungen:
- API-Server laeuft lokal (Standard http://localhost:5000)
- Python-Paket `requests` ist installiert (pip install requests)
- Optionale Umgebungsvariable `CONSYS_API_URL` zum Ueberschreiben des Basis-URLs
"""

from __future__ import annotations

import os
import uuid
from datetime import date

import requests

BASE_URL = os.getenv("CONSYS_API_URL", "http://localhost:5000/api")


def _url(path: str) -> str:
    return f"{BASE_URL.rstrip('/')}/{path.lstrip('/')}"


def _require_success(resp: requests.Response) -> dict:
    resp.raise_for_status()
    payload = resp.json()
    assert payload.get("success"), payload
    return payload


def _pick_any_employee() -> int:
    resp = requests.get(_url("mitarbeiter"), params={"limit": 1, "aktiv": "true"})
    data = _require_success(resp)["data"]
    if not data:
        raise RuntimeError("Kein aktiver Mitarbeiter verfuegbar")
    return data[0]["ID"]


def _create_payload(ma_id: int) -> dict:
    today = date.today().isoformat()
    marker = uuid.uuid4().hex[:8]
    return {
        "MA_ID": ma_id,
        "vonDat": today,
        "bisDat": today,
        "Grund": f"API-Test-{marker}",
        "Bemerkung": f"Automatischer Testeintrag {marker}",
        "Ganztaegig": True,
    }


def run_crud_roundtrip() -> None:
    ma_id = _pick_any_employee()
    payload = _create_payload(ma_id)

    # Create
    create_resp = requests.post(_url("abwesenheiten"), json=payload)
    create_data = _require_success(create_resp)
    new_id = create_data["id"]

    # Read (verify newly created record is filterbar)
    list_resp = requests.get(
        _url("abwesenheiten"),
        params={"ma_id": ma_id, "datum_von": payload["vonDat"], "datum_bis": payload["bisDat"]},
    )
    list_data = _require_success(list_resp)["data"]
    assert any(row["ID"] == new_id for row in list_data), list_data

    # Update
    updated_payload = dict(payload)
    updated_payload["Grund"] = payload["Grund"] + "-UPD"
    update_resp = requests.put(_url(f"abwesenheiten/{new_id}"), json=updated_payload)
    _require_success(update_resp)

    # Delete
    delete_resp = requests.delete(_url(f"abwesenheiten/{new_id}"))
    _require_success(delete_resp)

    # Verify deletion
    verify_resp = requests.get(_url("abwesenheiten"), params={"ma_id": ma_id, "datum_von": payload["vonDat"], "datum_bis": payload["bisDat"]})
    verify_data = _require_success(verify_resp)["data"]
    assert not any(row["ID"] == new_id for row in verify_data), verify_data


if __name__ == "__main__":
    run_crud_roundtrip()
    print("Abwesenheiten-API CRUD-Test erfolgreich abgeschlossen.")
