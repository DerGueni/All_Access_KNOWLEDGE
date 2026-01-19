/**
 * CONSEC PLANUNG - Login Page Logic
 */

document.addEventListener('DOMContentLoaded', () => {
    // Prüfen ob bereits eingeloggt
    if (App.isLoggedIn()) {
        window.location.href = 'dashboard.html';
        return;
    }

    // Gespeicherte E-Mail laden
    const savedUser = App.localStorage.get('savedUser');
    if (savedUser && savedUser.email) {
        document.getElementById('email').value = savedUser.email;
        document.getElementById('remember').checked = true;
    }

    // Login Form Handler
    const loginForm = document.getElementById('loginForm');
    const loginBtn = loginForm.querySelector('.btn-login');
    const btnText = loginBtn.querySelector('.btn-text');
    const btnLoader = loginBtn.querySelector('.btn-loader');
    const errorDiv = document.getElementById('loginError');

    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const email = document.getElementById('email').value.trim();
        const password = document.getElementById('password').value;
        const remember = document.getElementById('remember').checked;

        // Validierung
        if (!email || !password) {
            showError('Bitte alle Felder ausfüllen');
            return;
        }

        // Loading State
        setLoading(true);
        hideError();

        try {
            await App.login(email, password, remember);
            // Erfolg - weiterleiten
            window.location.href = 'dashboard.html';
        } catch (error) {
            console.error('Login failed:', error);
            showError(error.message || 'Anmeldung fehlgeschlagen. Bitte prüfen Sie Ihre Eingaben.');
            setLoading(false);
        }
    });

    // Password Toggle
    const togglePassword = document.querySelector('.toggle-password');
    const passwordInput = document.getElementById('password');

    togglePassword.addEventListener('click', () => {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        togglePassword.classList.toggle('active');
    });

    // Helper Functions
    function setLoading(loading) {
        loginBtn.disabled = loading;
        btnText.classList.toggle('hidden', loading);
        btnLoader.classList.toggle('hidden', !loading);
    }

    function showError(message) {
        errorDiv.textContent = message;
        errorDiv.classList.remove('hidden');
    }

    function hideError() {
        errorDiv.classList.add('hidden');
    }
});
