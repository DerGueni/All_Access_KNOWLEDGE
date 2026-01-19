using Microsoft.UI;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace ConsysWinUI.Controls;

/// <summary>
/// Wiederverwendbares Kalender-Grid Control für Wochen-Ansicht (7 Tage).
/// Zeigt Schichten/Einsätze pro Tag mit vertikaler Timeline.
/// </summary>
public sealed partial class CalendarGrid : UserControl
{
    private DateTime _startDate;
    private readonly List<CalendarDayColumn> _dayColumns = new();

    public CalendarGrid()
    {
        this.InitializeComponent();
        SetCurrentWeek();
    }

    #region Public Properties

    /// <summary>
    /// Event wenn eine Schicht angeklickt wird
    /// </summary>
    public event EventHandler<CalendarEntryClickedEventArgs>? EntryClicked;

    /// <summary>
    /// Event wenn der Zeitraum geändert wird
    /// </summary>
    public event EventHandler<DateRangeChangedEventArgs>? DateRangeChanged;

    #endregion

    #region Public Methods

    /// <summary>
    /// Setzt die Kalenderdaten für die aktuelle Woche
    /// </summary>
    public void SetEntries(IEnumerable<CalendarEntry> entries)
    {
        foreach (var column in _dayColumns)
        {
            var dayEntries = entries.Where(e => e.Date.Date == column.Date.Date).ToList();
            column.SetEntries(dayEntries);
        }
    }

    /// <summary>
    /// Löscht alle Einträge
    /// </summary>
    public void ClearEntries()
    {
        foreach (var column in _dayColumns)
        {
            column.ClearEntries();
        }
    }

    /// <summary>
    /// Setzt die Woche auf das heutige Datum
    /// </summary>
    public void SetCurrentWeek()
    {
        var today = DateTime.Today;
        var dayOfWeek = (int)today.DayOfWeek;
        if (dayOfWeek == 0) dayOfWeek = 7; // Sonntag = 7

        _startDate = today.AddDays(-(dayOfWeek - 1)); // Montag
        RenderCalendar();
    }

    /// <summary>
    /// Setzt den Start-Datum (muss ein Montag sein)
    /// </summary>
    public void SetWeek(DateTime startDate)
    {
        // Stelle sicher, dass es ein Montag ist
        var dayOfWeek = (int)startDate.DayOfWeek;
        if (dayOfWeek == 0) dayOfWeek = 7;

        _startDate = startDate.AddDays(-(dayOfWeek - 1));
        RenderCalendar();
    }

    #endregion

    #region Private Methods

    private void RenderCalendar()
    {
        // Update Header
        UpdateWeekHeader();

        // Clear existing columns
        _dayColumns.Clear();
        CalendarGridContent.Children.Clear();
        HeaderGrid.Children.Clear();

        // Create 7 day columns (Montag bis Sonntag)
        var germanCulture = new CultureInfo("de-DE");

        for (int i = 0; i < 7; i++)
        {
            var date = _startDate.AddDays(i);
            var isWeekend = date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday;
            var isToday = date.Date == DateTime.Today;

            // Header
            var headerBorder = new Border
            {
                Background = isWeekend
                    ? new SolidColorBrush(Microsoft.UI.Colors.LightGray)
                    : new SolidColorBrush(Microsoft.UI.Colors.Transparent),
                BorderBrush = new SolidColorBrush(Microsoft.UI.Colors.Gray),
                BorderThickness = new Thickness(1, 1, 1, 0),
                Padding = new Thickness(8, 12, 8, 12),
                CornerRadius = new CornerRadius(4, 4, 0, 0)
            };

            var headerStack = new StackPanel
            {
                Orientation = Orientation.Vertical,
                HorizontalAlignment = HorizontalAlignment.Center,
                Spacing = 4
            };

            var dayNameText = new TextBlock
            {
                Text = date.ToString("dddd", germanCulture),
                FontSize = 12,
                FontWeight = Microsoft.UI.Text.FontWeights.SemiBold,
                HorizontalAlignment = HorizontalAlignment.Center
            };

            var dateText = new TextBlock
            {
                Text = date.ToString("dd.MM.yyyy"),
                FontSize = 14,
                FontWeight = isToday ? Microsoft.UI.Text.FontWeights.Bold : Microsoft.UI.Text.FontWeights.Normal,
                Foreground = isToday
                    ? new SolidColorBrush(Microsoft.UI.Colors.Blue)
                    : new SolidColorBrush(Microsoft.UI.Colors.Black),
                HorizontalAlignment = HorizontalAlignment.Center
            };

            headerStack.Children.Add(dayNameText);
            headerStack.Children.Add(dateText);
            headerBorder.Child = headerStack;

            Grid.SetColumn(headerBorder, i);
            HeaderGrid.Children.Add(headerBorder);

            // Day Column
            var dayColumn = new CalendarDayColumn(date, isWeekend, isToday);
            dayColumn.EntryClicked += OnEntryClicked;

            Grid.SetColumn(dayColumn, i);
            CalendarGridContent.Children.Add(dayColumn);

            _dayColumns.Add(dayColumn);
        }

        // Fire event
        DateRangeChanged?.Invoke(this, new DateRangeChangedEventArgs
        {
            StartDate = _startDate,
            EndDate = _startDate.AddDays(6)
        });
    }

    private void UpdateWeekHeader()
    {
        var endDate = _startDate.AddDays(6);
        var weekNumber = GetWeekNumber(_startDate);

        WeekRangeText.Text = $"KW {weekNumber}: {_startDate:dd.MM.yyyy} - {endDate:dd.MM.yyyy}";
    }

    private int GetWeekNumber(DateTime date)
    {
        var germanCulture = new CultureInfo("de-DE");
        return germanCulture.Calendar.GetWeekOfYear(
            date,
            CalendarWeekRule.FirstFourDayWeek,
            DayOfWeek.Monday);
    }

    #endregion

    #region Event Handlers

    private void PreviousWeek_Click(object sender, RoutedEventArgs e)
    {
        _startDate = _startDate.AddDays(-7);
        RenderCalendar();
    }

    private void NextWeek_Click(object sender, RoutedEventArgs e)
    {
        _startDate = _startDate.AddDays(7);
        RenderCalendar();
    }

    private void CurrentWeek_Click(object sender, RoutedEventArgs e)
    {
        SetCurrentWeek();
    }

    private void OnEntryClicked(object? sender, CalendarEntryClickedEventArgs e)
    {
        EntryClicked?.Invoke(this, e);
    }

    #endregion
}

/// <summary>
/// Einzelne Tages-Spalte im Kalender
/// </summary>
internal class CalendarDayColumn : UserControl
{
    private readonly DateTime _date;
    private readonly StackPanel _entriesPanel;
    private readonly Border _containerBorder;

    public DateTime Date => _date;
    public event EventHandler<CalendarEntryClickedEventArgs>? EntryClicked;

    public CalendarDayColumn(DateTime date, bool isWeekend, bool isToday)
    {
        _date = date;

        // Entries Container
        _entriesPanel = new StackPanel
        {
            Spacing = 4,
            Orientation = Orientation.Vertical
        };

        // Container Border mit Styling
        _containerBorder = new Border
        {
            BorderBrush = new SolidColorBrush(Microsoft.UI.Colors.Gray),
            BorderThickness = new Thickness(1, 0, 1, 1),
            Background = isWeekend
                ? new SolidColorBrush(Windows.UI.Color.FromArgb(20, 128, 128, 128))
                : new SolidColorBrush(Microsoft.UI.Colors.White),
            Padding = new Thickness(8),
            MinHeight = 400,
            Child = _entriesPanel
        };

        if (isToday)
        {
            _containerBorder.Background = new SolidColorBrush(Windows.UI.Color.FromArgb(30, 0, 120, 215));
        }

        Content = _containerBorder;
    }

    public void SetEntries(List<CalendarEntry> entries)
    {
        _entriesPanel.Children.Clear();

        if (!entries.Any())
        {
            var emptyText = new TextBlock
            {
                Text = "Keine Einträge",
                FontSize = 11,
                Foreground = new SolidColorBrush(Microsoft.UI.Colors.Gray),
                HorizontalAlignment = HorizontalAlignment.Center,
                Margin = new Thickness(0, 20, 0, 0)
            };
            _entriesPanel.Children.Add(emptyText);
            return;
        }

        // Sortiere nach Startzeit
        var sortedEntries = entries.OrderBy(e => e.StartTime).ToList();

        foreach (var entry in sortedEntries)
        {
            var entryCard = CreateEntryCard(entry);
            _entriesPanel.Children.Add(entryCard);
        }
    }

    public void ClearEntries()
    {
        _entriesPanel.Children.Clear();
    }

    private Border CreateEntryCard(CalendarEntry entry)
    {
        var card = new Border
        {
            Background = GetEntryColor(entry.Type),
            BorderBrush = GetBorderColor(entry.Type),
            BorderThickness = new Thickness(2, 2, 2, 2),
            CornerRadius = new CornerRadius(6),
            Padding = new Thickness(8, 6, 8, 6),
            Margin = new Thickness(0, 0, 0, 6),
            Tag = entry
        };

        var stack = new StackPanel { Spacing = 3 };

        // Zeit (nur wenn nicht ganztägig)
        if (entry.Type != CalendarEntryType.Abwesenheit &&
            entry.Type != CalendarEntryType.Urlaub &&
            entry.Type != CalendarEntryType.Krank)
        {
            var timeText = new TextBlock
            {
                Text = $"{entry.StartTime:hh\\:mm} - {entry.EndTime:hh\\:mm}",
                FontSize = 11,
                FontWeight = Microsoft.UI.Text.FontWeights.SemiBold,
                Foreground = new SolidColorBrush(Microsoft.UI.Colors.Black)
            };
            stack.Children.Add(timeText);
        }

        // Titel
        var titleText = new TextBlock
        {
            Text = entry.Title,
            FontSize = 12,
            FontWeight = Microsoft.UI.Text.FontWeights.Bold,
            TextWrapping = TextWrapping.Wrap,
            Foreground = new SolidColorBrush(Microsoft.UI.Colors.Black)
        };
        stack.Children.Add(titleText);

        // Details
        if (!string.IsNullOrEmpty(entry.Details))
        {
            var detailsText = new TextBlock
            {
                Text = entry.Details,
                FontSize = 10,
                Foreground = new SolidColorBrush(Windows.UI.Color.FromArgb(255, 60, 60, 60)),
                TextWrapping = TextWrapping.Wrap,
                MaxLines = 2,
                TextTrimming = TextTrimming.CharacterEllipsis
            };
            stack.Children.Add(detailsText);
        }

        // Badge (z.B. "2/5 MA" oder "Urlaub")
        if (!string.IsNullOrEmpty(entry.Badge))
        {
            var badgeBorder = new Border
            {
                Background = new SolidColorBrush(Windows.UI.Color.FromArgb(80, 0, 0, 0)),
                CornerRadius = new CornerRadius(3),
                Padding = new Thickness(6, 2, 6, 2),
                HorizontalAlignment = HorizontalAlignment.Left,
                Margin = new Thickness(0, 2, 0, 0)
            };

            var badgeText = new TextBlock
            {
                Text = entry.Badge,
                FontSize = 10,
                FontWeight = Microsoft.UI.Text.FontWeights.SemiBold,
                Foreground = entry.BadgeColor != null
                    ? new SolidColorBrush(entry.BadgeColor.Value)
                    : new SolidColorBrush(Microsoft.UI.Colors.White)
            };

            badgeBorder.Child = badgeText;
            stack.Children.Add(badgeBorder);
        }

        card.Child = stack;

        // Click-Handler mit Hover-Effekt
        card.PointerEntered += (s, e) =>
        {
            card.BorderThickness = new Thickness(3);
        };

        card.PointerExited += (s, e) =>
        {
            card.BorderThickness = new Thickness(2);
        };

        card.PointerPressed += (s, e) =>
        {
            EntryClicked?.Invoke(this, new CalendarEntryClickedEventArgs { Entry = entry });
        };

        return card;
    }

    private SolidColorBrush GetBorderColor(CalendarEntryType type)
    {
        return type switch
        {
            CalendarEntryType.Schicht => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 70, 130, 180)), // SteelBlue
            CalendarEntryType.Einsatz => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 34, 139, 34)), // ForestGreen
            CalendarEntryType.Abwesenheit => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 255, 105, 180)), // HotPink
            CalendarEntryType.Urlaub => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 255, 140, 0)), // DarkOrange
            CalendarEntryType.Krank => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 220, 20, 60)), // Crimson
            _ => new SolidColorBrush(Microsoft.UI.Colors.Gray)
        };
    }

    private SolidColorBrush GetEntryColor(CalendarEntryType type)
    {
        return type switch
        {
            CalendarEntryType.Schicht => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 173, 216, 230)), // LightBlue
            CalendarEntryType.Einsatz => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 144, 238, 144)), // LightGreen
            CalendarEntryType.Abwesenheit => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 255, 182, 193)), // LightPink
            CalendarEntryType.Urlaub => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 255, 218, 185)), // PeachPuff
            CalendarEntryType.Krank => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 255, 160, 122)), // LightSalmon
            _ => new SolidColorBrush(Microsoft.UI.Colors.LightGray)
        };
    }
}

#region Event Args & Models

public class CalendarEntryClickedEventArgs : EventArgs
{
    public CalendarEntry Entry { get; set; } = null!;
}

public class DateRangeChangedEventArgs : EventArgs
{
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
}

public class CalendarEntry
{
    public int Id { get; set; }
    public DateTime Date { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Details { get; set; }
    public string? Badge { get; set; }
    public Windows.UI.Color? BadgeColor { get; set; }
    public CalendarEntryType Type { get; set; }
    public object? Data { get; set; } // Zusätzliche Daten (z.B. VA_ID, MA_ID)
}

public enum CalendarEntryType
{
    Schicht,
    Einsatz,
    Abwesenheit,
    Urlaub,
    Krank
}

#endregion
