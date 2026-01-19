CONSEC Sidebar Design-Varianten
================================

Dieser Ordner enthaelt professionelle Sidebar-Design-Varianten.

VERFUEGBARE VARIANTEN:
----------------------

1. sidebar_variant_03_dark.css - "Dark Professional"
   - Dunkles Theme (#1a1a2e, #16213e, #0f3460)
   - Neon-Akzente (#e94560 - Pink/Rot)
   - Glasmorphism-Effekt
   - Pulsierender Glow bei aktivem Button

2. sidebar_variant_04_gradient.css - "Gradient Flow"
   - Animierter Farbverlauf (#667eea -> #764ba2 -> #f093fb)
   - Cyan-Akzente (#00d4ff)
   - Shimmer-Effekt bei Hover
   - Weiche, abgerundete Kanten


ANWENDUNG:
----------

In shell.html eine Variante einbinden (nach dem <head>-Tag):

  <link rel="stylesheet" href="css/sidebar_variants/sidebar_variant_03_dark.css">

oder

  <link rel="stylesheet" href="css/sidebar_variants/sidebar_variant_04_gradient.css">


HINWEIS: Die Variante ueberschreibt die Standard-Sidebar-Styles.
         Nur EINE Variante gleichzeitig einbinden!


FEATURES BEIDER VARIANTEN:
--------------------------
- Touch-freundlich: Mindestens 44px Button-Hoehe
- Responsive: Anpassung bei verschiedenen Bildschirmgroessen
- Hover/Active States mit Animationen
- Accessibility: Focus-States, Reduced-Motion Support
- Premium-Look mit Schatten und Tiefe


TECHNISCHE DETAILS:
-------------------
- CSS Custom Properties (CSS-Variablen) fuer einfache Anpassung
- Backdrop-filter fuer Glasmorphism (funktioniert in modernen Browsern)
- CSS Animationen ohne JavaScript
- Responsive Breakpoints: 1200px, 992px


Stand: 2026-01-18
