/**
 * CONSEC PLANUNG - Mobile App
 * Gemeinsame Funktionen und API-Client
 */

const App = {
    // API Base URL
    API_BASE: 'http://localhost:5000/api',

    // Aktueller Benutzer
    currentUser: null,

    /**
     * API Request Helper
     */
    async api(endpoint, options = {}) {
        const url = `${this.API_BASE}${endpoint}`;
        const defaultOptions = {
            headers: {
                'Content-Type': 'application/json',
            },
        };

        try {
            const response = await fetch(url, { ...defaultOptions, ...options });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    },

    /**
     * GET Request
     */
    async get(endpoint) {
        return this.api(endpoint, { method: 'GET' });
    },

    /**
     * POST Request
     */
    async post(endpoint, data) {
        return this.api(endpoint, {
            method: 'POST',
            body: JSON.stringify(data),
        });
    },

    /**
     * PUT Request
     */
    async put(endpoint, data) {
        return this.api(endpoint, {
            method: 'PUT',
            body: JSON.stringify(data),
        });
    },

    /**
     * Session Storage Helpers
     */
    storage: {
        set(key, value) {
            try {
                sessionStorage.setItem(key, JSON.stringify(value));
            } catch (e) {
                console.error('Storage error:', e);
            }
        },

        get(key) {
            try {
                const value = sessionStorage.getItem(key);
                return value ? JSON.parse(value) : null;
            } catch (e) {
                console.error('Storage error:', e);
                return null;
            }
        },

        remove(key) {
            try {
                sessionStorage.removeItem(key);
            } catch (e) {
                console.error('Storage error:', e);
            }
        },

        clear() {
            try {
                sessionStorage.clear();
            } catch (e) {
                console.error('Storage error:', e);
            }
        }
    },

    /**
     * Local Storage (für "Angemeldet bleiben")
     */
    localStorage: {
        set(key, value) {
            try {
                localStorage.setItem(key, JSON.stringify(value));
            } catch (e) {
                console.error('LocalStorage error:', e);
            }
        },

        get(key) {
            try {
                const value = localStorage.getItem(key);
                return value ? JSON.parse(value) : null;
            } catch (e) {
                console.error('LocalStorage error:', e);
                return null;
            }
        },

        remove(key) {
            try {
                localStorage.removeItem(key);
            } catch (e) {
                console.error('LocalStorage error:', e);
            }
        }
    },

    /**
     * Benutzer einloggen
     */
    async login(email, password, remember = false) {
        // Versuche Mitarbeiter anhand E-Mail oder Mobilnummer zu finden
        const response = await this.get('/mitarbeiter');
        const mitarbeiter = response.data || response; // Unterstützt beide Formate

        // Suche nach E-Mail oder Telefon (unterstützt beide Feldnamen-Varianten)
        const searchTerm = email.toLowerCase().replace(/\s/g, '');
        const user = mitarbeiter.find(m => {
            const userEmail = (m.Email || '').toLowerCase();
            const userTel = (m.Tel_Mobil || m.TelMobil || '').replace(/\s/g, '').replace(/-/g, '');
            return userEmail === searchTerm || userTel.includes(searchTerm.replace(/-/g, ''));
        });

        if (!user) {
            throw new Error('Benutzer nicht gefunden');
        }

        // In einer echten App würde hier das Passwort geprüft werden
        // Für Demo: Akzeptiere jedes Passwort oder "1234" als PIN
        if (password !== '1234' && password.length < 4) {
            throw new Error('Ungültiges Passwort');
        }

        // Benutzer speichern (unterstützt beide Feldnamen-Varianten)
        const userData = {
            id: user.ID || user.MA_ID,
            vorname: user.Vorname,
            nachname: user.Nachname,
            email: user.Email,
            telefon: user.Tel_Mobil || user.TelMobil
        };

        this.currentUser = userData;
        this.storage.set('user', userData);

        if (remember) {
            this.localStorage.set('savedUser', { email });
        }

        return userData;
    },

    /**
     * Benutzer ausloggen
     */
    logout() {
        this.currentUser = null;
        this.storage.remove('user');
        window.location.href = 'index.html';
    },

    /**
     * Prüfen ob eingeloggt
     */
    isLoggedIn() {
        if (this.currentUser) return true;

        const user = this.storage.get('user');
        if (user) {
            this.currentUser = user;
            return true;
        }
        return false;
    },

    /**
     * Aktuellen Benutzer holen
     */
    getUser() {
        if (!this.currentUser) {
            this.currentUser = this.storage.get('user');
        }
        return this.currentUser;
    },

    /**
     * Toast Notification anzeigen
     */
    toast(message, type = 'info') {
        const container = document.getElementById('toastContainer');
        if (!container) return;

        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.textContent = message;
        container.appendChild(toast);

        setTimeout(() => {
            toast.remove();
        }, 3000);
    },

    /**
     * Datum formatieren
     */
    formatDate(dateStr) {
        if (!dateStr) return '-';
        const date = new Date(dateStr);
        const days = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
        const day = days[date.getDay()];
        const d = date.getDate().toString().padStart(2, '0');
        const m = (date.getMonth() + 1).toString().padStart(2, '0');
        const y = date.getFullYear().toString().slice(-2);
        return `${day}. ${d}.${m}.${y}`;
    },

    /**
     * Zeit formatieren
     */
    formatTime(timeStr) {
        if (!timeStr) return '-';
        // Wenn es ein Date-String ist
        if (timeStr.includes('T') || timeStr.includes(' ')) {
            const date = new Date(timeStr);
            return date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
        }
        // Wenn es bereits HH:MM Format ist
        return timeStr.substring(0, 5);
    },

    /**
     * QR Code generieren (einfache SVG-Version)
     */
    generateQRCode(data, size = 200) {
        // Einfacher QR-Code Platzhalter
        // In Produktion würde hier eine QR-Code Library verwendet werden
        return `
            <svg width="${size}" height="${size}" viewBox="0 0 100 100">
                <rect width="100" height="100" fill="white"/>
                <rect x="10" y="10" width="25" height="25" fill="black"/>
                <rect x="65" y="10" width="25" height="25" fill="black"/>
                <rect x="10" y="65" width="25" height="25" fill="black"/>
                <rect x="15" y="15" width="15" height="15" fill="white"/>
                <rect x="70" y="15" width="15" height="15" fill="white"/>
                <rect x="15" y="70" width="15" height="15" fill="white"/>
                <rect x="20" y="20" width="5" height="5" fill="black"/>
                <rect x="75" y="20" width="5" height="5" fill="black"/>
                <rect x="20" y="75" width="5" height="5" fill="black"/>
                <rect x="40" y="40" width="20" height="20" fill="black"/>
                <text x="50" y="95" text-anchor="middle" font-size="6" fill="#666">ID: ${data}</text>
            </svg>
        `;
    }
};

// Export für Module
if (typeof module !== 'undefined' && module.exports) {
    module.exports = App;
}
