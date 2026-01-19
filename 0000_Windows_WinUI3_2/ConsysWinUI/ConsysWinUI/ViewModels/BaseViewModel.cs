using System;
using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using ConsysWinUI.Services;

namespace ConsysWinUI.ViewModels;

/// <summary>
/// Abstrakte Basisklasse für alle ViewModels im CONSYS System.
/// Stellt gemeinsame Funktionalität und Services bereit.
/// </summary>
public abstract partial class BaseViewModel : ObservableObject
{
    protected readonly IDatabaseService _databaseService;
    protected readonly INavigationService _navigationService;
    protected readonly IDialogService _dialogService;

    [ObservableProperty]
    private bool _isLoading;

    [ObservableProperty]
    private string? _statusMessage;

    [ObservableProperty]
    private bool _hasError;

    protected BaseViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
    {
        _databaseService = databaseService ?? throw new ArgumentNullException(nameof(databaseService));
        _navigationService = navigationService ?? throw new ArgumentNullException(nameof(navigationService));
        _dialogService = dialogService ?? throw new ArgumentNullException(nameof(dialogService));
    }

    /// <summary>
    /// Initialisiert das ViewModel. Wird beim ersten Laden aufgerufen.
    /// </summary>
    public virtual Task InitializeAsync()
    {
        return Task.CompletedTask;
    }

    /// <summary>
    /// Führt eine Operation mit Loading-Status und Fehlerbehandlung aus.
    /// </summary>
    protected async Task ExecuteWithLoadingAsync(Func<Task> operation, string? loadingMessage = null)
    {
        try
        {
            IsLoading = true;
            HasError = false;
            StatusMessage = loadingMessage ?? "Lädt...";

            await operation();

            StatusMessage = null;
        }
        catch (Exception ex)
        {
            HasError = true;
            StatusMessage = $"Fehler: {ex.Message}";
            await _dialogService.ShowErrorAsync("Fehler", ex.Message);
        }
        finally
        {
            IsLoading = false;
        }
    }

    /// <summary>
    /// Führt eine Operation mit Loading-Status, Fehlerbehandlung und Rückgabewert aus.
    /// </summary>
    protected async Task<T?> ExecuteWithLoadingAsync<T>(Func<Task<T>> operation, string? loadingMessage = null)
    {
        try
        {
            IsLoading = true;
            HasError = false;
            StatusMessage = loadingMessage ?? "Lädt...";

            var result = await operation();

            StatusMessage = null;
            return result;
        }
        catch (Exception ex)
        {
            HasError = true;
            StatusMessage = $"Fehler: {ex.Message}";
            await _dialogService.ShowErrorAsync("Fehler", ex.Message);
            return default;
        }
        finally
        {
            IsLoading = false;
        }
    }

    /// <summary>
    /// Zeigt eine Erfolgsmeldung an.
    /// </summary>
    protected void ShowSuccess(string message)
    {
        HasError = false;
        StatusMessage = message;
    }

    /// <summary>
    /// Zeigt eine Fehlermeldung an.
    /// </summary>
    protected void ShowError(string message)
    {
        HasError = true;
        StatusMessage = message;
    }

    /// <summary>
    /// Zeigt eine Info-Meldung an.
    /// </summary>
    protected void ShowInfo(string message)
    {
        HasError = false;
        StatusMessage = message;
    }
}
