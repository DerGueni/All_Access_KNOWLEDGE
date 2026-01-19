using System;
using System.Collections.Generic;
using Microsoft.UI;
using Windows.UI;

namespace ConsysWinUI.Helpers
{
    /// <summary>
    /// Konvertiert Access Long-Farbwerte in WinUI Color-Objekte
    /// </summary>
    public static class AccessColorConverter
    {
        // System-Farben Mapping (negative Werte in Access)
        private static readonly Dictionary<long, Color> SystemColors = new()
        {
            { -2147483633, Color.FromArgb(255, 240, 240, 240) }, // COLOR_BTNFACE
            { -2147483643, Color.FromArgb(255, 0, 0, 0) },       // COLOR_WINDOWTEXT
            { -2147483640, Color.FromArgb(255, 255, 255, 255) }, // COLOR_WINDOW
            { -2147483635, Color.FromArgb(255, 192, 192, 192) }, // COLOR_BTNSHADOW
            { -2147483632, Color.FromArgb(255, 128, 128, 128) }, // COLOR_GRAYTEXT
            { -2147483630, Color.FromArgb(255, 0, 0, 0) },       // COLOR_BTNTEXT
            { -2147483616, Color.FromArgb(255, 0, 0, 0) },       // COLOR_INFOTEXT
            { -2147483605, Color.FromArgb(255, 240, 240, 240) }, // COLOR_BTNHIGHLIGHT
        };

        /// <summary>
        /// Konvertiert Access-Farbwert (Long) zu WinUI Color
        /// </summary>
        public static Color ToColor(long accessColor)
        {
            // System-Farben (negative Werte)
            if (accessColor < 0)
            {
                if (SystemColors.TryGetValue(accessColor, out Color systemColor))
                {
                    return systemColor;
                }
                // Fallback für unbekannte System-Farben
                return Color.FromArgb(255, 240, 240, 240);
            }

            // Normale BGR-Farben
            byte r = (byte)(accessColor & 0xFF);
            byte g = (byte)((accessColor >> 8) & 0xFF);
            byte b = (byte)((accessColor >> 16) & 0xFF);

            return Color.FromArgb(255, r, g, b);
        }

        /// <summary>
        /// Konvertiert Access-Farbwert zu Hex-String
        /// </summary>
        public static string ToHex(long accessColor)
        {
            Color color = ToColor(accessColor);
            return $"#{color.R:X2}{color.G:X2}{color.B:X2}";
        }

        /// <summary>
        /// Konvertiert Hex-String zu Color
        /// </summary>
        public static Color FromHex(string hex)
        {
            hex = hex.TrimStart('#');

            if (hex.Length == 6)
            {
                return Color.FromArgb(
                    255,
                    Convert.ToByte(hex.Substring(0, 2), 16),
                    Convert.ToByte(hex.Substring(2, 2), 16),
                    Convert.ToByte(hex.Substring(4, 2), 16)
                );
            }

            if (hex.Length == 8)
            {
                return Color.FromArgb(
                    Convert.ToByte(hex.Substring(0, 2), 16),
                    Convert.ToByte(hex.Substring(2, 2), 16),
                    Convert.ToByte(hex.Substring(4, 2), 16),
                    Convert.ToByte(hex.Substring(6, 2), 16)
                );
            }

            return Colors.Transparent;
        }

        /// <summary>
        /// Konvertiert Twips zu Pixel (Access verwendet Twips für Positionen)
        /// </summary>
        public static double TwipsToPixels(int twips)
        {
            return twips / 15.0;
        }

        /// <summary>
        /// Konvertiert Pixel zu Twips
        /// </summary>
        public static int PixelsToTwips(double pixels)
        {
            return (int)(pixels * 15);
        }
    }
}
