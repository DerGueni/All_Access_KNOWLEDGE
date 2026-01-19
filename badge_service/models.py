from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date, datetime
from typing import Any, Dict, Optional


@dataclass
class EmployeeRecord:
    """Lightweight representation of the MA dataset used for badge printing."""

    employee_id: int
    first_name: str
    last_name: str
    street: Optional[str] = None
    house_number: Optional[str] = None
    postal_code: Optional[str] = None
    city: Optional[str] = None
    country: Optional[str] = None
    phone_mobile: Optional[str] = None
    email: Optional[str] = None
    badge_number: Optional[str] = None
    badge_valid_until: Optional[date] = None
    picture_filename: Optional[str] = None
    signature_filename: Optional[str] = None
    address_line: str = field(default="", init=False)
    picture_path: Optional[str] = field(default=None, init=False)
    signature_path: Optional[str] = field(default=None, init=False)
    company_signature_path: Optional[str] = field(default=None, init=False)

    def normalize(self) -> None:
        """Populate derived fields that are handy for templates."""
        street = (self.street or "").strip()
        number = (self.house_number or "").strip()
        if street and number:
            self.address_line = f"{street} {number}".strip()
        else:
            self.address_line = street or number

    def to_payload(self) -> Dict[str, Any]:
        """Return a JSON serialisable dict."""
        return {
            "employeeId": self.employee_id,
            "firstName": self.first_name,
            "lastName": self.last_name,
            "address": self.address_line,
            "postalCode": self.postal_code,
            "city": self.city,
            "country": self.country,
            "mobile": self.phone_mobile,
            "email": self.email,
            "badgeNumber": self.badge_number,
            "badgeValidUntil": self.badge_valid_until.isoformat() if self.badge_valid_until else None,
            "picture": self.picture_path,
            "signature": self.signature_path,
            "companySignature": self.company_signature_path,
        }

    @staticmethod
    def parse_badge_date(value: Any) -> Optional[date]:
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
