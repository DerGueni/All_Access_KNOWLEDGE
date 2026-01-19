const forms = {
    auftragstamm: { title: 'Auftragstamm', file: 'frm_va_Auftragstamm.html' },
    mitarbeiterstamm: { title: 'Mitarbeiterstamm', file: 'frm_MA_Mitarbeiterstamm.html' },
    kundenstamm: { title: 'Kundenstamm', file: 'frm_KD_Kundenstamm.html' },
    schnellauswahl: { title: 'Schnellauswahl', file: 'frm_MA_VA_Schnellauswahl.html' },
    dienstplanuebersicht: { title: 'Dienstplanuebersicht', file: 'frm_N_Dienstplanuebersicht.html' },
    planungsuebersicht: { title: 'Planungsuebersicht', file: 'frm_VA_Planungsuebersicht.html' }
};

const tabList = document.getElementById('tabList');
const content = document.getElementById('tabContent');
const currentFormLabel = document.getElementById('currentForm');

const openTabs = new Map();
let activeTabId = null;

function openForm(formId) {
    if (!forms[formId]) return;

    if (!openTabs.has(formId)) {
        const tabEl = document.createElement('div');
        tabEl.className = 'tab';
        tabEl.dataset.form = formId;
        tabEl.innerHTML = `<span>${forms[formId].title}</span><span class="close">×</span>`;
        tabList.appendChild(tabEl);

        const iframe = document.createElement('iframe');
        iframe.className = 'shell-iframe';
        iframe.dataset.form = formId;
        iframe.src = `${forms[formId].file}?embedded=1`;
        content.appendChild(iframe);

        openTabs.set(formId, { tabEl, iframe });

        tabEl.addEventListener('click', (e) => {
            if (e.target.classList.contains('close')) {
                closeForm(formId);
            } else {
                setActive(formId);
            }
        });
    }

    setActive(formId);
    persistTabs();
}

function setActive(formId) {
    openTabs.forEach((value, id) => {
        value.tabEl.classList.toggle('active', id === formId);
        value.iframe.classList.toggle('active', id === formId);
    });
    activeTabId = formId;
    currentFormLabel.textContent = forms[formId].title;
    persistTabs();
}

function closeForm(formId) {
    const entry = openTabs.get(formId);
    if (!entry) return;
    entry.tabEl.remove();
    entry.iframe.remove();
    openTabs.delete(formId);

    if (activeTabId === formId) {
        const next = openTabs.keys().next().value;
        if (next) setActive(next);
        else currentFormLabel.textContent = 'Kein Formular';
    }
    persistTabs();
}

function persistTabs() {
    const ids = Array.from(openTabs.keys());
    localStorage.setItem('consec_tabs', JSON.stringify(ids));
    localStorage.setItem('consec_active', activeTabId || '');
}

function restoreTabs() {
    const ids = JSON.parse(localStorage.getItem('consec_tabs') || '[]');
    const active = localStorage.getItem('consec_active');
    ids.forEach(openForm);
    if (active && openTabs.has(active)) setActive(active);
}

function getQueryForm() {
    const params = new URLSearchParams(location.search);
    return params.get('form');
}

function initSidebar() {
    document.querySelectorAll('[data-form]').forEach(btn => {
        btn.addEventListener('click', () => openForm(btn.dataset.form));
    });
}

// Expose shell API for embedded forms
window.ConsysShell = {
    showForm: openForm
};

restoreTabs();
initSidebar();

const initial = getQueryForm() || 'auftragstamm';
openForm(initial);
