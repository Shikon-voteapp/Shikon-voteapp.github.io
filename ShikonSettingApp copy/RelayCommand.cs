using System;
using System.Windows.Input;

namespace ShikonSettingApp
{
    public class RelayCommand : ICommand
    {
        private readonly Action<object?> _execute;
        private readonly Predicate<object?>? _canExecute;

        // EventHandler? のように ? を追加
        public event EventHandler? CanExecuteChanged
        {
            add => CommandManager.RequerySuggested += value;
            remove => CommandManager.RequerySuggested -= value;
        }

        public RelayCommand(Action<object?> execute, Predicate<object?>? canExecute = null)
        {
            _execute = execute ?? throw new ArgumentNullException(nameof(execute));
            _canExecute = canExecute;
        }

        // object? のように ? を追加
        public bool CanExecute(object? parameter) => _canExecute?.Invoke(parameter) ?? true;

        // object? のように ? を追加
        public void Execute(object? parameter) => _execute(parameter);
    }
}