using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.UI.Xaml;
using System;
using System.IO;
using System.Diagnostics;
using ConsysWinUI.Services;
using ConsysWinUI.ViewModels;

namespace ConsysWinUI
{
    public partial class App : Application
    {
        private static IServiceProvider? _serviceProvider;
        private Window? _window;

        public static IServiceProvider ServiceProvider => _serviceProvider!;

        public App()
        {
            try
            {
                LogStartup("App constructor started");

                // Set up global exception handlers
                this.UnhandledException += App_UnhandledException;
                System.AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;
                System.Threading.Tasks.TaskScheduler.UnobservedTaskException += TaskScheduler_UnobservedTaskException;

                LogStartup("Exception handlers registered, calling InitializeComponent");
                this.InitializeComponent();
                LogStartup("InitializeComponent completed");

                ConfigureServices();
                LogStartup("ConfigureServices completed");
            }
            catch (Exception ex)
            {
                LogStartup($"FATAL ERROR: {ex}");
                throw;
            }
        }

        private static void LogStartup(string message)
        {
            var logPath = Path.Combine(AppContext.BaseDirectory, "startup.log");
            var logLine = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff}] {message}\n";
            File.AppendAllText(logPath, logLine);
            Debug.WriteLine(logLine);
        }

        private void App_UnhandledException(object sender, Microsoft.UI.Xaml.UnhandledExceptionEventArgs e)
        {
            Debug.WriteLine($"Unhandled Exception: {e.Exception}");
            e.Handled = true;
        }

        private void CurrentDomain_UnhandledException(object sender, System.UnhandledExceptionEventArgs e)
        {
            Debug.WriteLine($"Domain Unhandled Exception: {e.ExceptionObject}");
        }

        private void TaskScheduler_UnobservedTaskException(object? sender, System.Threading.Tasks.UnobservedTaskExceptionEventArgs e)
        {
            Debug.WriteLine($"Unobserved Task Exception: {e.Exception}");
            e.SetObserved();
        }

        private void ConfigureServices()
        {
            var services = new ServiceCollection();

            // Configuration
            var configPath = Path.Combine(AppContext.BaseDirectory, "appsettings.json");
            var configuration = new ConfigurationBuilder()
                .SetBasePath(AppContext.BaseDirectory)
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                .Build();

            services.AddSingleton<IConfiguration>(configuration);

            // Core Services
            services.AddSingleton<IDatabaseService, DatabaseService>();
            services.AddSingleton<INavigationService, NavigationService>();
            services.AddSingleton<IDialogService, DialogService>();

            // ViewModels
            services.AddTransient<MainMenuViewModel>();
            services.AddTransient<MitarbeiterstammViewModel>();
            services.AddTransient<KundenstammViewModel>();
            services.AddTransient<ObjektstammViewModel>();
            services.AddTransient<AuftragstammViewModel>();
            services.AddTransient<DienstplanMAViewModel>();
            services.AddTransient<DienstplanObjektViewModel>();
            services.AddTransient<SchnellauswahlViewModel>();
            services.AddTransient<BewerberViewModel>();
            services.AddTransient<AbwesenheitViewModel>();
            services.AddTransient<ZeitkontenViewModel>();
            services.AddTransient<LohnabrechnungenViewModel>();
            services.AddTransient<EinstellungenViewModel>();

            // Build ServiceProvider
            _serviceProvider = services.BuildServiceProvider();
        }

        protected override void OnLaunched(Microsoft.UI.Xaml.LaunchActivatedEventArgs args)
        {
            try
            {
                LogStartup("OnLaunched started");
                _window = new MainWindow();
                LogStartup("MainWindow created");
                _window.Activate();
                LogStartup("MainWindow activated");
            }
            catch (Exception ex)
            {
                LogStartup($"OnLaunched FATAL ERROR: {ex}");
                throw;
            }
        }

        public static T? GetService<T>() where T : class
        {
            return _serviceProvider?.GetService<T>();
        }

        public static T GetRequiredService<T>() where T : class
        {
            return _serviceProvider!.GetRequiredService<T>();
        }
    }
}
