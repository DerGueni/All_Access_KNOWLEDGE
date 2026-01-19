from __future__ import annotations

from typing import Dict, List

BADGE_TEMPLATES: Dict[str, Dict[str, str]] = {
    "Einsatzleitung": {
        "report": "rpt_Ausweis_ohne_Namen_einsatzleitung",
        "badgeType": "einsatzleitung",
        "color": "#2d5016",
        "label": "Einsatzleitung"
    },
    "Bereichsleiter": {
        "report": "rpt_Ausweis_ohne_Namen_bereichsleiter",
        "badgeType": "bereichsleiter",
        "color": "#2a5d82",
        "label": "Bereichsleiter"
    },
    "Security": {
        "report": "rpt_Ausweis_ohne_Namen_sec",
        "badgeType": "security",
        "color": "#202833",
        "label": "Security"
    },
    "Service": {
        "report": "rpt_Ausweis_ohne_Namen_service",
        "badgeType": "service",
        "color": "#786014",
        "label": "Service"
    },
    "Platzanweiser": {
        "report": "rpt_Ausweis_ohne_Namen_platzanweiser",
        "badgeType": "platzanweiser",
        "color": "#355c51",
        "label": "Platzanweiser"
    },
    "Staff": {
        "report": "rpt_Ausweis_ohne_Namen_staff",
        "badgeType": "staff",
        "color": "#953579",
        "label": "Staff"
    }
}

CARD_TEMPLATES: Dict[str, Dict[str, str]] = {
    "Sicherheit": {
        "report": "rpt_Ausweis_Karte_Vorderseite",
        "cardType": "Sicherheit",
        "label": "Karte Sicherheit",
        "requiresBadgy": True
    },
    "Servicekarte": {
        "report": "rpt_Ausweis_Karte_Vorderseite",
        "cardType": "Service",
        "label": "Karte Service",
        "requiresBadgy": True
    },
    "Rueckseite": {
        "report": "rpt_Ausweis_Karte_Rueckseite",
        "cardType": "Rueckseite",
        "label": "Kartenrückseite",
        "requiresBadgy": True
    },
    "Sonder": {
        "report": "rpt_Ausweis_Karte_Vorderseite",
        "cardType": "Sonder",
        "label": "Sonderkarte",
        "requiresBadgy": True
    }
}


def list_badge_templates() -> List[Dict[str, str]]:
    return [
        {
            "key": key,
            "label": value["label"],
            "report": value["report"],
            "badgeType": value.get("badgeType"),
            "color": value.get("color")
        }
        for key, value in BADGE_TEMPLATES.items()
    ]


def list_card_templates() -> List[Dict[str, str]]:
    return [
        {
            "key": key,
            "label": value["label"],
            "report": value["report"],
            "cardType": value.get("cardType"),
            "requiresBadgy": value.get("requiresBadgy", False)
        }
        for key, value in CARD_TEMPLATES.items()
    ]
