using System;
using System.Threading.Tasks;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;

namespace ConsysWinUI.Services;

public interface IDialogService
{
    void SetXamlRoot(XamlRoot xamlRoot);
    Task ShowMessageAsync(string title, string message);
    Task<bool> ShowConfirmationAsync(string title, string message);
    Task ShowErrorAsync(string title, string message);
}

public class DialogService : IDialogService
{
    private XamlRoot? _xamlRoot;

    public void SetXamlRoot(XamlRoot xamlRoot)
    {
        _xamlRoot = xamlRoot;
    }

    public async Task ShowMessageAsync(string title, string message)
    {
        await ShowDialogAsync(title, message, "OK", null);
    }

    public async Task<bool> ShowConfirmationAsync(string title, string message)
    {
        var result = await ShowDialogAsync(title, message, "Ja", "Nein");
        return result == ContentDialogResult.Primary;
    }

    public async Task ShowErrorAsync(string title, string message)
    {
        await ShowDialogAsync($"Fehler: {title}", message, "OK", null);
    }

    private async Task<ContentDialogResult> ShowDialogAsync(
        string title,
        string content,
        string primaryButtonText,
        string? secondaryButtonText)
    {
        if (_xamlRoot == null)
        {
            // Fallback: Log error but don't crash
            System.Diagnostics.Debug.WriteLine($"DialogService: XamlRoot not set. Dialog: {title} - {content}");
            return ContentDialogResult.None;
        }

        var dialog = new ContentDialog
        {
            Title = title,
            Content = content,
            PrimaryButtonText = primaryButtonText,
            XamlRoot = _xamlRoot,
            DefaultButton = ContentDialogButton.Primary
        };

        if (!string.IsNullOrEmpty(secondaryButtonText))
        {
            dialog.SecondaryButtonText = secondaryButtonText;
        }

        return await dialog.ShowAsync();
    }
}
