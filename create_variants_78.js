#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const baseDir = 'C:\\Users\\guenther.siegert\\Documents\\0006_All_Access_KNOWLEDGE\\04_HTML_Forms\\forms';
const sourceFile = path.join(baseDir, 'frm_va_Auftragstamm.html');
const variantDir = path.join(baseDir, 'varianten_auftragstamm');

// Minimalist White color replacements
const MINIMALIST_COLORS = {
    '#8080c0': '#FAFAFA',
    '#6060a0': '#FFFFFF',
    '#000080': '#1565C0',
    '#1084d0': '#42A5F5',
    '#9090c0': '#FFFFFF',
    '#b8b8d8': '#FFFFFF',
    '#a0a0c0': '#FAFAFA',
    '#8080b0': '#F5F5F5',
    '#4040a0': '#1565C0',
    '#606090': '#E0E0E0',
    '#404080': '#BDBDBD',
    '#404070': '#E0E0E0',
    '#505080': '#BDBDBD',
    '#d0d0e0': '#FFFFFF',
    '#e0e0f0': '#FAFAFA',
    '#b0b0d0': '#F5F5F5',
    '#9090b0': '#EEEEEE',
    '#a0a0d0': '#F5F5F5',
    '#c0c0d8': '#E0E0E0',
    '#c0c0d0': '#FAFAFA',
    '#a0a0b0': '#EEEEEE',
    '#e0e0ff': '#FAFAFA',
    '#f0f0ff': '#F5F5F5',
    '#d0d0ff': '#E3F2FD',
    '#e8e8e8': '#FAFAFA',
    '#c0c0c0': '#E0E0E0',
    '#f0f0f0': '#FFFFFF',
    '#d0d0d0': '#F5F5F5',
    '#ece9d8': '#FAFAFA'
};

// Nord Theme color replacements
const NORD_COLORS = {
    '#8080c0': '#2E3440',
    '#6060a0': '#3B4252',
    '#000080': '#81A1C1',
    '#1084d0': '#88C0D0',
    '#9090c0': '#3B4252',
    '#b8b8d8': '#434C5E',
    '#a0a0c0': '#434C5E',
    '#8080b0': '#4C566A',
    '#4040a0': '#5E81AC',
    '#606090': '#4C566A',
    '#404080': '#3B4252',
    '#404070': '#434C5E',
    '#505080': '#4C566A',
    '#d0d0e0': '#4C566A',
    '#e0e0f0': '#E5E9F0',
    '#b0b0d0': '#D8DEE9',
    '#9090b0': '#4C566A',
    '#a0a0d0': '#5E81AC',
    '#c0c0d8': '#D8DEE9',
    '#c0c0d0': '#4C566A',
    '#a0a0b0': '#4C566A',
    '#e0e0ff': '#434C5E',
    '#f0f0ff': '#3B4252',
    '#d0d0ff': '#4C566A',
    '#e8e8e8': '#4C566A',
    '#c0c0c0': '#3B4252',
    '#f0f0f0': '#434C5E',
    '#d0d0d0': '#4C566A',
    '#ece9d8': '#4C566A',
    'white': '#ECEFF4',
    '#fff': '#E5E9F0'
};

function createVariant(sourceContent, variantName, colorMap) {
    let content = sourceContent;

    // Title
    content = content.replace(
        '<title>Auftragsverwaltung</title>',
        `<title>Auftragsverwaltung - ${variantName}</title>`
    );

    // Colors
    let replacements = 0;
    for (const [original, target] of Object.entries(colorMap)) {
        const regex = new RegExp(original.replace('#', '\\#'), 'gi');
        const matches = (content.match(regex) || []).length;
        if (matches > 0) {
            content = content.replace(regex, target);
            replacements += matches;
        }
    }

    console.log(`  ${replacements} Farbersetzungen`);
    return content;
}

function main() {
    console.log('Erstelle Varianten 7 und 8...\n');

    if (!fs.existsSync(variantDir)) {
        fs.mkdirSync(variantDir, { recursive: true });
    }

    const sourceContent = fs.readFileSync(sourceFile, 'utf-8');
    console.log('Original gelesen.\n');

    // Variante 7: Minimalist White
    console.log('Erstelle Variante 7: Minimalist White');
    const variant7 = createVariant(sourceContent, 'Minimalist White', MINIMALIST_COLORS);
    fs.writeFileSync(path.join(variantDir, 'variante_07_minimalist.html'), variant7, 'utf-8');
    console.log('Gespeichert: variante_07_minimalist.html\n');

    // Variante 8: Nord Theme
    console.log('Erstelle Variante 8: Nord Theme');
    const variant8 = createVariant(sourceContent, 'Nord Theme', NORD_COLORS);
    fs.writeFileSync(path.join(variantDir, 'variante_08_nord.html'), variant8, 'utf-8');
    console.log('Gespeichert: variante_08_nord.html\n');

    console.log('Fertig!');
}

main();
