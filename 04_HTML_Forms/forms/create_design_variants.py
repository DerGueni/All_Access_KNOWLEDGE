#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Design Variants Generator for frm_va_Auftragstamm.html
Erstellt 2 Design-Varianten mit unterschiedlichem CSS, identischer HTML-Struktur und JavaScript.
"""

import re
import os

# === KONFIGURATION ===
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ORIGINAL_FILE = os.path.join(SCRIPT_DIR, 'frm_va_Auftragstamm.html')
OUTPUT_DIR = os.path.join(SCRIPT_DIR, 'varianten_auftragstamm')

# Erstelle Output-Verzeichnis
os.makedirs(OUTPUT_DIR, exist_ok=True)

# === CSS FÜR VARIANTE 7: MINIMALIST WHITE ===
CSS_MINIMALIST = """        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            font-size: 11px;
        }

        body {
            background-color: #FAFAFA;
            overflow: hidden;
            height: 100vh;
        }

        .window-frame {
            background-color: #FAFAFA;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Title Bar - Minimal */
        .title-bar {
            background: #FFFFFF;
            color: #212121;
            padding: 8px 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            height: 40px;
            flex-shrink: 0;
            border-bottom: 1px solid #E0E0E0;
        }

        .title-bar-left {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
            font-size: 13px;
        }

        .title-bar-buttons {
            display: flex;
            gap: 8px;
        }

        .title-btn {
            width: 32px;
            height: 32px;
            background: transparent;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #757575;
            transition: all 0.2s;
        }

        .title-btn:hover {
            background: #F5F5F5;
            border-color: #BDBDBD;
        }

        .title-btn.close {
            color: #D32F2F;
        }

        .title-btn.close:hover {
            background: #FFEBEE;
            border-color: #D32F2F;
        }

        /* Main Container */
        .main-container {
            display: flex;
            flex: 1;
            overflow: hidden;
        }

        /* Left Menu - Ultra minimal */
        .left-menu {
            width: 180px;
            background-color: #FFFFFF;
            padding: 12px 8px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            flex-shrink: 0;
            border-right: 1px solid #E0E0E0;
        }

        .menu-header {
            background-color: transparent;
            color: #212121;
            padding: 8px 12px;
            text-align: left;
            font-weight: 600;
            font-size: 11px;
            margin-bottom: 12px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .menu-buttons {
            display: flex;
            flex-direction: column;
            flex: 1;
            justify-content: space-between;
        }

        .menu-btn {
            background: transparent;
            padding: 10px 12px;
            text-align: left;
            cursor: pointer;
            font-size: 11px;
            color: #212121;
            font-weight: 400;
            border: none;
            border-left: 2px solid transparent;
            margin: 1px 0;
            transition: all 0.2s;
        }

        .menu-btn:hover {
            background: #F5F5F5;
            border-left-color: #BDBDBD;
        }

        .menu-btn.active {
            background: #F5F5F5;
            border-left-color: #1565C0;
            color: #1565C0;
            font-weight: 500;
        }

        /* Vollbild-Button */
        .fullscreen-btn {
            position: fixed;
            top: 8px;
            right: 8px;
            width: 32px;
            height: 32px;
            background: #FFFFFF;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            cursor: pointer;
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            color: #757575;
            transition: all 0.2s;
        }

        .fullscreen-btn:hover {
            background: #F5F5F5;
            border-color: #BDBDBD;
        }

        /* Vollbild-Modus */
        body.fullscreen-mode .title-bar {
            display: none;
        }

        /* Content Area */
        .content-area {
            flex: 1;
            background-color: #FAFAFA;
            padding: 8px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            overflow: hidden;
        }

        /* Header Row */
        .header-row {
            background-color: #FFFFFF;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-shrink: 0;
            flex-wrap: wrap;
        }

        .logo-box {
            width: 40px;
            height: 40px;
            background: #1565C0;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 18px;
        }

        .title-text {
            font-size: 16px;
            font-weight: 600;
            color: #212121;
        }

        .header-links {
            display: flex;
            gap: 16px;
            margin-left: 8px;
        }

        .header-link {
            color: #1565C0;
            text-decoration: none;
            cursor: pointer;
            font-size: 11px;
            border-bottom: 1px solid transparent;
            transition: border-color 0.2s;
        }

        .header-link:hover {
            border-bottom-color: #1565C0;
        }

        .btn {
            background: transparent;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            padding: 6px 12px;
            cursor: pointer;
            font-size: 11px;
            white-space: nowrap;
            color: #212121;
            transition: all 0.2s;
        }

        .btn:hover {
            background: #F5F5F5;
            border-color: #BDBDBD;
        }

        .btn:disabled {
            opacity: 0.4;
            cursor: not-allowed;
        }

        .btn-green {
            background: #FFFFFF;
            border-color: #4CAF50;
            color: #4CAF50;
        }

        .btn-green:hover {
            background: #E8F5E9;
        }

        .btn-yellow {
            background: #FFFFFF;
            border-color: #FFC107;
            color: #F57C00;
        }

        .btn-yellow:hover {
            background: #FFF8E1;
        }

        .btn-red {
            background: #FFFFFF;
            border-color: #F44336;
            color: #F44336;
        }

        .btn-red:hover {
            background: #FFEBEE;
        }

        /* GPT Box */
        .gpt-box {
            background: #FFF9C4;
            border: 1px solid #F9A825;
            border-radius: 4px;
            padding: 4px 8px;
            font-size: 9px;
            text-align: center;
            line-height: 1.4;
            position: absolute;
            right: 16px;
            top: 12px;
        }

        .header-row-wrapper {
            position: relative;
        }

        /* Button Row */
        .button-row {
            background-color: #FFFFFF;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            padding: 8px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-shrink: 0;
            flex-wrap: wrap;
        }

        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
        }

        .status-group {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-left: auto;
        }

        .form-label {
            font-size: 11px;
            color: #757575;
        }

        .form-select, .form-input {
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            padding: 4px 8px;
            font-size: 11px;
            background: white;
            transition: border-color 0.2s;
        }

        .form-input:focus, .form-select:focus {
            outline: none;
            border-color: #1565C0;
        }

        .form-input.readonly {
            background: #FAFAFA;
            color: #757575;
        }

        /* Form Section */
        .form-section {
            background-color: #FFFFFF;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            padding: 16px;
            display: flex;
            gap: 32px;
            flex-shrink: 0;
            flex-wrap: wrap;
        }

        .form-column {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-row {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-column.left .form-label {
            min-width: 45px;
            text-align: right;
        }

        .form-column.middle .form-label {
            min-width: 110px;
            text-align: right;
        }

        .form-column.right .form-label {
            min-width: 90px;
            text-align: right;
        }

        .input-narrow { width: 80px; }
        .input-medium { width: 200px; }
        .input-wide { width: 250px; }

        /* Work Area */
        .work-area {
            display: flex;
            flex: 1;
            gap: 8px;
            overflow: hidden;
        }

        /* Left Work Panel */
        .left-work-panel {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 8px;
            overflow: hidden;
        }

        /* Tab Container */
        .tab-container {
            background-color: #FFFFFF;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .tab-header {
            display: flex;
            background: #FFFFFF;
            border-bottom: 1px solid #E0E0E0;
            flex-shrink: 0;
        }

        .tab-btn {
            padding: 10px 16px;
            background: transparent;
            border: none;
            border-bottom: 2px solid transparent;
            cursor: pointer;
            font-size: 11px;
            color: #757575;
            transition: all 0.2s;
        }

        .tab-btn:hover {
            color: #212121;
            background: #FAFAFA;
        }

        .tab-btn.active {
            color: #1565C0;
            border-bottom-color: #1565C0;
            font-weight: 500;
        }

        .tab-content {
            padding: 16px;
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .tab-page {
            display: none;
            flex: 1;
            flex-direction: column;
            overflow: hidden;
        }

        .tab-page.active {
            display: flex;
        }

        .bwn-row {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 12px;
            flex-shrink: 0;
        }

        .status-red {
            color: #D32F2F;
            font-weight: 500;
        }

        /* Grid Area */
        .grid-area {
            display: flex;
            gap: 8px;
            flex: 1;
            overflow: hidden;
        }

        /* Left Subform */
        .subform-left {
            width: 200px;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }

        .subform-right {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            min-width: 0;
        }

        .grid-wrapper {
            flex: 1;
            overflow: auto;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            background: white;
        }

        /* Data Grid */
        .data-grid {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
        }

        .data-grid th {
            background: #FAFAFA;
            border-bottom: 1px solid #E0E0E0;
            padding: 8px 10px;
            text-align: left;
            font-weight: 500;
            position: sticky;
            top: 0;
            white-space: nowrap;
            font-size: 11px;
            cursor: pointer;
            color: #757575;
        }

        .data-grid th:hover {
            background: #F5F5F5;
        }

        .data-grid td {
            border-bottom: 1px solid #F5F5F5;
            padding: 6px 10px;
            height: 32px;
        }

        .data-grid tr:hover {
            background: #FAFAFA;
        }

        .data-grid tr.selected {
            background: #E3F2FD;
            color: #1565C0;
        }

        .data-grid input, .data-grid select {
            border: none;
            width: 100%;
            padding: 0;
            font-size: 11px;
            background: transparent;
        }

        .cell-blue { background-color: #E3F2FD; }
        .cell-green { background-color: #E8F5E9; }
        .cell-yellow { background-color: #FFF9C4; }
        .cell-red { background-color: #FFEBEE; }

        /* Absagen Section */
        .absagen-section {
            margin-top: 8px;
            flex-shrink: 0;
        }

        .absagen-label {
            font-weight: 500;
            margin-bottom: 8px;
            font-size: 11px;
            color: #757575;
        }

        .absagen-grid-wrapper {
            height: 120px;
            overflow: auto;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            background: white;
        }

        /* Right Panel */
        .right-panel {
            width: 420px;
            background: #FFFFFF;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            overflow: hidden;
        }

        .right-header {
            padding: 12px;
            border-bottom: 1px solid #E0E0E0;
            flex-shrink: 0;
        }

        .status-table {
            width: 100%;
            font-size: 11px;
            border-collapse: collapse;
        }

        .status-table td {
            padding: 6px 8px;
        }

        .status-table .count {
            text-align: right;
            font-weight: 500;
        }

        .anzeigen-btn {
            background: transparent;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            padding: 2px 8px;
            font-size: 10px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .anzeigen-btn:hover {
            background: #F5F5F5;
        }

        .date-nav {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            background: #FAFAFA;
            border-bottom: 1px solid #E0E0E0;
            flex-shrink: 0;
            font-size: 11px;
        }

        .date-input {
            width: 80px;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            padding: 4px 8px;
            font-size: 11px;
        }

        .nav-btn {
            background: transparent;
            border: 1px solid #E0E0E0;
            border-radius: 4px;
            padding: 4px 10px;
            cursor: pointer;
            font-size: 11px;
            transition: all 0.2s;
        }

        .nav-btn:hover {
            background: #F5F5F5;
        }

        .auftraege-wrapper {
            flex: 1;
            overflow: auto;
        }

        .auftraege-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
        }

        .auftraege-table th {
            background: #FAFAFA;
            border-bottom: 1px solid #E0E0E0;
            padding: 8px 10px;
            text-align: left;
            position: sticky;
            top: 0;
            font-weight: 500;
            white-space: nowrap;
            cursor: pointer;
            color: #757575;
        }

        .auftraege-table td {
            border-bottom: 1px solid #F5F5F5;
            padding: 6px 10px;
            white-space: nowrap;
            background: white;
            height: 32px;
        }

        .auftraege-table tr:nth-child(even) td {
            background: #FAFAFA;
        }

        .auftraege-table tr:hover td {
            background: #F5F5F5;
        }

        .auftraege-table tr.selected td {
            background: #E3F2FD;
            color: #1565C0;
        }

        /* Status Bar */
        .status-bar {
            background: #FFFFFF;
            border-top: 1px solid #E0E0E0;
            padding: 6px 12px;
            display: flex;
            gap: 16px;
            font-size: 10px;
            flex-shrink: 0;
            color: #757575;
        }

        .status-section {
            border: none;
            padding: 0;
            background: transparent;
        }

        /* Loading Overlay */
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(250, 250, 250, 0.95);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .loading-overlay.active {
            display: flex;
        }

        .loading-spinner {
            width: 40px;
            height: 40px;
            border: 3px solid #E0E0E0;
            border-top-color: #1565C0;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Modal */
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.4);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 1001;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: #FFFFFF;
            border: 1px solid #E0E0E0;
            border-radius: 8px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.12);
            padding: 0;
            min-width: 320px;
        }

        .modal-header {
            background: #FAFAFA;
            color: #212121;
            padding: 16px 20px;
            border-bottom: 1px solid #E0E0E0;
            display: flex;
            justify-content: space-between;
            border-radius: 8px 8px 0 0;
            font-weight: 500;
        }

        .modal-body {
            padding: 20px;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            padding: 16px 20px;
            border-top: 1px solid #E0E0E0;
        }

        /* Scrollbar - Minimal */
        ::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }

        ::-webkit-scrollbar-track {
            background: #FAFAFA;
        }

        ::-webkit-scrollbar-thumb {
            background: #E0E0E0;
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #BDBDBD;
        }

        /* Toast Notifications */
        .toast-container {
            position: fixed;
            top: 50px;
            right: 16px;
            z-index: 1002;
        }

        .toast {
            background: #212121;
            color: white;
            padding: 12px 20px;
            margin-bottom: 8px;
            border-radius: 4px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            animation: slideIn 0.3s ease;
        }

        .toast.success { background: #4CAF50; }
        .toast.error { background: #F44336; }
        .toast.warning { background: #FF9800; }

        @keyframes slideIn {
            from { transform: translateX(120%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
"""

# === CSS FÜR VARIANTE 8: NORD THEME ===
CSS_NORD = """        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Fira Code', monospace;
            font-size: 11px;
        }

        body {
            background-color: #2E3440;
            overflow: hidden;
            height: 100vh;
        }

        .window-frame {
            background-color: #2E3440;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Title Bar */
        .title-bar {
            background: #3B4252;
            color: #ECEFF4;
            padding: 8px 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            height: 40px;
            flex-shrink: 0;
            border-bottom: 1px solid #434C5E;
        }

        .title-bar-left {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
            font-size: 13px;
        }

        .title-bar-buttons {
            display: flex;
            gap: 6px;
        }

        .title-btn {
            width: 32px;
            height: 32px;
            background: #434C5E;
            border: 1px solid #4C566A;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #D8DEE9;
            transition: all 0.2s;
        }

        .title-btn:hover {
            background: #4C566A;
            border-color: #5E687E;
        }

        .title-btn.close {
            color: #BF616A;
        }

        .title-btn.close:hover {
            background: #BF616A;
            color: #ECEFF4;
        }

        /* Main Container */
        .main-container {
            display: flex;
            flex: 1;
            overflow: hidden;
        }

        /* Left Menu */
        .left-menu {
            width: 180px;
            background-color: #3B4252;
            padding: 12px 8px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            flex-shrink: 0;
            border-right: 1px solid #434C5E;
        }

        .menu-header {
            background-color: transparent;
            color: #88C0D0;
            padding: 8px 12px;
            text-align: left;
            font-weight: 600;
            font-size: 11px;
            margin-bottom: 12px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .menu-buttons {
            display: flex;
            flex-direction: column;
            flex: 1;
            justify-content: space-between;
        }

        .menu-btn {
            background: transparent;
            padding: 10px 12px;
            text-align: left;
            cursor: pointer;
            font-size: 11px;
            color: #D8DEE9;
            font-weight: 400;
            border: none;
            border-left: 2px solid transparent;
            margin: 1px 0;
            transition: all 0.2s;
            border-radius: 0 4px 4px 0;
        }

        .menu-btn:hover {
            background: #434C5E;
            border-left-color: #88C0D0;
        }

        .menu-btn.active {
            background: #434C5E;
            border-left-color: #81A1C1;
            color: #ECEFF4;
            font-weight: 500;
        }

        /* Vollbild-Button */
        .fullscreen-btn {
            position: fixed;
            top: 8px;
            right: 8px;
            width: 32px;
            height: 32px;
            background: #434C5E;
            border: 1px solid #4C566A;
            border-radius: 4px;
            cursor: pointer;
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            color: #D8DEE9;
            transition: all 0.2s;
        }

        .fullscreen-btn:hover {
            background: #4C566A;
        }

        /* Vollbild-Modus */
        body.fullscreen-mode .title-bar {
            display: none;
        }

        /* Content Area */
        .content-area {
            flex: 1;
            background-color: #2E3440;
            padding: 8px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            overflow: hidden;
        }

        /* Header Row */
        .header-row {
            background-color: #3B4252;
            border: 1px solid #434C5E;
            border-radius: 4px;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-shrink: 0;
            flex-wrap: wrap;
        }

        .logo-box {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #81A1C1, #88C0D0);
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ECEFF4;
            font-weight: 600;
            font-size: 18px;
        }

        .title-text {
            font-size: 16px;
            font-weight: 600;
            color: #ECEFF4;
        }

        .header-links {
            display: flex;
            gap: 16px;
            margin-left: 8px;
        }

        .header-link {
            color: #88C0D0;
            text-decoration: none;
            cursor: pointer;
            font-size: 11px;
            border-bottom: 1px solid transparent;
            transition: border-color 0.2s;
        }

        .header-link:hover {
            border-bottom-color: #88C0D0;
        }

        .btn {
            background: #434C5E;
            border: 1px solid #4C566A;
            border-radius: 4px;
            padding: 6px 12px;
            cursor: pointer;
            font-size: 11px;
            white-space: nowrap;
            color: #D8DEE9;
            transition: all 0.2s;
        }

        .btn:hover {
            background: #4C566A;
            border-color: #5E687E;
        }

        .btn:disabled {
            opacity: 0.4;
            cursor: not-allowed;
        }

        .btn-green {
            background: #434C5E;
            border-color: #A3BE8C;
            color: #A3BE8C;
        }

        .btn-green:hover {
            background: #A3BE8C;
            color: #2E3440;
        }

        .btn-yellow {
            background: #434C5E;
            border-color: #EBCB8B;
            color: #EBCB8B;
        }

        .btn-yellow:hover {
            background: #EBCB8B;
            color: #2E3440;
        }

        .btn-red {
            background: #434C5E;
            border-color: #BF616A;
            color: #BF616A;
        }

        .btn-red:hover {
            background: #BF616A;
            color: #ECEFF4;
        }

        /* GPT Box */
        .gpt-box {
            background: #434C5E;
            border: 1px solid #EBCB8B;
            border-radius: 4px;
            padding: 4px 8px;
            font-size: 9px;
            text-align: center;
            line-height: 1.4;
            position: absolute;
            right: 16px;
            top: 12px;
            color: #EBCB8B;
        }

        .header-row-wrapper {
            position: relative;
        }

        /* Button Row */
        .button-row {
            background-color: #3B4252;
            border: 1px solid #434C5E;
            border-radius: 4px;
            padding: 8px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-shrink: 0;
            flex-wrap: wrap;
        }

        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            color: #D8DEE9;
        }

        .status-group {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-left: auto;
        }

        .form-label {
            font-size: 11px;
            color: #D8DEE9;
        }

        .form-select, .form-input {
            border: 1px solid #4C566A;
            border-radius: 4px;
            padding: 4px 8px;
            font-size: 11px;
            background: #434C5E;
            color: #ECEFF4;
            transition: border-color 0.2s;
        }

        .form-input:focus, .form-select:focus {
            outline: none;
            border-color: #88C0D0;
        }

        .form-input.readonly {
            background: #3B4252;
            color: #D8DEE9;
        }

        /* Form Section */
        .form-section {
            background-color: #3B4252;
            border: 1px solid #434C5E;
            border-radius: 4px;
            padding: 16px;
            display: flex;
            gap: 32px;
            flex-shrink: 0;
            flex-wrap: wrap;
        }

        .form-column {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-row {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #D8DEE9;
        }

        .form-column.left .form-label {
            min-width: 45px;
            text-align: right;
        }

        .form-column.middle .form-label {
            min-width: 110px;
            text-align: right;
        }

        .form-column.right .form-label {
            min-width: 90px;
            text-align: right;
        }

        .input-narrow { width: 80px; }
        .input-medium { width: 200px; }
        .input-wide { width: 250px; }

        /* Work Area */
        .work-area {
            display: flex;
            flex: 1;
            gap: 8px;
            overflow: hidden;
        }

        /* Left Work Panel */
        .left-work-panel {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 8px;
            overflow: hidden;
        }

        /* Tab Container */
        .tab-container {
            background-color: #3B4252;
            border: 1px solid #434C5E;
            border-radius: 4px;
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .tab-header {
            display: flex;
            background: #3B4252;
            border-bottom: 1px solid #434C5E;
            flex-shrink: 0;
        }

        .tab-btn {
            padding: 10px 16px;
            background: transparent;
            border: none;
            border-bottom: 2px solid transparent;
            cursor: pointer;
            font-size: 11px;
            color: #D8DEE9;
            transition: all 0.2s;
        }

        .tab-btn:hover {
            color: #ECEFF4;
            background: #434C5E;
        }

        .tab-btn.active {
            color: #88C0D0;
            border-bottom-color: #88C0D0;
            font-weight: 500;
        }

        .tab-content {
            padding: 16px;
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .tab-page {
            display: none;
            flex: 1;
            flex-direction: column;
            overflow: hidden;
        }

        .tab-page.active {
            display: flex;
        }

        .bwn-row {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 12px;
            flex-shrink: 0;
        }

        .status-red {
            color: #BF616A;
            font-weight: 500;
        }

        /* Grid Area */
        .grid-area {
            display: flex;
            gap: 8px;
            flex: 1;
            overflow: hidden;
        }

        /* Left Subform */
        .subform-left {
            width: 200px;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }

        .subform-right {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            min-width: 0;
        }

        .grid-wrapper {
            flex: 1;
            overflow: auto;
            border: 1px solid #434C5E;
            border-radius: 4px;
            background: #2E3440;
        }

        /* Data Grid */
        .data-grid {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
        }

        .data-grid th {
            background: #3B4252;
            border-bottom: 1px solid #434C5E;
            padding: 8px 10px;
            text-align: left;
            font-weight: 500;
            position: sticky;
            top: 0;
            white-space: nowrap;
            font-size: 11px;
            cursor: pointer;
            color: #88C0D0;
        }

        .data-grid th:hover {
            background: #434C5E;
        }

        .data-grid td {
            border-bottom: 1px solid #3B4252;
            padding: 6px 10px;
            height: 32px;
            color: #D8DEE9;
        }

        .data-grid tr:hover {
            background: #3B4252;
        }

        .data-grid tr.selected {
            background: #434C5E;
            color: #88C0D0;
        }

        .data-grid input, .data-grid select {
            border: none;
            width: 100%;
            padding: 0;
            font-size: 11px;
            background: transparent;
            color: #ECEFF4;
        }

        .cell-blue { background-color: rgba(129, 161, 193, 0.2); }
        .cell-green { background-color: rgba(163, 190, 140, 0.2); }
        .cell-yellow { background-color: rgba(235, 203, 139, 0.2); }
        .cell-red { background-color: rgba(191, 97, 106, 0.2); }

        /* Absagen Section */
        .absagen-section {
            margin-top: 8px;
            flex-shrink: 0;
        }

        .absagen-label {
            font-weight: 500;
            margin-bottom: 8px;
            font-size: 11px;
            color: #88C0D0;
        }

        .absagen-grid-wrapper {
            height: 120px;
            overflow: auto;
            border: 1px solid #434C5E;
            border-radius: 4px;
            background: #2E3440;
        }

        /* Right Panel */
        .right-panel {
            width: 420px;
            background: #3B4252;
            border: 1px solid #434C5E;
            border-radius: 4px;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            overflow: hidden;
        }

        .right-header {
            padding: 12px;
            border-bottom: 1px solid #434C5E;
            flex-shrink: 0;
        }

        .status-table {
            width: 100%;
            font-size: 11px;
            border-collapse: collapse;
            color: #D8DEE9;
        }

        .status-table td {
            padding: 6px 8px;
        }

        .status-table .count {
            text-align: right;
            font-weight: 500;
            color: #88C0D0;
        }

        .anzeigen-btn {
            background: #434C5E;
            border: 1px solid #4C566A;
            border-radius: 4px;
            padding: 2px 8px;
            font-size: 10px;
            cursor: pointer;
            color: #D8DEE9;
            transition: all 0.2s;
        }

        .anzeigen-btn:hover {
            background: #4C566A;
        }

        .date-nav {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            background: #2E3440;
            border-bottom: 1px solid #434C5E;
            flex-shrink: 0;
            font-size: 11px;
            color: #D8DEE9;
        }

        .date-input {
            width: 80px;
            border: 1px solid #4C566A;
            border-radius: 4px;
            padding: 4px 8px;
            font-size: 11px;
            background: #434C5E;
            color: #ECEFF4;
        }

        .nav-btn {
            background: #434C5E;
            border: 1px solid #4C566A;
            border-radius: 4px;
            padding: 4px 10px;
            cursor: pointer;
            font-size: 11px;
            color: #D8DEE9;
            transition: all 0.2s;
        }

        .nav-btn:hover {
            background: #4C566A;
        }

        .auftraege-wrapper {
            flex: 1;
            overflow: auto;
        }

        .auftraege-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
        }

        .auftraege-table th {
            background: #3B4252;
            border-bottom: 1px solid #434C5E;
            padding: 8px 10px;
            text-align: left;
            position: sticky;
            top: 0;
            font-weight: 500;
            white-space: nowrap;
            cursor: pointer;
            color: #88C0D0;
        }

        .auftraege-table td {
            border-bottom: 1px solid #3B4252;
            padding: 6px 10px;
            white-space: nowrap;
            background: #2E3440;
            height: 32px;
            color: #D8DEE9;
        }

        .auftraege-table tr:nth-child(even) td {
            background: #3B4252;
        }

        .auftraege-table tr:hover td {
            background: #434C5E;
        }

        .auftraege-table tr.selected td {
            background: #434C5E;
            color: #88C0D0;
        }

        /* Status Bar */
        .status-bar {
            background: #3B4252;
            border-top: 1px solid #434C5E;
            padding: 6px 12px;
            display: flex;
            gap: 16px;
            font-size: 10px;
            flex-shrink: 0;
            color: #D8DEE9;
        }

        .status-section {
            border: none;
            padding: 0;
            background: transparent;
        }

        /* Loading Overlay */
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(46, 52, 64, 0.95);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .loading-overlay.active {
            display: flex;
        }

        .loading-spinner {
            width: 40px;
            height: 40px;
            border: 3px solid #4C566A;
            border-top-color: #88C0D0;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Modal */
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.7);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 1001;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: #3B4252;
            border: 1px solid #434C5E;
            border-radius: 8px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.4);
            padding: 0;
            min-width: 320px;
        }

        .modal-header {
            background: #434C5E;
            color: #ECEFF4;
            padding: 16px 20px;
            border-bottom: 1px solid #4C566A;
            display: flex;
            justify-content: space-between;
            border-radius: 8px 8px 0 0;
            font-weight: 500;
        }

        .modal-body {
            padding: 20px;
            color: #D8DEE9;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            padding: 16px 20px;
            border-top: 1px solid #434C5E;
        }

        /* Scrollbar */
        ::-webkit-scrollbar {
            width: 10px;
            height: 10px;
        }

        ::-webkit-scrollbar-track {
            background: #2E3440;
        }

        ::-webkit-scrollbar-thumb {
            background: #4C566A;
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #5E687E;
        }

        /* Toast Notifications */
        .toast-container {
            position: fixed;
            top: 50px;
            right: 16px;
            z-index: 1002;
        }

        .toast {
            background: #434C5E;
            color: #ECEFF4;
            padding: 12px 20px;
            margin-bottom: 8px;
            border-radius: 4px;
            border-left: 3px solid #88C0D0;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            animation: slideIn 0.3s ease;
        }

        .toast.success { border-left-color: #A3BE8C; }
        .toast.error { border-left-color: #BF616A; }
        .toast.warning { border-left-color: #EBCB8B; }

        @keyframes slideIn {
            from { transform: translateX(120%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
"""


def replace_css_section(html_content, new_css):
    """
    Ersetzt die CSS-Sektion zwischen <style> und </style> durch neues CSS.
    """
    pattern = r'(<style>)(.*?)(</style>)'

    def replacer(match):
        return match.group(1) + '\n' + new_css + '    ' + match.group(3)

    result = re.sub(pattern, replacer, html_content, flags=re.DOTALL)
    return result


def main():
    print("=" * 70)
    print("Design Variants Generator - Auftragsverwaltung")
    print("=" * 70)
    print()

    # Prüfe Original-Datei
    if not os.path.exists(ORIGINAL_FILE):
        print(f"FEHLER: Original-Datei nicht gefunden!")
        print(f"Pfad: {ORIGINAL_FILE}")
        return

    # Lese Original
    print(f"Lese Original-Datei...")
    with open(ORIGINAL_FILE, 'r', encoding='utf-8') as f:
        original_content = f.read()

    print(f"✓ Gelesen: {len(original_content):,} Zeichen")
    print()

    # === VARIANTE 7: MINIMALIST WHITE ===
    print("Erstelle Variante 7: Minimalist White")
    print("-" * 70)

    var07_content = replace_css_section(original_content, CSS_MINIMALIST)
    var07_content = var07_content.replace(
        '<title>Auftragsverwaltung</title>',
        '<title>Auftragsverwaltung - Minimalist White</title>'
    )

    var07_path = os.path.join(OUTPUT_DIR, 'variante_07_minimalist.html')
    with open(var07_path, 'w', encoding='utf-8') as f:
        f.write(var07_content)

    print(f"✓ Datei erstellt: {var07_path}")
    print(f"  Größe: {len(var07_content):,} Zeichen")
    print(f"  Design: Ultra-cleanes Minimalist-Design")
    print(f"  Farben: Weiß (#FAFAFA), Grau (#E0E0E0), Blau (#1565C0)")
    print()

    # === VARIANTE 8: NORD THEME ===
    print("Erstelle Variante 8: Nord Theme")
    print("-" * 70)

    var08_content = replace_css_section(original_content, CSS_NORD)
    var08_content = var08_content.replace(
        '<title>Auftragsverwaltung</title>',
        '<title>Auftragsverwaltung - Nord Theme</title>'
    )

    var08_path = os.path.join(OUTPUT_DIR, 'variante_08_nord.html')
    with open(var08_path, 'w', encoding='utf-8') as f:
        f.write(var08_content)

    print(f"✓ Datei erstellt: {var08_path}")
    print(f"  Größe: {len(var08_content):,} Zeichen")
    print(f"  Design: Nord Color Scheme (nordtheme.com)")
    print(f"  Farben: Polar Night, Snow Storm, Frost, Aurora")
    print()

    # === ZUSAMMENFASSUNG ===
    print("=" * 70)
    print("FERTIG! Beide Varianten wurden erstellt:")
    print("=" * 70)
    print()
    print(f"📁 Ordner: {OUTPUT_DIR}")
    print()
    print("📄 Variante 7: variante_07_minimalist.html")
    print("   → Ultra-clean, viel Weißraum, dezente Akzente")
    print()
    print("📄 Variante 8: variante_08_nord.html")
    print("   → Nord Theme, dunkle Farbpalette, modern")
    print()
    print("💡 Beide Varianten haben:")
    print("   - Identische HTML-Struktur")
    print("   - Identisches JavaScript")
    print("   - NUR angepasstes CSS")
    print()
    print("🚀 Zum Testen: Dateien im Browser öffnen")
    print("=" * 70)


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"\n❌ FEHLER: {e}")
        import traceback
        traceback.print_exc()
