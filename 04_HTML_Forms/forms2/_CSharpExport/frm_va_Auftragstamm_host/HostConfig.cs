using System;
using System.IO;
using System.Text.Json;

namespace Consys.AccessHost
{
    public class HostConfig
    {
        public string AccdbPath { get; set; } = "";
        public string FormName { get; set; } = "frm_va_Auftragstamm";

        public static HostConfig LoadOrCreate(string path)
        {
            if (!File.Exists(path))
            {
                var cfg = new HostConfig();
                File.WriteAllText(path, JsonSerializer.Serialize(cfg, new JsonSerializerOptions { WriteIndented = true }));
                return cfg;
            }
            var json = File.ReadAllText(path);
            var loaded = JsonSerializer.Deserialize<HostConfig>(json);
            return loaded ?? new HostConfig();
        }
    }
}
