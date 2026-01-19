#!/usr/bin/env node
/**
 * Access Bridge MCP Server v1.0
 * Ermöglicht Claude Desktop Zugriff auf MS Access Frontend
 * 
 * WICHTIG: 
 * - Frontend wird unsichtbar geöffnet
 * - Keine Fehlermeldungen/Speicherdialoge
 * - Nur EINE Instanz des Frontends
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { spawn } from "child_process";
import path from "path";

// Konfiguration
const CONFIG = {
  accessBridgePath: "C:\\Users\\guenther.siegert\\Documents\\Access Bridge",
  frontendPath: "S:\\CONSEC\\CONSEC PLANUNG AKTUELL\\B - DIVERSES\\Consys_FE_N_Test_Claude_GPT.accdb",
  powershellScript: "AccessUniversal.ps1",
  timeout: 60000 // 60 Sekunden Timeout
};

/**
 * Führt PowerShell-Befehl aus und gibt Ergebnis zurück
 */
async function runPowerShell(args) {
  return new Promise((resolve, reject) => {
    const scriptPath = path.join(CONFIG.accessBridgePath, CONFIG.powershellScript);
    
    // PowerShell mit -NoProfile und -ExecutionPolicy Bypass für schnelleren Start
    const psArgs = [
      "-NoProfile",
      "-ExecutionPolicy", "Bypass",
      "-File", scriptPath,
      ...args
    ];

    const ps = spawn("powershell.exe", psArgs, {
      cwd: CONFIG.accessBridgePath,
      windowsHide: true, // Versteckt PowerShell-Fenster
      stdio: ["pipe", "pipe", "pipe"]
    });

    let stdout = "";
    let stderr = "";

    ps.stdout.on("data", (data) => {
      stdout += data.toString();
    });

    ps.stderr.on("data", (data) => {
      stderr += data.toString();
    });

    const timeout = setTimeout(() => {
      ps.kill();
      reject(new Error(`Timeout nach ${CONFIG.timeout}ms`));
    }, CONFIG.timeout);

    ps.on("close", (code) => {
      clearTimeout(timeout);
      if (code === 0 || stdout.trim()) {
        try {
          // Versuche JSON zu parsen
          const result = JSON.parse(stdout.trim());
          resolve(result);
        } catch {
          // Falls kein JSON, gib raw text zurück
          resolve({ raw: stdout.trim() });
        }
      } else {
        reject(new Error(stderr || `Exit code: ${code}`));
      }
    });

    ps.on("error", (err) => {
      clearTimeout(timeout);
      reject(err);
    });
  });
}

/**
 * Konvertiert Tool-Parameter zu PowerShell-Argumenten
 */
function buildArgs(action, params) {
  const args = ["-Action", action];
  
  if (params.query) args.push("-Query", params.query);
  if (params.table) args.push("-Table", params.table);
  if (params.module) args.push("-Module", params.module);
  if (params.code) args.push("-Code", params.code);
  if (params.form) args.push("-Form", params.form);
  if (params.vbaFunction) args.push("-VBAFunction", params.vbaFunction);
  if (params.vbaArgs !== undefined) {
    if (Array.isArray(params.vbaArgs)) {
      args.push("-VBAArgs", `@(${params.vbaArgs.join(",")})`);
    } else {
      args.push("-VBAArgs", String(params.vbaArgs));
    }
  }
  if (params.data) {
    // Hashtable als PowerShell-Syntax
    const hashtable = Object.entries(params.data)
      .map(([k, v]) => `${k}="${v}"`)
      .join(";");
    args.push("-Data", `@{${hashtable}}`);
  }
  
  return args;
}

// MCP Server erstellen
const server = new Server(
  {
    name: "access-bridge-mcp",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Tool-Definitionen
const TOOLS = [
  {
    name: "access_test",
    description: "Testet die Verbindung zum Access Frontend und zeigt Statistiken (Tabellen, Queries, Module)",
    inputSchema: {
      type: "object",
      properties: {},
      required: []
    }
  },
  {
    name: "access_sql",
    description: "Führt SQL-Abfragen aus (SELECT, INSERT, UPDATE, DELETE). Datumsformat: #MM/DD/YYYY#",
    inputSchema: {
      type: "object",
      properties: {
        query: {
          type: "string",
          description: "SQL-Abfrage. Beispiel: SELECT TOP 10 * FROM tbl_VA_Auftragstamm"
        }
      },
      required: ["query"]
    }
  },
  {
    name: "access_insert",
    description: "Fügt einen Datensatz in eine Tabelle ein. DateTime wird automatisch formatiert.",
    inputSchema: {
      type: "object",
      properties: {
        table: {
          type: "string",
          description: "Tabellenname"
        },
        data: {
          type: "object",
          description: "Daten als Key-Value-Paare"
        }
      },
      required: ["table", "data"]
    }
  },
  {
    name: "access_vba_run",
    description: "Führt eine VBA-Funktion im Access Frontend aus",
    inputSchema: {
      type: "object",
      properties: {
        vbaFunction: {
          type: "string",
          description: "Name der VBA-Funktion"
        },
        vbaArgs: {
          description: "Argumente (einzelner Wert oder Array)",
        }
      },
      required: ["vbaFunction"]
    }
  },
  {
    name: "access_module_read",
    description: "Liest den Code eines VBA-Moduls",
    inputSchema: {
      type: "object",
      properties: {
        module: {
          type: "string",
          description: "Modulname (z.B. mdl_Test)"
        }
      },
      required: ["module"]
    }
  },
  {
    name: "access_module_write",
    description: "Schreibt/Erstellt ein VBA-Modul (ersetzt existierenden Code)",
    inputSchema: {
      type: "object",
      properties: {
        module: {
          type: "string",
          description: "Modulname"
        },
        code: {
          type: "string",
          description: "VBA-Code (ohne Attribute/Option Explicit)"
        }
      },
      required: ["module", "code"]
    }
  },
  {
    name: "access_module_delete",
    description: "Löscht ein VBA-Modul",
    inputSchema: {
      type: "object",
      properties: {
        module: {
          type: "string",
          description: "Modulname"
        }
      },
      required: ["module"]
    }
  },
  {
    name: "access_form_open",
    description: "Öffnet ein Formular im Access Frontend",
    inputSchema: {
      type: "object",
      properties: {
        form: {
          type: "string",
          description: "Formularname"
        }
      },
      required: ["form"]
    }
  },
  {
    name: "access_form_close",
    description: "Schließt ein Formular OHNE Speicherdialog",
    inputSchema: {
      type: "object",
      properties: {
        form: {
          type: "string",
          description: "Formularname"
        }
      },
      required: ["form"]
    }
  },
  {
    name: "access_eval",
    description: "Wertet einen Access-Ausdruck aus (z.B. Now(), DCount())",
    inputSchema: {
      type: "object",
      properties: {
        query: {
          type: "string",
          description: "Access-Ausdruck wie Now(), DCount('*','tbl_Name')"
        }
      },
      required: ["query"]
    }
  },
  {
    name: "access_list_tables",
    description: "Listet alle Tabellen der Datenbank auf",
    inputSchema: {
      type: "object",
      properties: {},
      required: []
    }
  },
  {
    name: "access_list_forms",
    description: "Listet alle Formulare auf",
    inputSchema: {
      type: "object",
      properties: {},
      required: []
    }
  },
  {
    name: "access_list_modules",
    description: "Listet alle VBA-Module auf",
    inputSchema: {
      type: "object",
      properties: {},
      required: []
    }
  },
  {
    name: "access_save",
    description: "Speichert die Datenbank",
    inputSchema: {
      type: "object",
      properties: {},
      required: []
    }
  },
  {
    name: "access_save_object",
    description: "Speichert ein bestimmtes Objekt (Formular oder Modul)",
    inputSchema: {
      type: "object",
      properties: {
        form: {
          type: "string",
          description: "Formularname (optional)"
        },
        module: {
          type: "string",
          description: "Modulname (optional)"
        }
      },
      required: []
    }
  }
];

// Tools auflisten
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: TOOLS
}));

// Tool-Aufrufe verarbeiten
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  
  try {
    let result;
    
    switch (name) {
      case "access_test":
        result = await runPowerShell(["-Action", "test"]);
        break;
        
      case "access_sql":
        result = await runPowerShell(buildArgs("sql", { query: args.query }));
        break;
        
      case "access_insert":
        result = await runPowerShell(buildArgs("insert", { table: args.table, data: args.data }));
        break;
        
      case "access_vba_run":
        result = await runPowerShell(buildArgs("vba", { vbaFunction: args.vbaFunction, vbaArgs: args.vbaArgs }));
        break;
        
      case "access_module_read":
        result = await runPowerShell(buildArgs("module", { module: args.module }));
        break;
        
      case "access_module_write":
        result = await runPowerShell(buildArgs("module", { module: args.module, code: args.code }));
        break;
        
      case "access_module_delete":
        result = await runPowerShell(buildArgs("module-delete", { module: args.module }));
        break;
        
      case "access_form_open":
        result = await runPowerShell(buildArgs("form", { form: args.form }));
        break;
        
      case "access_form_close":
        result = await runPowerShell(buildArgs("form-close", { form: args.form }));
        break;
        
      case "access_eval":
        result = await runPowerShell(buildArgs("eval", { query: args.query }));
        break;
        
      case "access_list_tables":
        result = await runPowerShell(["-Action", "list-tables"]);
        break;
        
      case "access_list_forms":
        result = await runPowerShell(["-Action", "list-forms"]);
        break;
        
      case "access_list_modules":
        result = await runPowerShell(["-Action", "list-modules"]);
        break;
        
      case "access_save":
        result = await runPowerShell(["-Action", "save"]);
        break;
        
      case "access_save_object":
        result = await runPowerShell(buildArgs("save-object", { form: args.form, module: args.module }));
        break;
        
      default:
        throw new Error(`Unbekanntes Tool: ${name}`);
    }
    
    return {
      content: [
        {
          type: "text",
          text: typeof result === "string" ? result : JSON.stringify(result, null, 2)
        }
      ]
    };
    
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `FEHLER: ${error.message}`
        }
      ],
      isError: true
    };
  }
});

// Server starten
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Access Bridge MCP Server gestartet");
}

main().catch(console.error);
