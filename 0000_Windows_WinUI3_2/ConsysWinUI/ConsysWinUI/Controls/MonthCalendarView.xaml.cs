using Microsoft.UI;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;

namespace ConsysWinUI.Controls;

/// <summary>
/// Monats-Kalender Control mit Abwesenheits-Markierungen.
/// Zeigt einen Monat in klassischer Kalenderansicht (7x6 Grid).
/// </summary>
public sealed partial class MonthCalendarView : UserControl
{
    private readonly List<MonthDayCell> _dayCells = new();

    public MonthCalendarView()
    {
        this.InitializeComponent();
        RenderCalendar();
    }

    #region Dependency Properties

    public static readonly DependencyProperty MonthProperty =
        DependencyProperty.Register(
            nameof(Month),
            typeof(int),
            typeof(MonthCalendarView),
            new PropertyMetadata(DateTime.Today.Month, OnDateChanged));

    public static readonly DependencyProperty YearProperty =
        DependencyProperty.Register(
            nameof(Year),
            typeof(int),
            typeof(MonthCalendarView),
            new PropertyMetadata(DateTime.Today.Year, OnDateChanged));

    public static readonly DependencyProperty EntriesProperty =
        DependencyProperty.Register(
            nameof(Entries),
            typeof(ObservableCollection<CalendarEntry>),
            typeof(MonthCalendarView),
            new PropertyMetadata(null, OnEntriesChanged));

    public int Month
    {
        get => (int)GetValue(MonthProperty);
        set => SetValue(MonthProperty, value);
    }

    public int Year
    {
        get => (int)GetValue(YearProperty);
        set => SetValue(YearProperty, value);
    }

    public ObservableCollection<CalendarEntry> Entries
    {
        get => (ObservableCollection<CalendarEntry>)GetValue(EntriesProperty);
        set => SetValue(EntriesProperty, value);
    }

    private static void OnDateChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
    {
        if (d is MonthCalendarView calendar)
        {
            calendar.RenderCalendar();
        }
    }

    private static void OnEntriesChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
    {
        if (d is MonthCalendarView calendar)
        {
            calendar.UpdateEntries();
        }
    }

    #endregion

    #region Event

    public event EventHandler<CalendarEntryClickedEventArgs>? EntryClicked;

    #endregion

    #region Private Methods

    private void RenderCalendar()
    {
        // Validierung
        if (Month < 1 || Month > 12 || Year < 1900 || Year > 2100)
            return;

        // Clear existing cells
        _dayCells.Clear();
        CalendarContentGrid.Children.Clear();

        // Ersten Tag des Monats
        var firstDayOfMonth = new DateTime(Year, Month, 1);
        var daysInMonth = DateTime.DaysInMonth(Year, Month);

        // Wochentag des ersten Tages (Montag = 1, Sonntag = 7)
        var firstDayOfWeek = (int)firstDayOfMonth.DayOfWeek;
        if (firstDayOfWeek == 0) firstDayOfWeek = 7; // Sonntag

        // Start-Datum (kann im vorherigen Monat liegen)
        var startDate = firstDayOfMonth.AddDays(-(firstDayOfWeek - 1));

        // Erstelle 42 Zellen (6 Zeilen x 7 Spalten)
        for (int i = 0; i < 42; i++)
        {
            var cellDate = startDate.AddDays(i);
            var isCurrentMonth = cellDate.Month == Month;
            var isToday = cellDate.Date == DateTime.Today;
            var isWeekend = cellDate.DayOfWeek == DayOfWeek.Saturday || cellDate.DayOfWeek == DayOfWeek.Sunday;

            var cell = new MonthDayCell(cellDate, isCurrentMonth, isToday, isWeekend);
            cell.EntryClicked += OnCellEntryClicked;

            var row = i / 7;
            var col = i % 7;

            Grid.SetRow(cell, row);
            Grid.SetColumn(cell, col);

            CalendarContentGrid.Children.Add(cell);
            _dayCells.Add(cell);
        }

        // Update entries wenn bereits vorhanden
        UpdateEntries();
    }

    private void UpdateEntries()
    {
        if (Entries == null || !_dayCells.Any())
            return;

        // Leere alle Zellen
        foreach (var cell in _dayCells)
        {
            cell.ClearEntries();
        }

        // Setze Einträge für entsprechende Tage
        foreach (var entry in Entries)
        {
            var cell = _dayCells.FirstOrDefault(c => c.Date.Date == entry.Date.Date);
            cell?.AddEntry(entry);
        }
    }

    private void OnCellEntryClicked(object? sender, CalendarEntryClickedEventArgs e)
    {
        EntryClicked?.Invoke(this, e);
    }

    #endregion
}

/// <summary>
/// Einzelne Tages-Zelle im Monatskalender
/// </summary>
internal class MonthDayCell : UserControl
{
    private readonly DateTime _date;
    private readonly bool _isCurrentMonth;
    private readonly bool _isToday;
    private readonly bool _isWeekend;
    private readonly Border _containerBorder;
    private readonly TextBlock _dayNumberText;
    private readonly StackPanel _entriesPanel;
    private readonly List<CalendarEntry> _entries = new();

    public DateTime Date => _date;
    public event EventHandler<CalendarEntryClickedEventArgs>? EntryClicked;

    public MonthDayCell(DateTime date, bool isCurrentMonth, bool isToday, bool isWeekend)
    {
        _date = date;
        _isCurrentMonth = isCurrentMonth;
        _isToday = isToday;
        _isWeekend = isWeekend;

        // Main Grid
        var mainGrid = new Grid
        {
            RowDefinitions =
            {
                new RowDefinition { Height = GridLength.Auto },
                new RowDefinition { Height = new GridLength(1, GridUnitType.Star) }
            }
        };

        // Tagesnummer
        _dayNumberText = new TextBlock
        {
            Text = date.Day.ToString(),
            FontSize = 12,
            FontWeight = isToday ? Microsoft.UI.Text.FontWeights.Bold : Microsoft.UI.Text.FontWeights.Normal,
            Foreground = isToday
                ? new SolidColorBrush(Colors.Blue)
                : isCurrentMonth
                    ? new SolidColorBrush(Colors.Black)
                    : new SolidColorBrush(Colors.Gray),
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Top,
            Margin = new Thickness(2, 2, 2, 4)
        };

        Grid.SetRow(_dayNumberText, 0);
        mainGrid.Children.Add(_dayNumberText);

        // Einträge Panel
        _entriesPanel = new StackPanel
        {
            Orientation = Orientation.Vertical,
            Spacing = 2,
            HorizontalAlignment = HorizontalAlignment.Stretch,
            VerticalAlignment = VerticalAlignment.Top,
            Margin = new Thickness(2, 0, 2, 2)
        };

        Grid.SetRow(_entriesPanel, 1);
        mainGrid.Children.Add(_entriesPanel);

        // Container Border
        _containerBorder = new Border
        {
            BorderBrush = new SolidColorBrush(Colors.LightGray),
            BorderThickness = new Thickness(1),
            Background = GetCellBackground(),
            Child = mainGrid,
            MinHeight = 60
        };

        Content = _containerBorder;
    }

    public void AddEntry(CalendarEntry entry)
    {
        _entries.Add(entry);
        RenderEntries();
    }

    public void ClearEntries()
    {
        _entries.Clear();
        _entriesPanel.Children.Clear();
    }

    private void RenderEntries()
    {
        _entriesPanel.Children.Clear();

        // Maximal 3 Einträge anzeigen
        var visibleEntries = _entries.Take(3).ToList();

        foreach (var entry in visibleEntries)
        {
            var entryIndicator = CreateEntryIndicator(entry);
            _entriesPanel.Children.Add(entryIndicator);
        }

        // "Mehr..." Indikator wenn mehr als 3 Einträge
        if (_entries.Count > 3)
        {
            var moreText = new TextBlock
            {
                Text = $"+{_entries.Count - 3} weitere",
                FontSize = 9,
                Foreground = new SolidColorBrush(Colors.Gray),
                HorizontalAlignment = HorizontalAlignment.Center,
                Margin = new Thickness(0, 2, 0, 0)
            };
            _entriesPanel.Children.Add(moreText);
        }
    }

    private Border CreateEntryIndicator(CalendarEntry entry)
    {
        var indicator = new Border
        {
            Background = GetEntryColor(entry.Type),
            BorderBrush = GetBorderColor(entry.Type),
            BorderThickness = new Thickness(1),
            CornerRadius = new CornerRadius(3),
            Padding = new Thickness(4, 2, 4, 2),
            Tag = entry
        };

        var text = new TextBlock
        {
            Text = entry.Badge ?? entry.Title,
            FontSize = 9,
            FontWeight = Microsoft.UI.Text.FontWeights.SemiBold,
            Foreground = new SolidColorBrush(Colors.Black),
            TextTrimming = TextTrimming.CharacterEllipsis,
            MaxLines = 1
        };

        indicator.Child = text;

        // Click handler
        indicator.PointerPressed += (s, e) =>
        {
            EntryClicked?.Invoke(this, new CalendarEntryClickedEventArgs { Entry = entry });
        };

        return indicator;
    }

    private SolidColorBrush GetCellBackground()
    {
        if (_isToday)
            return new SolidColorBrush(Windows.UI.Color.FromArgb(40, 0, 120, 215)); // Hellblau

        if (_isWeekend)
            return new SolidColorBrush(Windows.UI.Color.FromArgb(15, 128, 128, 128)); // Hellgrau

        if (!_isCurrentMonth)
            return new SolidColorBrush(Windows.UI.Color.FromArgb(10, 128, 128, 128)); // Sehr hellgrau

        return new SolidColorBrush(Colors.White);
    }

    private SolidColorBrush GetBorderColor(CalendarEntryType type)
    {
        return type switch
        {
            CalendarEntryType.Schicht => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 70, 130, 180)), // SteelBlue
            CalendarEntryType.Einsatz => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 34, 139, 34)), // ForestGreen
            CalendarEntryType.Abwesenheit => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 139, 0, 0)), // DarkRed
            CalendarEntryType.Urlaub => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 255, 140, 0)), // DarkOrange
            CalendarEntryType.Krank => new SolidColorBrush(Windows.UI.Color.FromArgb(255, 178, 34, 34)), // Firebrick
            _ => new SolidColorBrush(Colors.Gray)
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
            _ => new SolidColorBrush(Colors.LightGray)
        };
    }
}
