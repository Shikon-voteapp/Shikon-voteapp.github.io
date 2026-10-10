using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace ShikonSettingApp
{
    public class CategoryViewModel : INotifyPropertyChanged
    {
        private bool _isSelected;
        private readonly Action<GroupCategory, bool> _updateAction;

        public GroupCategory Category { get; }
        public string Name => Category.ToString();

        public bool IsSelected
        {
            get => _isSelected;
            set
            {
                if (_isSelected != value)
                {
                    _isSelected = value;
                    OnPropertyChanged();
                    _updateAction?.Invoke(Category, _isSelected);
                }
            }
        }

        public CategoryViewModel(GroupCategory category, Action<GroupCategory, bool> updateAction)
        {
            Category = category;
            _updateAction = updateAction;
        }

        // ? を追加
        public event PropertyChangedEventHandler? PropertyChanged;

        protected void OnPropertyChanged([CallerMemberName] string? name = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }
    }
}