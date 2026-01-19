using System;
using System.Collections.Generic;
using Microsoft.UI.Xaml.Controls;

namespace ConsysWinUI.Services;

public interface INavigationAware
{
    void OnNavigatedTo(object? parameter);
    void OnNavigatedFrom();
}

public interface INavigationService
{
    void NavigateTo<TViewModel>(object? parameter = null) where TViewModel : class;
    void NavigateBack();
    bool CanNavigateBack { get; }
    event EventHandler<Type>? NavigationRequested;
}

public class NavigationService : INavigationService
{
    private readonly Stack<Type> _navigationStack = new();
    private object? _currentViewModel;

    public event EventHandler<Type>? NavigationRequested;

    public bool CanNavigateBack => _navigationStack.Count > 0;

    public void NavigateTo<TViewModel>(object? parameter = null) where TViewModel : class
    {
        var viewModelType = typeof(TViewModel);

        // Store current page in stack if exists
        if (_currentViewModel != null)
        {
            if (_currentViewModel is INavigationAware currentAware)
            {
                currentAware.OnNavigatedFrom();
            }

            _navigationStack.Push(_currentViewModel.GetType());
        }

        // Navigate to new page
        NavigationRequested?.Invoke(this, viewModelType);
    }

    public void NavigateBack()
    {
        if (!CanNavigateBack)
            return;

        // Notify current page
        if (_currentViewModel is INavigationAware currentAware)
        {
            currentAware.OnNavigatedFrom();
        }

        // Pop and navigate to previous page
        var previousType = _navigationStack.Pop();
        NavigationRequested?.Invoke(this, previousType);
    }

    public void SetCurrentViewModel(object viewModel)
    {
        _currentViewModel = viewModel;

        if (viewModel is INavigationAware aware)
        {
            aware.OnNavigatedTo(null);
        }
    }

    public void NotifyNavigated(object viewModel, object? parameter)
    {
        _currentViewModel = viewModel;

        if (viewModel is INavigationAware aware)
        {
            aware.OnNavigatedTo(parameter);
        }
    }
}
