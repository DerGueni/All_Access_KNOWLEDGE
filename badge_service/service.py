from __future__ import annotations

import json
import logging
from datetime import date, datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

from flask import Flask, jsonify, request
from flask_cors import CORS

if __package__ in (None, ""):
    import sys

    PACKAGE_ROOT = Path(__file__).resolve().parent.parent
    sys.path.append(str(PACKAGE_ROOT))
    from badge_service import templates  # type: ignore
    from badge_service.db import AccessDatabase  # type: ignore
    from badge_service.job_queue import JobQueue  # type: ignore
    from badge_service.models import EmployeeRecord  # type: ignore
else:
    from . import templates
    from .db import AccessDatabase
    from .job_queue import JobQueue
    from .models import EmployeeRecord

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("badge-service")

CONFIG_PATH = Path(__file__).with_name("config.json")
CONFIG: Dict[str, Any] = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})

db = AccessDatabase(CONFIG["database"]["backend_path"])
job_queue = JobQueue(CONFIG["jobs"]["queue_directory"], CONFIG["jobs"].get("retention_hours", 72))


def parse_date(value: Any) -> Optional[date]:
    if isinstance(value, date):
        return value
    if isinstance(value, datetime):
        return value.date()
    if isinstance(value, str) and value:
        for fmt in ("%Y-%m-%d", "%d.%m.%Y", "%Y/%m/%d"):
            try:
                return datetime.strptime(value, fmt).date()
            except ValueError:
                continue
    return None


def _asset_path(root: str, filename: Optional[str], fallback: str) -> str:
    root_path = Path(root)
    if filename:
        candidate = root_path / filename
        if candidate.exists():
            return str(candidate)
    fallback_path = root_path / fallback
    return str(fallback_path)


def _inject_assets(records: List[EmployeeRecord]) -> None:
    asset_roots = db.resolve_asset_roots(CONFIG["paths"])
    for record in records:
        record.picture_path = _asset_path(asset_roots["photo_root"], record.picture_filename, asset_roots["photo_fallback"])
        record.signature_path = _asset_path(asset_roots["signature_root"], record.signature_filename, asset_roots["signature_fallback"])
        record.company_signature_path = asset_roots["company_signature_root"]


def _default_printer(kind: str) -> str:
    printers = CONFIG.get("printers", {})
    if kind == "card":
        return printers.get("default_card_printer") or printers.get("default_report_printer", "Badgy200")
    return printers.get("default_report_printer", "Badgy200")


@app.route("/api/badges/status")
def status() -> Any:
    return jsonify({
        "service": "badge-print",
        "database": CONFIG["database"]["backend_path"],
        "templates": len(templates.BADGE_TEMPLATES),
        "cardTemplates": len(templates.CARD_TEMPLATES)
    })


@app.route("/api/badges/templates")
def list_templates() -> Any:
    return jsonify({
        "badgeTemplates": templates.list_badge_templates(),
        "cardTemplates": templates.list_card_templates()
    })


@app.route("/api/badges/jobs", methods=["POST"])
def create_badge_job() -> Any:
    payload = request.get_json(force=True, silent=True) or {}
    template_key = payload.get("template")
    employee_ids = payload.get("employeeIds", [])
    if not employee_ids:
        return jsonify({"error": "employeeIds erforderlich"}), 400
    if template_key not in templates.BADGE_TEMPLATES:
        return jsonify({"error": f"Unbekanntes Template: {template_key}"}), 400

    valid_until = parse_date(payload.get("validUntil"))
    assign_numbers = bool(payload.get("assignNumbers", True))
    update_valid_until = bool(payload.get("updateEmployeeValidity", True))

    try:
        employees = db.fetch_employees(employee_ids)
        if not employees:
            return jsonify({"error": "Keine Mitarbeiter gefunden"}), 404

        if assign_numbers:
            numbers = db.ensure_badge_numbers([emp.employee_id for emp in employees])
            for emp in employees:
                if emp.employee_id in numbers:
                    emp.badge_number = numbers[emp.employee_id]

        if valid_until and update_valid_until:
            db.update_badge_valid_until([emp.employee_id for emp in employees], valid_until)
            for emp in employees:
                emp.badge_valid_until = valid_until
        elif not valid_until:
            # Fallback to stored value from DB
            valid_until = employees[0].badge_valid_until

        _inject_assets(employees)

        template = templates.BADGE_TEMPLATES[template_key]
        printer = payload.get("printer") or _default_printer("badge")

        job = {
            "template": template_key,
            "report": template["report"],
            "printer": printer,
            "validUntil": valid_until.isoformat() if valid_until else None,
            "employeeCount": len(employees),
            "employees": [emp.to_payload() for emp in employees]
        }
        job_id, job_path = job_queue.enqueue("badge", job)
        job["jobId"] = job_id
        job["jobFile"] = str(job_path)
        return jsonify(job)
    except Exception as error:  # pragma: no cover - runtime protection
        logger.exception("Badge job creation failed")
        return jsonify({"error": str(error)}), 500


@app.route("/api/cards/jobs", methods=["POST"])
def create_card_job() -> Any:
    payload = request.get_json(force=True, silent=True) or {}
    card_type = payload.get("cardType")
    employee_id = payload.get("employeeId")
    if not employee_id:
        return jsonify({"error": "employeeId erforderlich"}), 400
    if card_type not in templates.CARD_TEMPLATES:
        return jsonify({"error": f"Unbekannter Kartentyp: {card_type}"}), 400

    custom_text = payload.get("customText")
    printer = payload.get("printer") or _default_printer("card")

    try:
        employee = db.fetch_employees([employee_id])
        if not employee:
            return jsonify({"error": "Mitarbeiter nicht gefunden"}), 404
        record = employee[0]
        _inject_assets([record])
        template = templates.CARD_TEMPLATES[card_type]

        job = {
            "cardType": card_type,
            "printer": printer,
            "report": template["report"],
            "employee": record.to_payload(),
            "customText": custom_text
        }
        job_id, job_path = job_queue.enqueue("card", job)
        job["jobId"] = job_id
        job["jobFile"] = str(job_path)
        return jsonify(job)
    except Exception as error:  # pragma: no cover - runtime protection
        logger.exception("Card job creation failed")
        return jsonify({"error": str(error)}), 500


@app.route("/api/badges/preview", methods=["POST"])
def preview_job() -> Any:
    payload = request.get_json(force=True, silent=True) or {}
    employee_ids = payload.get("employeeIds", [])
    if not employee_ids:
        return jsonify({"error": "employeeIds erforderlich"}), 400
    try:
        employees = db.fetch_employees(employee_ids)
        _inject_assets(employees)
        return jsonify({"employees": [emp.to_payload() for emp in employees]})
    except Exception as error:  # pragma: no cover - runtime protection
        logger.exception("Preview failed")
        return jsonify({"error": str(error)}), 500


if __name__ == "__main__":
    server_cfg = CONFIG.get("server", {})
    host = server_cfg.get("host", "0.0.0.0")
    port = int(server_cfg.get("port", 5005))
    debug = bool(server_cfg.get("debug", False))
    logger.info("Badge service listening on %s:%s", host, port)
    app.run(host=host, port=port, debug=debug)
