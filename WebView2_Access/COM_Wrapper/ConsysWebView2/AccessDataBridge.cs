using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace ConsysWebView2
{
    /// <summary>
    /// AccessDataBridge - Direkte OleDb-Anbindung an Access Backend
    /// C# 5.0 KOMPATIBEL (ohne String Interpolation)
    /// </summary>
    public class AccessDataBridge : IDisposable
    {
        private static readonly string[] BACKEND_PATHS = new[]
        {
            @"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\0_Consec_V1_BE_V1.55_Test.accdb",
            @"S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb",
            @"C:\Users\guenther.siegert\Documents\Consec_BE_LOCAL.accdb"
        };

        private static readonly string LOG_PATH = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "Consys", "WebView2", "bridge.log"
        );

        private string _connectionString;
        private string _lastError = "";
        private string _currentDbPath = "";

        public string LastError { get { return _lastError; } }
        public string CurrentDbPath { get { return _currentDbPath; } }

        private void Log(string level, string message, int? requestId = null)
        {
            try
            {
                var logDir = Path.GetDirectoryName(LOG_PATH);
                if (!Directory.Exists(logDir))
                    Directory.CreateDirectory(logDir);

                var timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
                var reqInfo = requestId.HasValue ? "[Req:" + requestId + "]" : "";
                var logLine = timestamp + " [" + level + "]" + reqInfo + " " + message;

                var fi = new FileInfo(LOG_PATH);
                if (fi.Exists && fi.Length > 5 * 1024 * 1024)
                {
                    var backupPath = LOG_PATH + ".old";
                    if (File.Exists(backupPath)) File.Delete(backupPath);
                    File.Move(LOG_PATH, backupPath);
                }

                File.AppendAllText(LOG_PATH, logLine + Environment.NewLine);
            }
            catch { }
        }

        private void LogInfo(string message, int? requestId = null) { Log("INFO", message, requestId); }
        private void LogError(string message, int? requestId = null) { Log("ERROR", message, requestId); }
        private void LogDebug(string message, int? requestId = null) { Log("DEBUG", message, requestId); }

        public AccessDataBridge()
        {
            LogInfo("AccessDataBridge wird initialisiert...");
            InitializeConnection();
        }

        public AccessDataBridge(string customDbPath)
        {
            LogInfo("AccessDataBridge mit Custom-Pfad: " + customDbPath);
            if (File.Exists(customDbPath))
            {
                _currentDbPath = customDbPath;
                _connectionString = BuildConnectionString(customDbPath);
                LogInfo("Verbunden mit: " + customDbPath);
            }
            else
            {
                LogError("Custom-Pfad nicht gefunden: " + customDbPath);
                InitializeConnection();
            }
        }

        private void InitializeConnection()
        {
            foreach (var path in BACKEND_PATHS)
            {
                LogDebug("Pruefe Pfad: " + path);
                if (File.Exists(path))
                {
                    _currentDbPath = path;
                    _connectionString = BuildConnectionString(path);
                    LogInfo("Verbunden mit Backend: " + path);
                    return;
                }
            }
            _lastError = "Keine Access-Backend-Datenbank gefunden!";
            LogError(_lastError);
        }

        private string BuildConnectionString(string dbPath)
        {
            return "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + dbPath + ";Persist Security Info=False;";
        }

        public string ProcessRequest(string jsonMessage)
        {
            int requestId = 0;
            string action = "";

            try
            {
                var request = JsonConvert.DeserializeObject<JObject>(jsonMessage);
                if (request == null)
                {
                    LogError("Ungueltige JSON-Nachricht empfangen");
                    return CreateErrorResponse(0, "Ungültige JSON-Nachricht");
                }

                requestId = request.Value<int?>("requestId") ?? 0;
                action = request.Value<string>("action") ?? "";
                var parameters = request["params"] as JObject ?? new JObject();

                LogInfo("Action: " + action, requestId);

                var response = RouteAction(requestId, action, parameters);

                var responseObj = JsonConvert.DeserializeObject<JObject>(response);
                bool ok = responseObj != null && (responseObj.Value<bool?>("ok") ?? false);
                LogInfo("Response: ok=" + ok, requestId);

                return response;
            }
            catch (Exception ex)
            {
                _lastError = ex.Message;
                LogError("Exception in Action '" + action + "': " + ex.Message + "\n" + ex.StackTrace, requestId);
                return CreateErrorResponse(requestId, ex.Message);
            }
        }

        private string RouteAction(int requestId, string action, JObject parameters)
        {
            try
            {
                switch (action.ToLower())
                {
                    case "loaddata":
                        return HandleLoadData(requestId, parameters);
                    case "list":
                        return HandleList(requestId, parameters);
                    case "search":
                        return HandleSearch(requestId, parameters);
                    case "save":
                        return HandleSave(requestId, parameters);
                    case "delete":
                        return HandleDelete(requestId, parameters);
                    case "getauftrag":
                        return HandleGetAuftrag(requestId, parameters);
                    case "getauftragliste":
                    case "listauftraege":
                        return HandleListAuftraege(requestId, parameters);
                    case "getmitarbeiter":
                        return HandleGetMitarbeiter(requestId, parameters);
                    case "getmitarbeiterliste":
                    case "listmitarbeiter":
                        return HandleListMitarbeiter(requestId, parameters);
                    case "getkunde":
                        return HandleGetKunde(requestId, parameters);
                    case "getkundenliste":
                    case "listkunden":
                        return HandleListKunden(requestId, parameters);
                    case "getobjektliste":
                    case "listobjekte":
                        return HandleListObjekte(requestId, parameters);
                    case "getzuordnungen":
                    case "loadzuordnungen":
                        return HandleGetZuordnungen(requestId, parameters);
                    case "createzuordnung":
                        return HandleCreateZuordnung(requestId, parameters);
                    case "deletezuordnung":
                        return HandleDeleteZuordnung(requestId, parameters);
                    case "getschichten":
                        return HandleGetSchichten(requestId, parameters);
                    case "geteinsatztage":
                        return HandleGetEinsatztage(requestId, parameters);
                    case "getstatusliste":
                        return HandleGetStatusListe(requestId, parameters);
                    case "getvorschlaege":
                        return HandleGetVorschlaege(requestId, parameters);
                    case "getabsagen":
                        return HandleGetAbsagen(requestId, parameters);
                    case "getanfragen":
                        return HandleGetAnfragen(requestId, parameters);
                    case "executesql":
                        return HandleExecuteSQL(requestId, parameters);
                    case "ping":
                        return CreateSuccessResponse(requestId, new { pong = true, timestamp = DateTime.Now });
                    default:
                        return CreateErrorResponse(requestId, "Unbekannte Aktion: " + action);
                }
            }
            catch (Exception ex)
            {
                _lastError = ex.Message;
                return CreateErrorResponse(requestId, ex.Message);
            }
        }

        private string HandleLoadData(int requestId, JObject parameters)
        {
            string type = parameters.Value<string>("type") ?? "";
            int? id = parameters.Value<int?>("id");

            string table = MapTypeToTable(type);
            string idField = GetIdField(type);

            string sql;
            if (id.HasValue)
            {
                sql = "SELECT * FROM " + table + " WHERE " + idField + " = " + id.Value;
            }
            else
            {
                sql = "SELECT TOP 500 * FROM " + table;
            }

            var data = ExecuteQuery(sql);
            return CreateSuccessResponse(requestId, data);
        }

        private string HandleList(int requestId, JObject parameters)
        {
            string type = parameters.Value<string>("type") ?? "";
            int limit = parameters.Value<int?>("limit") ?? 100;

            string table = MapTypeToTable(type);
            string sql = "SELECT TOP " + limit + " * FROM " + table;

            var data = ExecuteQuery(sql);
            return CreateSuccessResponse(requestId, new { data = data });
        }

        private string HandleSearch(int requestId, JObject parameters)
        {
            string type = parameters.Value<string>("type") ?? "";
            string term = parameters.Value<string>("term") ?? "";

            string table = MapTypeToTable(type);
            string searchField = GetSearchField(type);

            string sql = "SELECT TOP 50 * FROM " + table + " WHERE " + searchField + " LIKE '%" + EscapeSql(term) + "%'";

            var data = ExecuteQuery(sql);
            return CreateSuccessResponse(requestId, data);
        }

        private string HandleSave(int requestId, JObject parameters)
        {
            string type = parameters.Value<string>("type") ?? "";
            var data = parameters["data"] as JObject;

            if (data == null)
                return CreateErrorResponse(requestId, "Keine Daten zum Speichern");

            string table = MapTypeToTable(type);
            string idField = GetIdField(type);
            int? id = data.Value<int?>("id") ?? data.Value<int?>("ID");

            if (id.HasValue && id > 0)
            {
                var setClauses = new List<string>();
                foreach (var prop in data.Properties())
                {
                    if (prop.Name.ToLower() != "id" && prop.Name != idField)
                    {
                        string value = FormatValueForSql(prop.Value);
                        setClauses.Add("[" + prop.Name + "] = " + value);
                    }
                }

                if (setClauses.Count == 0)
                    return CreateErrorResponse(requestId, "Keine Felder zum Update");

                string sql = "UPDATE " + table + " SET " + string.Join(", ", setClauses) + " WHERE " + idField + " = " + id.Value;
                int affected = ExecuteNonQuery(sql);

                return CreateSuccessResponse(requestId, new { updated = affected > 0, id = id.Value });
            }
            else
            {
                var columns = new List<string>();
                var values = new List<string>();

                foreach (var prop in data.Properties())
                {
                    if (prop.Name.ToLower() != "id")
                    {
                        columns.Add("[" + prop.Name + "]");
                        values.Add(FormatValueForSql(prop.Value));
                    }
                }

                string sql = "INSERT INTO " + table + " (" + string.Join(", ", columns) + ") VALUES (" + string.Join(", ", values) + ")";
                ExecuteNonQuery(sql);

                var result = ExecuteQuery("SELECT @@IDENTITY AS NewID");
                int newId = 0;
                if (result.Count > 0 && result[0].ContainsKey("NewID"))
                {
                    newId = Convert.ToInt32(result[0]["NewID"]);
                }

                return CreateSuccessResponse(requestId, new { inserted = true, id = newId });
            }
        }

        private string HandleDelete(int requestId, JObject parameters)
        {
            string type = parameters.Value<string>("type") ?? "";
            int? id = parameters.Value<int?>("id");

            if (!id.HasValue)
                return CreateErrorResponse(requestId, "ID erforderlich");

            string table = MapTypeToTable(type);
            string idField = GetIdField(type);

            string sql = "DELETE FROM " + table + " WHERE " + idField + " = " + id.Value;
            int affected = ExecuteNonQuery(sql);

            return CreateSuccessResponse(requestId, new { deleted = affected > 0 });
        }

        private string HandleGetAuftrag(int requestId, JObject parameters)
        {
            int? id = parameters.Value<int?>("id");
            if (!id.HasValue)
                return CreateErrorResponse(requestId, "ID erforderlich");

            string sql = @"
                SELECT
                    ID AS VA_ID, Auftrag, Objekt, Objekt_ID, Ort,
                    Dat_VA_Von, Dat_VA_Bis, Veranst_Status_ID, Veranstalter_ID,
                    Treffpunkt, Treffp_Zeit, Dienstkleidung, Ansprechpartner,
                    Bemerkungen, Erst_von, Erst_am, Aend_von, Aend_am
                FROM tbl_VA_Auftragstamm
                WHERE ID = " + id.Value;

            var data = ExecuteQuery(sql);
            if (data.Count == 0)
                return CreateErrorResponse(requestId, "Auftrag nicht gefunden");

            return CreateSuccessResponse(requestId, data[0]);
        }

        private string HandleListAuftraege(int requestId, JObject parameters)
        {
            int limit = parameters.Value<int?>("limit") ?? 100;
            string status = parameters.Value<string>("status");

            string sql = @"
                SELECT TOP " + limit + @"
                    ID AS VA_ID, Auftrag, Objekt, Ort,
                    Dat_VA_Von, Dat_VA_Bis, Veranst_Status_ID
                FROM tbl_VA_Auftragstamm
                WHERE 1=1";

            if (!string.IsNullOrEmpty(status))
                sql += " AND Veranst_Status_ID = " + status;

            sql += " ORDER BY Dat_VA_Von DESC";

            var data = ExecuteQuery(sql);
            return CreateSuccessResponse(requestId, new { data = data, count = data.Count });
        }

        private string HandleGetMitarbeiter(int requestId, JObject parameters)
        {
            int? id = parameters.Value<int?>("id");
            if (!id.HasValue)
                return CreateErrorResponse(requestId, "ID erforderlich");

            string sql = @"
                SELECT
                    ID AS MA_ID, Nachname, Vorname, LexWare_ID AS PersNr,
                    Strasse, PLZ, Ort, Tel_Mobil, Tel_Festnetz, Email,
                    Geb_Dat AS Geburtsdatum, IstAktiv AS Aktiv,
                    Anstellungsart_ID AS Anstellung
                FROM tbl_MA_Mitarbeiterstamm
                WHERE ID = " + id.Value;

            var data = ExecuteQuery(sql);
            if (data.Count == 0)
                return CreateErrorResponse(requestId, "Mitarbeiter nicht gefunden");

            return CreateSuccessResponse(requestId, data[0]);
        }

        private string HandleListMitarbeiter(int requestId, JObject parameters)
        {
            int limit = parameters.Value<int?>("limit") ?? 100;
            bool? aktiv = parameters.Value<bool?>("aktiv");
            string search = parameters.Value<string>("search");

            string sql = @"
                SELECT TOP " + limit + @"
                    ID AS MA_ID, Nachname, Vorname, LexWare_ID AS PersNr,
                    Tel_Mobil, Email, IstAktiv AS Aktiv
                FROM tbl_MA_Mitarbeiterstamm
                WHERE 1=1";

            if (aktiv.HasValue && aktiv.Value)
                sql += " AND IstAktiv = True";
            if (!string.IsNullOrEmpty(search))
                sql += " AND (Nachname LIKE '%" + EscapeSql(search) + "%' OR Vorname LIKE '%" + EscapeSql(search) + "%')";

            sql += " ORDER BY Nachname, Vorname";

            var data = ExecuteQuery(sql);
            return CreateSuccessResponse(requestId, new { data = data, count = data.Count });
        }

        private string HandleGetKunde(int requestId, JObject parameters)
        {
            int? id = parameters.Value<int?>("id");
            if (!id.HasValue)
                return CreateErrorResponse(requestId, "ID erforderlich");

            string sql = @"
                SELECT
                    kun_Id, kun_Firma, kun_Kuerzel, kun_Strasse, kun_PLZ, kun_Ort,
                    kun_telefon, kun_email, kun_IstAktiv AS Aktiv
                FROM tbl_KD_Kundenstamm
                WHERE kun_Id = " + id.Value;

            var data = ExecuteQuery(sql);
            if (data.Count == 0)
                return CreateErrorResponse(requestId, "Kunde nicht gefunden");

            return CreateSuccessResponse(requestId, data[0]);
        }

        private string HandleListKunden(int requestId, JObject parameters)
        {
            try
            {
                int limit = parameters.Value<int?>("limit") ?? 200;
                bool? aktiv = parameters.Value<bool?>("aktiv");

                string sql = @"
                    SELECT TOP " + limit + @"
                        kun_Id, kun_Firma, kun_Kuerzel, kun_Ort, kun_telefon, kun_email
                    FROM tbl_KD_Kundenstamm
                    WHERE 1=1";

                if (aktiv.HasValue && aktiv.Value)
                    sql += " AND kun_IstAktiv = True";

                sql += " ORDER BY kun_Firma";

                var data = ExecuteQuery(sql);
                return CreateSuccessResponse(requestId, new { data = data, count = data.Count });
            }
            catch (Exception)
            {
                return CreateSuccessResponse(requestId, new { data = new List<object>(), count = 0 });
            }
        }

        private string HandleListObjekte(int requestId, JObject parameters)
        {
            string sql = @"
                SELECT ID, Objekt, Strasse, PLZ, Ort
                FROM tbl_OB_Objekt
                ORDER BY Objekt";

            var data = ExecuteQuery(sql);
            return CreateSuccessResponse(requestId, new { data = data });
        }

        private string HandleGetZuordnungen(int requestId, JObject parameters)
        {
            int? vaId = parameters.Value<int?>("va_id") ?? parameters.Value<int?>("VA_ID");
            if (!vaId.HasValue)
                return CreateErrorResponse(requestId, "VA_ID erforderlich");

            string sql = @"
                SELECT
                    p.ID, p.MA_ID, m.Nachname AS MA_Nachname, m.Vorname AS MA_Vorname,
                    p.MVA_Start, p.MVA_Ende, p.Status_ID, p.VADatum, p.VAStart_ID
                FROM tbl_MA_VA_Planung AS p
                LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON p.MA_ID = m.ID
                WHERE p.VA_ID = " + vaId.Value + @"
                ORDER BY p.VADatum, p.MVA_Start";

            var data = ExecuteQuery(sql);
            return CreateSuccessResponse(requestId, new { data = data });
        }

        private string HandleCreateZuordnung(int requestId, JObject parameters)
        {
            int? vaId = parameters.Value<int?>("va_id") ?? parameters.Value<int?>("VA_ID");
            int? maId = parameters.Value<int?>("ma_id") ?? parameters.Value<int?>("MA_ID");

            if (!vaId.HasValue || !maId.HasValue)
                return CreateErrorResponse(requestId, "VA_ID und MA_ID erforderlich");

            string vadatum = parameters.Value<string>("vadatum") ?? parameters.Value<string>("VADatum");
            string von = parameters.Value<string>("von") ?? parameters.Value<string>("MVA_Start");
            string bis = parameters.Value<string>("bis") ?? parameters.Value<string>("MVA_Ende");
            int status = parameters.Value<int?>("status") ?? parameters.Value<int?>("Status_ID") ?? 1;

            string sql = @"
                INSERT INTO tbl_MA_VA_Planung (VA_ID, MA_ID, VADatum, MVA_Start, MVA_Ende, Status_ID)
                VALUES (" + vaId.Value + ", " + maId.Value + ", #" + vadatum + "#, '" + von + "', '" + bis + "', " + status + ")";

            ExecuteNonQuery(sql);
            return CreateSuccessResponse(requestId, new { success = true });
        }

        private string HandleDeleteZuordnung(int requestId, JObject parameters)
        {
            int? id = parameters.Value<int?>("id");
            if (!id.HasValue)
                return CreateErrorResponse(requestId, "ID erforderlich");

            string sql = "DELETE FROM tbl_MA_VA_Planung WHERE ID = " + id.Value;
            int affected = ExecuteNonQuery(sql);

            return CreateSuccessResponse(requestId, new { deleted = affected > 0 });
        }

        private string HandleGetSchichten(int requestId, JObject parameters)
        {
            int? vaId = parameters.Value<int?>("va_id");
            if (!vaId.HasValue)
                return CreateErrorResponse(requestId, "VA_ID erforderlich");

            string sql = @"
                SELECT
                    s.VAS_ID AS ID, s.VAS_Von AS VA_Start, s.VAS_Bis AS VA_Ende,
                    s.VAS_MA_Anzahl AS MA_Anzahl, d.VADatum AS Datum
                FROM tbl_VA_Start s
                INNER JOIN tbl_VA_Datum d ON s.VAS_VADatum_ID = d.VADatum_ID
                WHERE d.VADatum_VA_ID = " + vaId.Value + @"
                ORDER BY d.VADatum, s.VAS_Von";

            var data = ExecuteQuery(sql);
            return CreateSuccessResponse(requestId, new { data = data });
        }

        private string HandleGetEinsatztage(int requestId, JObject parameters)
        {
            int? vaId = parameters.Value<int?>("va_id") ?? parameters.Value<int?>("VA_ID");
            if (!vaId.HasValue)
                return CreateErrorResponse(requestId, "VA_ID erforderlich");

            string sql = @"
                SELECT VADatum_ID AS ID, VADatum, VADatum_VA_ID AS VA_ID
                FROM tbl_VA_Datum
                WHERE VADatum_VA_ID = " + vaId.Value + @"
                ORDER BY VADatum";

            var data = ExecuteQuery(sql);
            return CreateSuccessResponse(requestId, new { data = data });
        }

        private string HandleGetStatusListe(int requestId, JObject parameters)
        {
            try
            {
                string sql = @"SELECT ID, Status_Bez AS Bezeichnung FROM tbl_VA_Status ORDER BY ID";
                var data = ExecuteQuery(sql);
                return CreateSuccessResponse(requestId, new { data = data });
            }
            catch (Exception)
            {
                var fallbackData = new[]
                {
                    new { ID = 1, Bezeichnung = "Offen" },
                    new { ID = 2, Bezeichnung = "Bestätigt" },
                    new { ID = 3, Bezeichnung = "Abgesagt" },
                    new { ID = 4, Bezeichnung = "Abgeschlossen" }
                };
                return CreateSuccessResponse(requestId, new { data = fallbackData });
            }
        }

        private string HandleGetVorschlaege(int requestId, JObject parameters)
        {
            string field = parameters.Value<string>("field") ?? "";
            var data = new List<string>();

            try
            {
                string sql = "";
                switch (field.ToLower())
                {
                    case "ort":
                        sql = "SELECT DISTINCT Ort FROM tbl_VA_Auftragstamm WHERE Ort IS NOT NULL AND Ort <> '' ORDER BY Ort";
                        break;
                    case "objekt":
                        sql = "SELECT DISTINCT Objekt FROM tbl_VA_Auftragstamm WHERE Objekt IS NOT NULL AND Objekt <> '' ORDER BY Objekt";
                        break;
                    default:
                        return CreateSuccessResponse(requestId, new { data = data });
                }

                var rows = ExecuteQuery(sql);
                foreach (var row in rows)
                {
                    var firstValue = row.Values.FirstOrDefault();
                    if (firstValue != null)
                        data.Add(firstValue.ToString());
                }
            }
            catch { }

            return CreateSuccessResponse(requestId, new { data = data });
        }

        private string HandleGetAbsagen(int requestId, JObject parameters)
        {
            int? vaId = parameters.Value<int?>("va_id") ?? parameters.Value<int?>("VA_ID");
            if (!vaId.HasValue)
                return CreateSuccessResponse(requestId, new { data = new List<object>() });

            try
            {
                string sql = @"
                    SELECT p.ID, p.MA_ID, m.Nachname AS MA_Nachname, m.Vorname AS MA_Vorname,
                           p.VADatum, p.Status_ID
                    FROM tbl_MA_VA_Planung AS p
                    LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON p.MA_ID = m.ID
                    WHERE p.VA_ID = " + vaId.Value + @" AND p.Status_ID = 3
                    ORDER BY p.VADatum";

                var data = ExecuteQuery(sql);
                return CreateSuccessResponse(requestId, new { data = data });
            }
            catch
            {
                return CreateSuccessResponse(requestId, new { data = new List<object>() });
            }
        }

        private string HandleGetAnfragen(int requestId, JObject parameters)
        {
            int? vaId = parameters.Value<int?>("va_id") ?? parameters.Value<int?>("VA_ID");
            if (!vaId.HasValue)
                return CreateSuccessResponse(requestId, new { data = new List<object>() });

            try
            {
                string sql = @"
                    SELECT p.ID, p.MA_ID, m.Nachname AS MA_Nachname, m.Vorname AS MA_Vorname,
                           p.VADatum, p.Status_ID
                    FROM tbl_MA_VA_Planung AS p
                    LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON p.MA_ID = m.ID
                    WHERE p.VA_ID = " + vaId.Value + @" AND p.Status_ID = 2
                    ORDER BY p.VADatum";

                var data = ExecuteQuery(sql);
                return CreateSuccessResponse(requestId, new { data = data });
            }
            catch
            {
                return CreateSuccessResponse(requestId, new { data = new List<object>() });
            }
        }

        private string HandleExecuteSQL(int requestId, JObject parameters)
        {
            string sql = parameters.Value<string>("sql");
            if (string.IsNullOrEmpty(sql))
                return CreateErrorResponse(requestId, "SQL erforderlich");

            if (!sql.Trim().ToUpper().StartsWith("SELECT"))
                return CreateErrorResponse(requestId, "Nur SELECT-Abfragen erlaubt");

            var data = ExecuteQuery(sql);
            return CreateSuccessResponse(requestId, new { rows = data, success = true });
        }

        private List<Dictionary<string, object>> ExecuteQuery(string sql)
        {
            var results = new List<Dictionary<string, object>>();

            using (var conn = new OleDbConnection(_connectionString))
            {
                conn.Open();
                using (var cmd = new OleDbCommand(sql, conn))
                {
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var row = new Dictionary<string, object>();
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                string name = reader.GetName(i);
                                object value = reader.IsDBNull(i) ? null : reader.GetValue(i);
                                row[name] = SerializeValue(value);
                            }
                            results.Add(row);
                        }
                    }
                }
            }

            return results;
        }

        private int ExecuteNonQuery(string sql)
        {
            using (var conn = new OleDbConnection(_connectionString))
            {
                conn.Open();
                using (var cmd = new OleDbCommand(sql, conn))
                {
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        private object SerializeValue(object value)
        {
            if (value == null) return null;
            if (value is DateTime) return ((DateTime)value).ToString("yyyy-MM-ddTHH:mm:ss");
            if (value is TimeSpan) return ((TimeSpan)value).ToString(@"hh\:mm\:ss");
            if (value is decimal) return (double)(decimal)value;
            if (value is byte[]) return Convert.ToBase64String((byte[])value);
            return value;
        }

        private string MapTypeToTable(string type)
        {
            switch (type.ToLower())
            {
                case "auftrag":
                case "auftraege":
                    return "tbl_VA_Auftragstamm";
                case "mitarbeiter":
                    return "tbl_MA_Mitarbeiterstamm";
                case "kunde":
                case "kunden":
                    return "tbl_KD_Kundenstamm";
                case "objekt":
                case "objekte":
                    return "tbl_OB_Objekt";
                case "zuordnung":
                case "zuordnungen":
                    return "tbl_MA_VA_Planung";
                case "schichten":
                    return "tbl_VA_Start";
                case "einsatztage":
                    return "tbl_VA_Datum";
                case "status":
                    return "tbl_VA_Status";
                case "abwesenheiten":
                    return "tbl_MA_Abwesenheit";
                default:
                    return type;
            }
        }

        private string GetIdField(string type)
        {
            switch (type.ToLower())
            {
                case "kunde":
                case "kunden":
                    return "kun_Id";
                default:
                    return "ID";
            }
        }

        private string GetSearchField(string type)
        {
            switch (type.ToLower())
            {
                case "mitarbeiter":
                    return "Nachname";
                case "kunde":
                case "kunden":
                    return "kun_Firma";
                case "auftrag":
                case "auftraege":
                    return "Auftrag";
                case "objekt":
                case "objekte":
                    return "Objekt";
                default:
                    return "ID";
            }
        }

        private string EscapeSql(string value)
        {
            if (string.IsNullOrEmpty(value)) return "";
            return value.Replace("'", "''");
        }

        private string FormatValueForSql(JToken token)
        {
            if (token == null || token.Type == JTokenType.Null)
                return "NULL";

            switch (token.Type)
            {
                case JTokenType.Integer:
                case JTokenType.Float:
                    return token.ToString();
                case JTokenType.Boolean:
                    return token.Value<bool>() ? "True" : "False";
                case JTokenType.Date:
                    return "#" + token.Value<DateTime>().ToString("yyyy-MM-dd HH:mm:ss") + "#";
                default:
                    string str = token.ToString();
                    return "'" + EscapeSql(str) + "'";
            }
        }

        private string CreateSuccessResponse(int requestId, object data)
        {
            var response = new
            {
                requestId = requestId,
                ok = true,
                data = data
            };
            return JsonConvert.SerializeObject(response);
        }

        private string CreateErrorResponse(int requestId, string error)
        {
            var response = new
            {
                requestId = requestId,
                ok = false,
                error = new { code = "ERROR", message = error }
            };
            return JsonConvert.SerializeObject(response);
        }

        public void Dispose()
        {
        }
    }
}
