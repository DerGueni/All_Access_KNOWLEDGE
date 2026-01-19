from __future__ import annotations

import json
import logging
import os
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Dict, Tuple
from uuid import uuid4

logger = logging.getLogger(__name__)


class JobQueue:
    """Persist print jobs as json files that can be picked up by spooler scripts."""

    def __init__(self, output_dir: str, retention_hours: int = 72) -> None:
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.retention = timedelta(hours=retention_hours)

    def enqueue(self, job_type: str, payload: Dict[str, Any]) -> Tuple[str, Path]:
        job_id = payload.get("jobId") or uuid4().hex
        timestamp = datetime.now(timezone.utc)
        payload.setdefault("jobId", job_id)
        payload.setdefault("jobType", job_type)
        payload.setdefault("createdAt", timestamp.isoformat())

        file_path = self.output_dir / f"{timestamp.strftime('%Y%m%d_%H%M%S')}_{job_type}_{job_id}.json"
        file_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
        logger.info("Queued %s job %s -> %s", job_type, job_id, file_path)
        self._cleanup()
        return job_id, file_path

    def _cleanup(self) -> None:
        cutoff = datetime.now(timezone.utc) - self.retention
        for entry in self.output_dir.glob("*.json"):
            try:
                stat = entry.stat()
                modified = datetime.fromtimestamp(stat.st_mtime, tz=timezone.utc)
                if modified < cutoff:
                    entry.unlink()
            except OSError as error:  # pragma: no cover - best effort cleanup
                logger.debug("Skip cleanup for %s: %s", entry, error)
