using System.Windows;

namespace ShikonSettingApp
{
    public partial class App : Application
    {
        private void Application_Startup(object sender, StartupEventArgs e)
        {
            string initialFolder = null;
            if (e.Args.Length > 0)
            {
                // コマンドライン引数からフォルダパスを取得
                initialFolder = e.Args[0];
            }

            // ViewModelにパスを渡してMainWindowを起動
            var mainWindow = new MainWindow(initialFolder);
            mainWindow.Show();
        }
    }
}