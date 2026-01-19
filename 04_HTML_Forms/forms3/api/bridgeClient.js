/**
 * bridgeClient.js
 * Re-exportiert den Bridge aus webview2-bridge.js
 * Dieser Wrapper ermoeglicht einfachen Import: import { Bridge } from '../api/bridgeClient.js'
 */

// Bridge aus webview2-bridge.js importieren
import '../js/webview2-bridge.js';

// Bridge ist jetzt global verfuegbar als window.Bridge
export const Bridge = window.Bridge;

// Default export fuer Kompatibilitaet
export default Bridge;
