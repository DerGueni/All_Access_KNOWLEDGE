#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const COLOR_MAPS = {
    '#8080c0': ['#00796B', '#1976D2'],
    '#6060a0': ['#004D40', '#0D47A1'],
    '#000080': ['#00695C', '#1565C0'],
    '#1084d0': ['#26A69A', '#42A5F5'],
    '#9090c0': ['#4DB6AC', '#64B5F6'],
    '#b8b8d8': ['#80CBC4', '#90CAF9'],
    '#a0a0c0': ['#80CBC4', '#90CAF9'],
    '#8080b0': ['#26A69A', '#42A5F5'],
    '#4040a0': ['#00695C', '#1565C0'],
    '#606090': ['#00695C', '#1565C0'],
    '#404080': ['#004D40', '#0D47A1'],
    '#404070': ['#004D40', '#0D47A1'],
    '#505080': ['#00695C', '#1565C0'],
    '#d0d0e0': ['#B2DFDB', '#BBDEFB'],
    '#e0e0f0': ['#E0F2F1', '#E3F2FD'],
    '#b0b0d0': ['#B2DFDB', '#BBDEFB'],
    '#9090b0': ['#4DB6AC', '#64B5F6'],
    '#a0a0d0': ['#80CBC4', '#90CAF9'],
    '#c0c0d8': ['#B2DFDB', '#BBDEFB'],
    '#c0c0d0': ['#B2DFDB', '#BBDEFB'],
    '#a0a0b0': ['#80CBC4', '#90CAF9'],
    '#e0e0ff': ['#E0F2F1', '#E3F2FD'],
    '#f0f0ff': ['#E0F2F1', '#E3F2FD'],
    '#d0d0ff': ['#B2DFDB', '#BBDEFB'],
    '#c00000': ['#B71C1C', '#C62828'],
    '#60c060': ['#26A69A', '#42A5F5'],
    '#308030': ['#00796B', '#1976D2'],
    '#e0e080': ['#FFD54F', '#FFD54F'],
    '#c0c040': ['#FFC107', '#FFC107'],
    '#e06060': ['#EF5350', '#EF5350'],
    '#c04040': ['#E53935', '#E53935'],
    '#add8e6': ['#80DEEA', '#81D4FA'],
    '#90ee90': ['#A5D6A7', '#A5D6A7'],
    '#ffff90': ['#FFF59D', '#FFF59D'],
    '#ffb0b0': ['#EF9A9A', '#EF9A9A'],
    '#ffe0e0': ['#FFEBEE', '#FFEBEE'],
    '#a00000': ['#C62828', '#C62828'],
    '#c75050': ['#EF5350', '#EF5350']
};

function createVariant(sourceContent, variantName, colorIndex) {
    let content = sourceContent;

    // Titel ändern
    content = content.replace(
        '<title>Auftragsverwaltung</title>',
        `<title>Auftragsverwaltung - ${variantName}</title>`
    );

    // Kommentar hinzufügen
    content = content.replace(
        '    <style>',
        `    <!-- VARIANTE: ${variantName} -->\n    <style>`
    );

    // Farben ersetzen
    let replacements = 0;
    for (const [original, [teal, ocean]] of Object.entries(COLOR_MAPS)) {
        const target = colorIndex === 0 ? teal : ocean;
        const regex = new RegExp(original.replace('#', '\\#'), 'gi');
        const matches = (content.match(regex) || []).length;
        if (matches > 0) {
            content = content.replace(regex, target);
            replacements += matches;
            console.log(`  ${original} -> ${target}: ${matches}x`);
        }
    }

    console.log(`  Gesamt: ${replacements} Farbersetzungen\n`);
    return content;
}

function main() {
    console.log('Erstelle Farbvarianten...\n');

    const baseDir = path.join(__dirname, '04_HTML_Forms', 'forms');
    const sourceFile = path.join(baseDir, 'frm_va_Auftragstamm.html');
    const variantDir = path.join(baseDir, 'varianten_auftragstamm');

    // Ordner erstellen
    if (!fs.existsSync(variantDir)) {
        fs.mkdirSync(variantDir, { recursive: true });
    }

    // Original lesen
    console.log(`Lese: ${sourceFile}`);
    const sourceContent = fs.readFileSync(sourceFile, 'utf-8');

    // Variante 9: Teal
    console.log('\nErstelle Variante 9: Teal Refresh');
    const variant1 = createVariant(sourceContent, 'Teal Refresh', 0);
    const target1 = path.join(variantDir, 'variante_09_teal.html');
    fs.writeFileSync(target1, variant1, 'utf-8');
    console.log(`Gespeichert: ${target1}`);

    // Variante 10: Ocean Blue
    console.log('\nErstelle Variante 10: Ocean Blue');
    const variant2 = createVariant(sourceContent, 'Ocean Blue', 1);
    const target2 = path.join(variantDir, 'variante_10_ocean_blue.html');
    fs.writeFileSync(target2, variant2, 'utf-8');
    console.log(`Gespeichert: ${target2}`);

    console.log('\nFertig! Beide Varianten wurden erstellt.');
}

main();
