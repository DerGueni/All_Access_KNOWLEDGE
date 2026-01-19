from __future__ import annotations

import logging
import threading
import time
from datetime import date
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence

import pyodbc

from .models import EmployeeRecord

logger = logging.getLogger(__name__)


class AccessDatabase:
    """Minimal helper around the Access ODBC driver with serialised queries."""

    def __init__(self, db_path: str, min_interval: float = 0.35) -> None:
        self.db_path = db_path
        self._conn: Optional[pyodbc.Connection] = None
        self._conn_lock = threading.Lock()
        self._query_lock = threading.Lock()
        self._last_query = 0.0
        self._min_interval = min_interval

    def _connect(self) -> pyodbc.Connection:
        with self._conn_lock:
            if self._conn is None:
                conn_str = (
                    r"DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};"
                    f"DBQ={self.db_path};"
                )
                logger.info("Opening Access connection to %s", self.db_path)
                self._conn = pyodbc.connect(conn_str)
            return self._conn

    def reset(self) -> None:
        with self._conn_lock:
            if self._conn is not None:
                try:
                    self._conn.close()
                except Exception as error:  # pragma: no cover - defensive
                    logger.warning("Access connection close failed: %s", error)
                finally:
                    self._conn = None

    def execute(self, sql: str, params: Optional[Sequence] = None, fetch: bool = True) -> List[pyodbc.Row]:
        with self._query_lock:
            elapsed = time.time() - self._last_query
            if elapsed < self._min_interval:
                time.sleep(self._min_interval - elapsed)

            attempt = 0
            while True:
                attempt += 1
                try:
                    conn = self._connect()
                    cursor = conn.cursor()
                    if params:
                        cursor.execute(sql, params)
                    else:
                        cursor.execute(sql)
                    if fetch:
                        rows = cursor.fetchall()
                    else:
                        conn.commit()
                        rows = []
                    cursor.close()
                    self._last_query = time.time()
                    return rows
                except pyodbc.Error as error:
                    logger.warning("Access query failed (attempt %s): %s", attempt, error)
                    self.reset()
                    if attempt >= 3:
                        raise
                    time.sleep(0.5)

    # ------------------------------------------------------------------
    # Domain specific helpers
    # ------------------------------------------------------------------

    def fetch_employees(self, employee_ids: Sequence[int]) -> List[EmployeeRecord]:
        if not employee_ids:
            return []
        placeholders = ",".join(["?"] * len(employee_ids))
        sql = f"""
            SELECT ID, Nachname, Vorname, Strasse, Nr, PLZ, Ort, Land, Bundesland,
                   Tel_Mobil, Email, DienstausweisNr, Ausweis_Endedatum,
                   tblBilddatei, tblSignaturdatei
            FROM tbl_MA_Mitarbeiterstamm
            WHERE ID IN ({placeholders})
        """
        rows = self.execute(sql, list(employee_ids))
        records: List[EmployeeRecord] = []
        for row in rows:
            record = EmployeeRecord(
                employee_id=row.ID,
                first_name=(row.Vorname or "").strip(),
                last_name=(row.Nachname or "").strip(),
                street=(row.Strasse or "").strip() or None,
                house_number=(row.Nr or "").strip() or None,
                postal_code=(row.PLZ or "").strip() or None,
                city=(row.Ort or "").strip() or None,
                country=(row.Land or "").strip() or None,
                phone_mobile=(row.Tel_Mobil or "").strip() or None,
                email=(row.Email or "").strip() or None,
                badge_number=(row.DienstausweisNr or "").strip() or None,
                badge_valid_until=EmployeeRecord.parse_badge_date(row.Ausweis_Endedatum),
                picture_filename=(row.tblBilddatei or "").strip() or None,
                signature_filename=(row.tblSignaturdatei or "").strip() or None,
            )
            record.normalize()
            records.append(record)
        # preserve requested order
        ordering = {employee_id: index for index, employee_id in enumerate(employee_ids)}
        records.sort(key=lambda rec: ordering.get(rec.employee_id, 0))
        return records

    def ensure_badge_numbers(self, employee_ids: Sequence[int]) -> Dict[int, str]:
        """Assign badge numbers to employees lacking one."""
        assigned: Dict[int, str] = {}
        if not employee_ids:
            return assigned
        placeholders = ",".join(["?"] * len(employee_ids))
        sql = f"SELECT ID, DienstausweisNr FROM tbl_MA_Mitarbeiterstamm WHERE ID IN ({placeholders})"
        rows = self.execute(sql, list(employee_ids))
        for row in rows:
            current = (row.DienstausweisNr or "").strip()
            if current:
                assigned[row.ID] = current
                continue
            new_value = f"{row.ID:06d}"
            update_sql = "UPDATE tbl_MA_Mitarbeiterstamm SET DienstausweisNr = ? WHERE ID = ?"
            self.execute(update_sql, (new_value, row.ID), fetch=False)
            assigned[row.ID] = new_value
        return assigned

    def update_badge_valid_until(self, employee_ids: Sequence[int], valid_until: date) -> None:
        if not employee_ids:
            return
        placeholders = ",".join(["?"] * len(employee_ids))
        sql = f"UPDATE tbl_MA_Mitarbeiterstamm SET Ausweis_Endedatum = ? WHERE ID IN ({placeholders})"
        params = [valid_until] + list(employee_ids)
        self.execute(sql, params, fetch=False)

    def fetch_property(self, name: str) -> Optional[str]:
        sql = "SELECT PropInhalt FROM _tblProperty WHERE PropName = ? AND PropUser = 'All'"
        rows = self.execute(sql, (name,))
        if not rows:
            return None
        value = rows[0][0]
        return (value or "").strip() or None

    def fetch_path_by_id(self, path_id: int) -> Optional[str]:
        sql = "SELECT Pfad FROM _tblEigeneFirma_Pfade WHERE ID = ?"
        rows = self.execute(sql, (path_id,))
        if not rows:
            return None
        value = rows[0][0]
        return (value or "").strip() or None

    def resolve_asset_roots(self, config_paths: Dict[str, int | str]) -> Dict[str, str]:
        base_property = config_paths.get("base_property")
        base_path = self.fetch_property(base_property) if base_property else None
        if not base_path:
            raise RuntimeError(f"Private property '{base_property}' konnte nicht gelesen werden")

        def build_path(path_value: Optional[str]) -> str:
            if not path_value:
                return base_path
            return str(Path(base_path) / path_value.strip("\\/"))

        photo_root = build_path(self.fetch_path_by_id(config_paths.get("photo_path_id", 7)))
        signature_root = build_path(self.fetch_path_by_id(config_paths.get("signature_path_id", 14)))
        company_signature_root = build_path(self.fetch_path_by_id(config_paths.get("company_signature_path_id", 6)))

        return {
            "base": base_path,
            "photo_root": photo_root,
            "signature_root": signature_root,
            "company_signature_root": company_signature_root,
            "photo_fallback": config_paths.get("photo_fallback", "KeinBild.jpg"),
            "signature_fallback": config_paths.get("signature_fallback", "KeinSignatur.jpg"),
        }
