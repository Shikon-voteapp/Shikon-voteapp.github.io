using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace ShikonSettingApp
{
    public partial class MainWindow : Window
    {
        private readonly MainViewModel _viewModel;

        public MainWindow()
        {
            InitializeComponent();
            _viewModel = DataContext as MainViewModel;
        }

        // 起動時引数を受け取るためのコンストラクタ
        public MainWindow(string folderPath) : this()
        {
            if (_viewModel != null && !string.IsNullOrEmpty(folderPath))
            {
                // UIが完全にロードされた後にパスを設定してデータを読み込む
                this.Loaded += (s, e) => {
                    _viewModel.FolderPath = folderPath;
                };
            }
        }
        protected override void OnClosing(System.ComponentModel.CancelEventArgs e)
        {
            base.OnClosing(e);

            if (_viewModel != null && _viewModel.IsDirty)
            {
                var result = MessageBox.Show(
                    "変更が保存されていません。終了する前に保存しますか？",
                    "確認",
                    MessageBoxButton.YesNoCancel,
                    MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    _viewModel.SaveCommand.Execute(null);
                }
                else if (result == MessageBoxResult.Cancel)
                {
                    // 終了をキャンセルする
                    e.Cancel = true;
                }
            }
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {

        }
    }

    // Nullかどうかをboolに変換するコンバーター (IsEnabled用)
    public class NullToBoolConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture) => value != null;
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture) => throw new NotImplementedException();
    }

    // NullかどうかをVisibilityに変換するコンバーター (表示/非表示の切り替え用)
    public class NullToVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            bool isNull = value == null;
            bool invert = parameter as string == "invert";

            if ((isNull && !invert) || (!isNull && invert))
                return Visibility.Collapsed;

            return Visibility.Visible;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture) => throw new NotImplementedException();
    }
}