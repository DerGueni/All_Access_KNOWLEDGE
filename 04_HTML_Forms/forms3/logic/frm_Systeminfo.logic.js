// ============================================================
// frm_Systeminfo.logic.js
// Logic-Datei fuer Systeminfo-Formular
// ============================================================

// === Form_Open (Access: Form_Open) ===
function Form_Open() {
    // Datum setzen (wie Access: Me!lbl_Datum.caption = Date)
    const heute = new Date();
    document.getElementById('datum').textContent = heute.toLocaleDateString('de-DE');

    // Public IP ermitteln (wie Access: Me!PublicIP = GetPublicIP())
    getPublicIP();
}

// === Form_Load (Access: Form_Load) ===
function Form_Load() {
    // Browser-Infos
    document.getElementById('browser').textContent = navigator.userAgent.split(' ').slice(-2).join(' ');
    document.getElementById('platform').textContent = navigator.platform;
    document.getElementById('screen').textContent = `${screen.width} x ${screen.height}`;
    document.getElementById('language').textContent = navigator.language;
    document.getElementById('formsPath').textContent = window.location.pathname;

    // Memory-Info (wie Access: api_UpdateSysResInfo)
    updateMemoryInfo();

    // API Status pruefen
    checkAPIStatus();

    // Frontend/Backend Pfade laden
    loadDatabasePaths();
}

// === cmdOK_Click (Access: cmdOK_Click) ===
function cmdOK_Click() {
    // DoCmd.Close - Fenster schliessen
    if (window.parent && window.parent !== window) {
        // In iframe - Parent benachrichtigen
        window.parent.postMessage({ type: 'CLOSE_FORM', form: 'frm_Systeminfo' }, '*');
    } else {
        window.close();
    }
}

// === btnHelp_Click (Access: btnHelp_Click) ===
function btnHelp_Click() {
    // DoCmd.OpenForm "frm_Hilfe_Anzeige"
    alert('Hilfe fuer Systeminfo:\n\nDieses Formular zeigt Systeminformationen an.\n- API Status zeigt ob Server erreichbar sind\n- Speicher zeigt Browser-Heap-Auslastung');
}

// === GetPublicIP (Access: GetPublicIP) ===
async function getPublicIP() {
    try {
        const response = await fetch('https://api.ipify.org?format=json');
        const data = await response.json();
        document.getElementById('publicIP').textContent = data.ip;
    } catch (e) {
        document.getElementById('publicIP').textContent = 'Nicht ermittelbar';
    }
}

// === api_UpdateSysResInfo (Access-Equivalent) ===
function updateMemoryInfo() {
    if (performance && performance.memory) {
        const used = performance.memory.usedJSHeapSize;
        const total = performance.memory.jsHeapSizeLimit;
        const percent = Math.round((used / total) * 100);

        const fill = document.getElementById('memoryFill');
        const text = document.getElementById('memoryText');

        fill.style.width = percent + '%';
        text.textContent = percent + '%';

        // Farben wie in Access
        if (percent < 15) {
            fill.style.backgroundColor = '#00ff00'; // Gruen
        } else if (percent < 50) {
            fill.style.backgroundColor = '#ffff00'; // Gelb
        } else {
            fill.style.backgroundColor = '#ff0000'; // Rot
        }

        document.getElementById('heapLimit').textContent =
            Math.round(total / 1024 / 1024) + ' MB';
    } else {
        document.getElementById('memoryText').textContent = 'N/A';
        document.getElementById('heapLimit').textContent = 'Nicht verfuegbar (nur Chrome)';
    }
}

// === API Status pruefen ===
async function checkAPIStatus() {
    // REST API (Port 5000)
    try {
        const response = await fetch('http://localhost:5000/api/tables', {
            method: 'GET',
            signal: AbortSignal.timeout(3000)
        });
        document.getElementById('apiStatus').textContent = response.ok ? 'Online' : 'Fehler';
        document.getElementById('apiStatus').style.color = response.ok ? 'green' : 'red';
    } catch (e) {
        document.getElementById('apiStatus').textContent = 'Offline';
        document.getElementById('apiStatus').style.color = 'red';
    }

    // VBA Bridge (Port 5002)
    try {
        const response = await fetch('http://localhost:5002/api/status', {
            method: 'GET',
            signal: AbortSignal.timeout(3000)
        });
        document.getElementById('vbaBridgeStatus').textContent = response.ok ? 'Online' : 'Fehler';
        document.getElementById('vbaBridgeStatus').style.color = response.ok ? 'green' : 'red';
    } catch (e) {
        document.getElementById('vbaBridgeStatus').textContent = 'Offline';
        document.getElementById('vbaBridgeStatus').style.color = 'red';
    }
}

// === Datenbank-Pfade laden (wie Access: Info_Frontend/Info_Backend) ===
async function loadDatabasePaths() {
    try {
        const response = await fetch('http://localhost:5000/api/status');
        if (response.ok) {
            const data = await response.json();
            if (data.frontend) {
                document.getElementById('frontendPath').textContent = data.frontend;
            }
            if (data.backend) {
                document.getElementById('backendPath').textContent = data.backend;
            }
        }
    } catch (e) {
        document.getElementById('frontendPath').textContent = 'API nicht erreichbar';
        document.getElementById('backendPath').textContent = 'API nicht erreichbar';
    }
}

// === Initialisierung ===
document.addEventListener('DOMContentLoaded', function() {
    Form_Open();
    Form_Load();

    // Speicher-Update alle 5 Sekunden (wie Access Timer)
    setInterval(updateMemoryInfo, 5000);
});

// === Window Exports fuer onclick Handler ===
window.cmdOK_Click = cmdOK_Click;
window.btnHelp_Click = btnHelp_Click;
