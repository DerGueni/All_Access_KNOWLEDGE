/**
 * FORM VALIDATOR - Automatisches Pruefskript fuer HTML-Formulare
 *
 * Prueft HTML-Formulare auf:
 * - Buttons ohne Funktion
 * - Felder ohne Datenbindung
 * - Datumsfilter ohne Wirkung
 * - Tote Links/Navigation
 *
 * Verwendung:
 *   Node.js: node form_validator.js [--json] [--html]
 *   Browser: <script src="form_validator.js"></script> dann FormValidator.runAll()
 *
 * Erstellt: 2026-01-06
 */

const FormValidator = {
    // Konfiguration
    config: {
        formsPath: '../',
        excludePatterns: ['backup', '_test', 'variante', 'design_varianten', 'sidebar_varianten', 'electron', 'HTMLBodies'],
        knownForms: [
            'frm_MA_Mitarbeiterstamm.html',
            'frm_KD_Kundenstamm.html',
            'frm_va_Auftragstamm.html',
            'frm_OB_Objekt.html',
            'frm_N_Dienstplanuebersicht.html',
            'frm_VA_Planungsuebersicht.html',
            'frm_Einsatzuebersicht.html',
            'frm_MA_VA_Schnellauswahl.html',
            'frm_MA_Abwesenheit.html',
            'frm_MA_Zeitkonten.html',
            'frm_N_Lohnabrechnungen.html',
            'frm_N_Stundenauswertung.html',
            'frm_Menuefuehrung1.html',
            'frm_DP_Dienstplan_MA.html',
            'frm_DP_Dienstplan_Objekt.html',
            'frm_N_Bewerber.html',
            'frm_Abwesenheiten.html',
            'frm_abwesenheitsuebersicht.html',
            'frm_Ausweis_Create.html',
            'shell.html'
        ]
    },

    // Ergebnisse
    results: {
        timestamp: null,
        forms: {},
        summary: {
            totalForms: 0,
            totalButtons: 0,
            buttonsWithoutHandler: 0,
            totalFields: 0,
            fieldsWithoutBinding: 0,
            totalDateFilters: 0,
            dateFiltersWithoutEffect: 0,
            totalLinks: 0,
            deadLinks: 0
        }
    },

    /**
     * Prueft einen Button auf Event-Handler
     */
    checkButton(button, formContext) {
        const issues = [];
        const id = button.id || button.getAttribute('data-id') || '(kein ID)';
        const text = button.textContent?.trim() || button.value || '';

        // Pruefe auf onclick
        const hasOnclick = button.hasAttribute('onclick') && button.getAttribute('onclick').trim() !== '';

        // Pruefe auf addEventListener (kann nur via Inspektion des Scripts geprueft werden)
        const hasEventListener = formContext.eventListeners?.includes(id);

        // Pruefe auf href bei Links als Buttons
        const hasHref = button.tagName === 'A' && button.hasAttribute('href') && button.getAttribute('href') !== '#';

        // Pruefe auf type="submit" bei Formularen
        const isSubmit = button.getAttribute('type') === 'submit';

        // Pruefe auf data-action
        const hasDataAction = button.hasAttribute('data-action');

        const hasHandler = hasOnclick || hasEventListener || hasHref || isSubmit || hasDataAction;

        if (!hasHandler) {
            issues.push({
                type: 'BUTTON_NO_HANDLER',
                severity: 'HIGH',
                element: id,
                text: text.substring(0, 50),
                message: `Button "${id}" hat keinen Event-Handler (onclick, addEventListener, href)`
            });
        }

        // Pruefe auf leeren Handler
        if (hasOnclick) {
            const onclick = button.getAttribute('onclick');
            if (onclick === '' || onclick === 'return false;' || onclick === 'void(0)') {
                issues.push({
                    type: 'BUTTON_EMPTY_HANDLER',
                    severity: 'MEDIUM',
                    element: id,
                    text: text.substring(0, 50),
                    message: `Button "${id}" hat leeren onclick-Handler: "${onclick}"`
                });
            }
        }

        return issues;
    },

    /**
     * Prueft ein Eingabefeld auf Datenbindung
     */
    checkField(field, formContext) {
        const issues = [];
        const id = field.id || field.name || '(kein ID)';
        const type = field.getAttribute('type') || field.tagName.toLowerCase();

        // Pruefe auf data-field Attribut
        const hasDataField = field.hasAttribute('data-field');

        // Pruefe auf name Attribut
        const hasName = field.hasAttribute('name') && field.getAttribute('name').trim() !== '';

        // Pruefe auf v-model (Vue) oder ng-model (Angular)
        const hasVModel = field.hasAttribute('v-model') || field.hasAttribute('ng-model');

        // Pruefe ob Feld in JS referenziert wird (via formContext)
        const isReferencedInJS = formContext.fieldReferences?.includes(id);

        // Readonly-Felder brauchen nicht immer Binding
        const isReadonly = field.hasAttribute('readonly') || field.hasAttribute('disabled');

        // Hidden-Felder sind OK ohne sichtbare Bindung
        const isHidden = type === 'hidden';

        const hasBinding = hasDataField || hasName || hasVModel || isReferencedInJS || isHidden;

        if (!hasBinding && !isReadonly) {
            issues.push({
                type: 'FIELD_NO_BINDING',
                severity: 'MEDIUM',
                element: id,
                fieldType: type,
                message: `Feld "${id}" (${type}) hat keine Datenbindung (data-field, name, v-model)`
            });
        }

        return issues;
    },

    /**
     * Prueft Datumsfilter auf Wirksamkeit
     */
    checkDateFilter(filter, formContext) {
        const issues = [];
        const id = filter.id || '(kein ID)';

        // Pruefe auf onchange-Handler
        const hasOnchange = filter.hasAttribute('onchange') && filter.getAttribute('onchange').trim() !== '';

        // Pruefe auf addEventListener
        const hasEventListener = formContext.eventListeners?.includes(id);

        // Pruefe ob Filter in einer Filterfunktion verwendet wird
        const isUsedInFilter = formContext.filterReferences?.includes(id);

        const hasEffect = hasOnchange || hasEventListener || isUsedInFilter;

        if (!hasEffect) {
            issues.push({
                type: 'DATE_FILTER_NO_EFFECT',
                severity: 'HIGH',
                element: id,
                message: `Datumsfilter "${id}" hat keinen onchange-Handler und wird nicht in Filterfunktion verwendet`
            });
        }

        return issues;
    },

    /**
     * Prueft Navigation auf tote Links
     */
    checkNavigation(link, formContext) {
        const issues = [];
        const href = link.getAttribute('href') || '';
        const onclick = link.getAttribute('onclick') || '';
        const dataNav = link.getAttribute('data-nav') || '';
        const text = link.textContent?.trim() || '';

        // Pruefe Bridge.navigate Aufrufe
        const navigateMatch = onclick.match(/Bridge\.navigate\(['"]([^'"]+)['"]/);
        if (navigateMatch) {
            const target = navigateMatch[1];
            const targetFile = target.endsWith('.html') ? target : `${target}.html`;

            // Pruefe ob Zieldatei existiert (in bekannten Formularen)
            if (!this.config.knownForms.includes(targetFile) &&
                !this.config.knownForms.some(f => f.toLowerCase() === targetFile.toLowerCase())) {
                issues.push({
                    type: 'DEAD_LINK_NAVIGATE',
                    severity: 'HIGH',
                    target: targetFile,
                    linkText: text.substring(0, 30),
                    message: `Bridge.navigate zu nicht-existierendem Formular: "${targetFile}"`
                });
            }
        }

        // Pruefe href auf tote Links
        if (href && href !== '#' && href !== 'javascript:void(0)' && !href.startsWith('http')) {
            const targetFile = href.split('?')[0].split('#')[0];
            if (targetFile.endsWith('.html') &&
                !this.config.knownForms.includes(targetFile) &&
                !this.config.knownForms.some(f => f.toLowerCase() === targetFile.toLowerCase())) {
                issues.push({
                    type: 'DEAD_LINK_HREF',
                    severity: 'MEDIUM',
                    target: targetFile,
                    linkText: text.substring(0, 30),
                    message: `href verweist auf nicht-existierendes Formular: "${targetFile}"`
                });
            }
        }

        return issues;
    },

    /**
     * Extrahiert Kontext aus eingebettetem JavaScript
     */
    extractJSContext(htmlContent) {
        const context = {
            eventListeners: [],
            fieldReferences: [],
            filterReferences: [],
            functions: []
        };

        // Finde alle addEventListener Aufrufe
        const addEventListenerRegex = /(?:getElementById|querySelector)\(['"]#?([^'"]+)['"]\)[\s\S]*?\.addEventListener/g;
        let match;
        while ((match = addEventListenerRegex.exec(htmlContent)) !== null) {
            context.eventListeners.push(match[1]);
        }

        // Finde alle getElementById Referenzen
        const getElementByIdRegex = /getElementById\(['"]([^'"]+)['"]\)/g;
        while ((match = getElementByIdRegex.exec(htmlContent)) !== null) {
            context.fieldReferences.push(match[1]);
        }

        // Finde Filter-Funktionen
        const filterFunctionRegex = /function\s+(?:filter|load|apply)[\w]*\s*\([^)]*\)\s*\{([^}]+)\}/gi;
        while ((match = filterFunctionRegex.exec(htmlContent)) !== null) {
            const funcBody = match[1];
            // Extrahiere referenzierte IDs
            const idRefs = funcBody.match(/getElementById\(['"]([^'"]+)['"]\)/g) || [];
            idRefs.forEach(ref => {
                const idMatch = ref.match(/getElementById\(['"]([^'"]+)['"]\)/);
                if (idMatch) {
                    context.filterReferences.push(idMatch[1]);
                }
            });
        }

        // Finde Funktionsnamen
        const functionRegex = /function\s+(\w+)\s*\(/g;
        while ((match = functionRegex.exec(htmlContent)) !== null) {
            context.functions.push(match[1]);
        }

        return context;
    },

    /**
     * Validiert ein einzelnes HTML-Formular
     */
    validateForm(formName, htmlContent) {
        const result = {
            name: formName,
            timestamp: new Date().toISOString(),
            issues: [],
            stats: {
                buttons: 0,
                buttonsWithoutHandler: 0,
                fields: 0,
                fieldsWithoutBinding: 0,
                dateFilters: 0,
                dateFiltersWithoutEffect: 0,
                links: 0,
                deadLinks: 0
            }
        };

        // Parse HTML (Browser oder Node.js)
        let doc;
        if (typeof DOMParser !== 'undefined') {
            doc = new DOMParser().parseFromString(htmlContent, 'text/html');
        } else {
            // Node.js - vereinfachte Regex-basierte Analyse
            return this.validateFormWithRegex(formName, htmlContent);
        }

        // Extrahiere JS-Kontext
        const jsContext = this.extractJSContext(htmlContent);

        // Pruefe Buttons
        const buttons = doc.querySelectorAll('button, input[type="button"], input[type="submit"], .btn, [role="button"]');
        result.stats.buttons = buttons.length;
        buttons.forEach(btn => {
            const issues = this.checkButton(btn, jsContext);
            if (issues.length > 0) {
                result.issues.push(...issues);
                result.stats.buttonsWithoutHandler += issues.filter(i => i.type === 'BUTTON_NO_HANDLER').length;
            }
        });

        // Pruefe Felder
        const fields = doc.querySelectorAll('input:not([type="button"]):not([type="submit"]), select, textarea');
        result.stats.fields = fields.length;
        fields.forEach(field => {
            const issues = this.checkField(field, jsContext);
            if (issues.length > 0) {
                result.issues.push(...issues);
                result.stats.fieldsWithoutBinding += issues.filter(i => i.type === 'FIELD_NO_BINDING').length;
            }
        });

        // Pruefe Datumsfilter
        const dateFilters = doc.querySelectorAll('input[type="date"], input[type="datetime-local"], [data-filter="date"]');
        result.stats.dateFilters = dateFilters.length;
        dateFilters.forEach(filter => {
            const issues = this.checkDateFilter(filter, jsContext);
            if (issues.length > 0) {
                result.issues.push(...issues);
                result.stats.dateFiltersWithoutEffect += issues.filter(i => i.type === 'DATE_FILTER_NO_EFFECT').length;
            }
        });

        // Pruefe Navigation
        const links = doc.querySelectorAll('a[href], [onclick*="navigate"], [data-nav]');
        result.stats.links = links.length;
        links.forEach(link => {
            const issues = this.checkNavigation(link, jsContext);
            if (issues.length > 0) {
                result.issues.push(...issues);
                result.stats.deadLinks += issues.filter(i => i.type.startsWith('DEAD_LINK')).length;
            }
        });

        return result;
    },

    /**
     * Regex-basierte Validierung fuer Node.js ohne DOM
     */
    validateFormWithRegex(formName, htmlContent) {
        const result = {
            name: formName,
            timestamp: new Date().toISOString(),
            issues: [],
            stats: {
                buttons: 0,
                buttonsWithoutHandler: 0,
                fields: 0,
                fieldsWithoutBinding: 0,
                dateFilters: 0,
                dateFiltersWithoutEffect: 0,
                links: 0,
                deadLinks: 0
            }
        };

        const jsContext = this.extractJSContext(htmlContent);

        // Buttons finden
        const buttonRegex = /<button[^>]*>[\s\S]*?<\/button>|<input[^>]*type=["'](?:button|submit)["'][^>]*>/gi;
        const buttons = htmlContent.match(buttonRegex) || [];
        result.stats.buttons = buttons.length;

        buttons.forEach(btnHtml => {
            const idMatch = btnHtml.match(/id=["']([^"']+)["']/i);
            const onclickMatch = btnHtml.match(/onclick=["']([^"']+)["']/i);
            const textMatch = btnHtml.match(/>([^<]+)</);

            const id = idMatch ? idMatch[1] : '(kein ID)';
            const hasOnclick = onclickMatch && onclickMatch[1].trim() !== '';
            const hasEventListener = jsContext.eventListeners.includes(id);

            if (!hasOnclick && !hasEventListener) {
                result.issues.push({
                    type: 'BUTTON_NO_HANDLER',
                    severity: 'HIGH',
                    element: id,
                    text: textMatch ? textMatch[1].substring(0, 50) : '',
                    message: `Button "${id}" hat keinen Event-Handler`
                });
                result.stats.buttonsWithoutHandler++;
            }
        });

        // Felder finden
        const fieldRegex = /<input[^>]*type=["'](?!button|submit|hidden)[^"']*["'][^>]*>|<select[^>]*>|<textarea[^>]*>/gi;
        const fields = htmlContent.match(fieldRegex) || [];
        result.stats.fields = fields.length;

        fields.forEach(fieldHtml => {
            const idMatch = fieldHtml.match(/id=["']([^"']+)["']/i);
            const nameMatch = fieldHtml.match(/name=["']([^"']+)["']/i);
            const dataFieldMatch = fieldHtml.match(/data-field=["']([^"']+)["']/i);
            const readonlyMatch = fieldHtml.match(/readonly|disabled/i);

            const id = idMatch ? idMatch[1] : '(kein ID)';
            const hasBinding = dataFieldMatch || nameMatch || jsContext.fieldReferences.includes(id);

            if (!hasBinding && !readonlyMatch) {
                result.issues.push({
                    type: 'FIELD_NO_BINDING',
                    severity: 'MEDIUM',
                    element: id,
                    message: `Feld "${id}" hat keine Datenbindung`
                });
                result.stats.fieldsWithoutBinding++;
            }
        });

        // Datumsfilter
        const dateRegex = /<input[^>]*type=["']date(?:time-local)?["'][^>]*>/gi;
        const dateFilters = htmlContent.match(dateRegex) || [];
        result.stats.dateFilters = dateFilters.length;

        dateFilters.forEach(filterHtml => {
            const idMatch = filterHtml.match(/id=["']([^"']+)["']/i);
            const onchangeMatch = filterHtml.match(/onchange=["']([^"']+)["']/i);

            const id = idMatch ? idMatch[1] : '(kein ID)';
            const hasOnchange = onchangeMatch && onchangeMatch[1].trim() !== '';
            const hasEventListener = jsContext.eventListeners.includes(id);
            const isInFilter = jsContext.filterReferences.includes(id);

            if (!hasOnchange && !hasEventListener && !isInFilter) {
                result.issues.push({
                    type: 'DATE_FILTER_NO_EFFECT',
                    severity: 'HIGH',
                    element: id,
                    message: `Datumsfilter "${id}" hat keine Wirkung`
                });
                result.stats.dateFiltersWithoutEffect++;
            }
        });

        // Navigation prufen
        const navigateRegex = /Bridge\.navigate\(['"]([^'"]+)['"]/g;
        let navMatch;
        while ((navMatch = navigateRegex.exec(htmlContent)) !== null) {
            const target = navMatch[1];
            const targetFile = target.endsWith('.html') ? target : `${target}.html`;
            result.stats.links++;

            if (!this.config.knownForms.includes(targetFile) &&
                !this.config.knownForms.some(f => f.toLowerCase() === targetFile.toLowerCase())) {
                result.issues.push({
                    type: 'DEAD_LINK_NAVIGATE',
                    severity: 'HIGH',
                    target: targetFile,
                    message: `Bridge.navigate zu nicht-existierendem Formular: "${targetFile}"`
                });
                result.stats.deadLinks++;
            }
        }

        return result;
    },

    /**
     * Formatiert Ergebnisse als Markdown
     */
    formatAsMarkdown(results) {
        let md = `# Form Validator Report\n\n`;
        md += `**Erstellt:** ${results.timestamp}\n\n`;

        // Summary
        md += `## Zusammenfassung\n\n`;
        md += `| Metrik | Wert |\n`;
        md += `|--------|------|\n`;
        md += `| Formulare geprueft | ${results.summary.totalForms} |\n`;
        md += `| Buttons gesamt | ${results.summary.totalButtons} |\n`;
        md += `| Buttons ohne Handler | ${results.summary.buttonsWithoutHandler} |\n`;
        md += `| Felder gesamt | ${results.summary.totalFields} |\n`;
        md += `| Felder ohne Binding | ${results.summary.fieldsWithoutBinding} |\n`;
        md += `| Datumsfilter gesamt | ${results.summary.totalDateFilters} |\n`;
        md += `| Filter ohne Wirkung | ${results.summary.dateFiltersWithoutEffect} |\n`;
        md += `| Links gesamt | ${results.summary.totalLinks} |\n`;
        md += `| Tote Links | ${results.summary.deadLinks} |\n\n`;

        // Details pro Formular
        md += `## Details pro Formular\n\n`;

        Object.entries(results.forms).forEach(([formName, formResult]) => {
            const issueCount = formResult.issues.length;
            const status = issueCount === 0 ? 'OK' : issueCount < 5 ? 'WARNUNG' : 'KRITISCH';
            const emoji = status === 'OK' ? '' : status === 'WARNUNG' ? '' : '';

            md += `### ${emoji} ${formName}\n\n`;
            md += `**Status:** ${status} (${issueCount} Issues)\n\n`;

            if (issueCount > 0) {
                md += `| Typ | Severity | Element | Beschreibung |\n`;
                md += `|-----|----------|---------|---------------|\n`;
                formResult.issues.forEach(issue => {
                    md += `| ${issue.type} | ${issue.severity} | ${issue.element || issue.target || '-'} | ${issue.message} |\n`;
                });
                md += `\n`;
            }
        });

        return md;
    },

    /**
     * Formatiert Ergebnisse als JSON
     */
    formatAsJSON(results) {
        return JSON.stringify(results, null, 2);
    },

    /**
     * Aktualisiert die Zusammenfassung
     */
    updateSummary() {
        const summary = this.results.summary;
        summary.totalForms = Object.keys(this.results.forms).length;
        summary.totalButtons = 0;
        summary.buttonsWithoutHandler = 0;
        summary.totalFields = 0;
        summary.fieldsWithoutBinding = 0;
        summary.totalDateFilters = 0;
        summary.dateFiltersWithoutEffect = 0;
        summary.totalLinks = 0;
        summary.deadLinks = 0;

        Object.values(this.results.forms).forEach(form => {
            summary.totalButtons += form.stats.buttons;
            summary.buttonsWithoutHandler += form.stats.buttonsWithoutHandler;
            summary.totalFields += form.stats.fields;
            summary.fieldsWithoutBinding += form.stats.fieldsWithoutBinding;
            summary.totalDateFilters += form.stats.dateFilters;
            summary.dateFiltersWithoutEffect += form.stats.dateFiltersWithoutEffect;
            summary.totalLinks += form.stats.links;
            summary.deadLinks += form.stats.deadLinks;
        });
    },

    /**
     * Hauptfunktion - prueft alle Formulare
     */
    async runAll(outputFormat = 'markdown') {
        this.results.timestamp = new Date().toISOString();
        this.results.forms = {};

        console.log('Form Validator gestartet...');
        console.log(`Pruefe ${this.config.knownForms.length} Formulare...\n`);

        // Node.js: Dateien lesen
        if (typeof require !== 'undefined') {
            const fs = require('fs');
            const path = require('path');
            const formsDir = path.resolve(__dirname, '..');

            for (const formName of this.config.knownForms) {
                const formPath = path.join(formsDir, formName);

                if (fs.existsSync(formPath)) {
                    try {
                        const content = fs.readFileSync(formPath, 'utf-8');
                        const result = this.validateForm(formName, content);
                        this.results.forms[formName] = result;
                        console.log(`[OK] ${formName} - ${result.issues.length} Issues`);
                    } catch (err) {
                        console.error(`[ERROR] ${formName}: ${err.message}`);
                    }
                } else {
                    console.log(`[SKIP] ${formName} - Datei nicht gefunden`);
                }
            }
        } else {
            // Browser: Formulare per fetch laden
            for (const formName of this.config.knownForms) {
                try {
                    const response = await fetch(this.config.formsPath + formName);
                    if (response.ok) {
                        const content = await response.text();
                        const result = this.validateForm(formName, content);
                        this.results.forms[formName] = result;
                        console.log(`[OK] ${formName} - ${result.issues.length} Issues`);
                    } else {
                        console.log(`[SKIP] ${formName} - HTTP ${response.status}`);
                    }
                } catch (err) {
                    console.error(`[ERROR] ${formName}: ${err.message}`);
                }
            }
        }

        this.updateSummary();

        console.log(`\nValidierung abgeschlossen.`);
        console.log(`Gesamt: ${this.results.summary.totalForms} Formulare, ${this.results.summary.buttonsWithoutHandler + this.results.summary.fieldsWithoutBinding + this.results.summary.dateFiltersWithoutEffect + this.results.summary.deadLinks} Issues gefunden.\n`);

        if (outputFormat === 'json') {
            return this.formatAsJSON(this.results);
        } else if (outputFormat === 'markdown') {
            return this.formatAsMarkdown(this.results);
        }

        return this.results;
    }
};

// Export fuer Node.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = FormValidator;

    // CLI-Ausfuehrung
    if (require.main === module) {
        const args = process.argv.slice(2);
        const format = args.includes('--json') ? 'json' : 'markdown';

        FormValidator.runAll(format).then(output => {
            console.log(output);

            // Optional: In Datei schreiben
            if (args.includes('--output')) {
                const fs = require('fs');
                const filename = format === 'json' ? 'validation_results.json' : 'validation_results.md';
                fs.writeFileSync(filename, output);
                console.log(`\nErgebnis gespeichert in: ${filename}`);
            }
        });
    }
}

// Export fuer Browser
if (typeof window !== 'undefined') {
    window.FormValidator = FormValidator;
}
