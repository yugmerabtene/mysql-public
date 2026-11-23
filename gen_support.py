#!/usr/bin/env python3
# Génération du support de cours HTML autonome (index.html) pour export PDF
# Inclut les chapitres 1 à 5, page de garde, sommaire, numérotation, schémas Mermaid, blocs de code protégés

import pathlib

ROOT = pathlib.Path("/home/yug/Documents/mysql")

def read_chapitre(n):
    p = ROOT / f"chapitre-0{n}.md"
    return p.read_text(encoding="utf-8")

# CSS d'impression professionnelle A4 + écran
CSS = """
* { box-sizing: border-box; }
body {
    font-family: 'DejaVu Sans', 'Liberation Sans', Arial, sans-serif;
    font-size: 9.5pt;
    line-height: 1.45;
    color: #1a1a1a;
    margin: 0;
}

/* ---------- PAGE DE GARDE ---------- */
#cover {
    page-break-after: always;
    height: 297mm;
    width: 210mm;
    margin: 0 auto;
    position: relative;
    background: linear-gradient(135deg, #0f3057 0%, #1a5f8a 55%, #2e8bc0 100%);
    color: #ffffff;
    padding: 30mm 20mm;
    box-sizing: border-box;
}
#cover .cover-top { text-align: left; margin-top: 15mm; }
#cover h1 {
    font-size: 34pt;
    font-weight: 800;
    margin: 10mm 0 5mm 0;
    line-height: 1.15;
    letter-spacing: 0.5px;
    color: #ffffff;
}
#cover .subtitle {
    font-size: 15pt;
    color: #dceefa;
    margin-bottom: 12mm;
    line-height: 1.5;
}
#cover .meta {
    font-size: 10pt;
    color: #e8f3fa;
    line-height: 1.8;
    margin-top: 15mm;
}
#cover .meta b { color: #ffffff; }
#cover .cover-bottom {
    position: absolute;
    bottom: 20mm;
    left: 20mm;
    right: 20mm;
    font-size: 9pt;
    color: #bfe3f8;
    border-top: 1px solid #4a90c2;
    padding-top: 5mm;
}

/* ---------- SOMMAIRE ---------- */
#sommaire {
    page-break-after: always;
    padding: 10mm 15mm;
}
#sommaire h1 { font-size: 22pt; color: #0f3057; margin-bottom: 8mm; border-bottom: 2px solid #0f3057; padding-bottom: 3mm; }
#sommaire h2 { font-size: 14pt; color: #1a5f8a; margin-top: 7mm; margin-bottom: 3mm; }
#sommaire ul { list-style: none; padding: 0; margin: 0; }
#sommaire li { margin-bottom: 2.5mm; font-size: 11pt; }
#sommaire li a { color: #1a1a1a; text-decoration: none; }
#sommaire li a:hover { color: #1a5f8a; text-decoration: underline; }
#sommaire .part { font-weight: 700; color: #0f3057; font-size: 13pt; margin-top: 6mm; }

/* ---------- CHAPITRES ---------- */
.chapter {
    page-break-before: always;
    padding: 10mm 15mm;
    min-height: 277mm;
}
.chapter:first-child { page-break-before: avoid; }
.chapter h1 {
    font-size: 20pt;
    color: #0f3057;
    border-bottom: 2.5px solid #1a5f8a;
    padding-bottom: 3mm;
    margin-bottom: 6mm;
}
.chapter h2 {
    font-size: 14pt;
    color: #1a5f8a;
    margin-top: 7mm;
    margin-bottom: 3mm;
    border-left: 4px solid #1a5f8a;
    padding-left: 3mm;
}
.chapter h3 {
    font-size: 11.5pt;
    color: #2e5f8a;
    margin-top: 5mm;
    margin-bottom: 2mm;
}
.chapter h4 { font-size: 10.5pt; color: #333; margin-top: 4mm; margin-bottom: 1.5mm; }
.chapter p { margin: 2mm 0; text-align: justify; }
.chapter ul, .chapter ol { margin: 2mm 0 2mm 6mm; padding-left: 4mm; }
.chapter li { margin-bottom: 1.2mm; text-align: justify; }
.chapter table {
    border-collapse: collapse;
    width: 100%;
    margin: 3mm 0;
    font-size: 8.5pt;
}
.chapter table th, .chapter table td {
    border: 0.5pt solid #9db2c8;
    padding: 1.5mm 2mm;
    text-align: left;
    vertical-align: top;
}
.chapter table th { background: #e8f0f7; color: #0f3057; font-weight: 700; }
.chapter table tr:nth-child(even) td { background: #f4f8fb; }

/* ---------- BLOCS DE CODE ---------- */
.chapter pre, .chapter code {
    font-family: 'DejaVu Sans Mono', 'Liberation Mono', monospace;
    font-size: 8pt;
}
.chapter pre {
    background: #f4f4f4;
    border: 0.5pt solid #cccccc;
    border-left: 3px solid #1a5f8a;
    padding: 3mm;
    margin: 3mm 0;
    overflow-x: auto;
    white-space: pre-wrap;
    word-wrap: break-word;
    page-break-inside: avoid;
    max-width: 100%;
}
.chapter pre code {
    font-size: inherit;
    white-space: pre-wrap;
    word-wrap: break-word;
}
.chapter code:not(pre code) {
    background: #eef4f9;
    padding: 0.5mm 1mm;
    border: 0.5pt solid #cccccc;
    border-radius: 2px;
    font-size: 8.5pt;
}

/* ---------- MERMAID ---------- */
.chapter .mermaid {
    margin: 5mm auto;
    page-break-inside: avoid;
    text-align: center;
    max-width: 100%;
}
.chapter .mermaid svg {
    max-width: 100%;
    height: auto;
    overflow: visible;
}

/* ---------- ENCASTREMENTS MACHINE ---------- */
.chapter blockquote {
    border-left: 3px solid #1a5f8a;
    background: #f0f6fb;
    padding: 2mm 3mm;
    margin: 3mm 0;
    font-size: 8.5pt;
    page-break-inside: avoid;
}

/* ---------- IMPRESSION PDF ---------- */
@page {
    size: A4;
    margin: 18mm 16mm 20mm 16mm;
    @bottom-center {
        content: "MySQL Cluster — Administration et exploitation — Support de cours";
        font-family: 'DejaVu Sans', sans-serif;
        font-size: 7.5pt;
        color: #666666;
    }
    @bottom-right {
        content: "Page " counter(page) " sur " counter(pages);
        font-family: 'DejaVu Sans', sans-serif;
        font-size: 7.5pt;
        color: #666666;
    }
    @top-right {
        content: string(doctitle);
        font-family: 'DejaVu Sans', sans-serif;
        font-size: 7.5pt;
        color: #999999;
    }
}
.chapter h1 { string-set: doctitle content(); }

@media screen {
    body { font-size: 13px; line-height: 1.6; }
    .chapter { page-break-before: auto; padding: 20px; min-height: auto; }
    #cover { height: auto; min-height: 600px; background: #ffffff; color: #000; border: 1px solid #ccc; }
    #cover h1 { color: #0f3057; font-size: 28pt; }
    #cover .subtitle { color: #333; }
    #cover .meta { color: #333; }
    #cover .meta b { color: #0f3057; }
    #cover .cover-bottom { color: #333; border-top-color: #999; }
}

/* ---------- ÉVITER COUPURES ---------- */
.chapter h2, .chapter h3, .chapter h4 { page-break-after: avoid; }
.chapter blockquote, .chapter table, .chapter pre, .chapter .mermaid { page-break-inside: avoid; }
.chapter p { orphans: 3; widows: 3; }
"""

JS = """
document.addEventListener('DOMContentLoaded', function() {
    // Générer le sommaire depuis les h1 de chaque chapitre
    var sommaire = document.getElementById('sommaire-liste');
    var chapitres = document.querySelectorAll('.chapter h1');
    var html = '';
    chapitres.forEach(function(h) {
        var id = h.id || 'chap-' + Math.random().toString(36).slice(2);
        h.id = id;
        html += '<li><a href="#' + id + '">' + h.textContent.trim() + '</a></li>';
    });
    sommaire.innerHTML = html;

    // Rendre le markdown de chaque chapitre
    document.querySelectorAll('script[type="text/markdown"]').forEach(function(script) {
        var container = document.getElementById(script.id.replace('md-', 'content-'));
        if (!container) {
            container = document.createElement('div');
            container.id = script.id.replace('md-', 'content-');
            container.className = 'chapter';
            script.parentNode.insertBefore(container, script.nextSibling);
        }
        var md = script.textContent;
        container.innerHTML = marked.parse(md);
    });

    // Convertir les blocs de code language-mermaid (produits par marked) en divs .mermaid
    document.querySelectorAll('pre > code.language-mermaid').forEach(function(block) {
        var pre = block.parentElement;
        var div = document.createElement('div');
        div.className = 'mermaid';
        div.textContent = block.textContent;
        pre.parentNode.replaceChild(div, pre);
    });

    // Initialiser Mermaid
    if (window.mermaid) {
        mermaid.initialize({ startOnLoad: false, theme: 'default', securityLevel: 'loose' });
        mermaid.init(undefined, document.querySelectorAll('.mermaid'));
    }
});
"""

# Construire le HTML
cover = ROOT / "cover.md"
cover_md = cover.read_text(encoding="utf-8") if cover.exists() else ""

html_parts = []
html_parts.append("<!DOCTYPE html>")
html_parts.append("<html lang=\"fr\">")
html_parts.append("<head>")
html_parts.append('<meta charset="utf-8">')
html_parts.append('<meta name="viewport" content="width=device-width, initial-scale=1">')
html_parts.append("<title>MySQL Cluster — Administration et exploitation — Support de cours</title>")
html_parts.append("<style>")
html_parts.append(CSS)
html_parts.append("</style>")
html_parts.append('<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>')
html_parts.append('<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>')
html_parts.append("</head>")
html_parts.append("<body>")

# Page de garde
html_parts.append('<div id="cover">')
html_parts.append('<div class="cover-top">')
html_parts.append('<h1>MySQL Cluster</h1>')
html_parts.append('<div class="subtitle">Administration et exploitation d\'un cluster NDB sur 3 VM isolées</div>')
html_parts.append('<div class="meta">')
html_parts.append('<p><b>Parcours de formation :</b> MySQL Cluster — Administration et exploitation</p>')
html_parts.append('<p><b>Public :</b> administrateurs système et bases de données (niveau débutant à intermédiaire)</p>')
html_parts.append('<p><b>Durée :</b> 5 jours (modules 1.0 à 1.1)</p>')
html_parts.append('<p><b>Infrastructure :</b> 3 VM Ubuntu Server 24.04 LTS sur réseau isolé vboxnet0 192.168.56.0/24</p>')
html_parts.append('<p><b>Architecture :</b> 1 nœud de gestion (NodeId 1) + 2 nœuds de stockage (NodeId 2 et 3) + 2 nœuds SQL (NodeId 4 et 5)</p>')
html_parts.append('<p><b>Contenu :</b> Chapitres 1 à 5 — Introduction, installation, architecture, administration, supervision, maintenance, optimisation, réplication, sécurité</p>')
html_parts.append('<p><b>Date :</b> Novembre 2026</p>')
html_parts.append('</div>')
html_parts.append('</div>')
html_parts.append('<div class="cover-bottom">')
html_parts.append('Support de cours pédagogique — Usage exclusif en laboratoire isolé. Aucune configuration de production, aucun accès Internet pendant les travaux pratiques.')
html_parts.append('</div>')
html_parts.append('</div>')

# Sommaire
html_parts.append('<div id="sommaire">')
html_parts.append('<h1>Sommaire</h1>')
html_parts.append('<div id="sommaire-liste"></div>')
html_parts.append('</div>')

# Chapitres
for n in range(1, 6):
    contenu = read_chapitre(n)
    html_parts.append(f'<script id="md-chapitre-{n}" type="text/markdown">')
    html_parts.append(contenu)
    html_parts.append('</script>')
    html_parts.append(f'<div id="content-chapitre-{n}" class="chapter"></div>')

html_parts.append('<script>')
html_parts.append(JS)
html_parts.append('</script>')
html_parts.append('</body>')
html_parts.append('</html>')

html = '\n'.join(html_parts)
out = ROOT / "index.html"
out.write_text(html, encoding="utf-8")
print(f"index.html généré : {out} ({len(html)} caractères)")