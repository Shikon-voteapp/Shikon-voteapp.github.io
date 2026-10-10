using Microsoft.Win32;
using Microsoft.WindowsAPICodePack.Dialogs;
using ShikonSettingApp;
using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Input;

namespace ShikonSettingApp
{
    public class MainViewModel : INotifyPropertyChanged
    {
        private string _folderPath;
        private string _dartFilePath;
        private string _originalDartCode;
        private string _statusMessage = "フォルダを選択してください。";
        private Group _selectedGroup;
        private ObservableCollection<Group> _groups = new ObservableCollection<Group>();
        private VotingPeriodConfig _config = new VotingPeriodConfig();
        private bool _isDirty = false;

        public string FolderPath
        {
            get => _folderPath;
            set { _folderPath = value; OnPropertyChanged(); LoadData(); }
        }

        public string StatusMessage
        {
            get => _statusMessage;
            set { _statusMessage = value; OnPropertyChanged(); }
        }

        private string? _idWarningMessage;
        public string? IdWarningMessage
        {
            get => _idWarningMessage;
            private set
            {
                if (_idWarningMessage != value)
                {
                    _idWarningMessage = value;
                    OnPropertyChanged();
                    OnPropertyChanged(nameof(HasIdWarning));
                }
            }
        }

        public bool HasIdWarning => !string.IsNullOrEmpty(_idWarningMessage);

        private string? _voteCategoryIdWarningMessage;
        public string? VoteCategoryIdWarningMessage
        {
            get => _voteCategoryIdWarningMessage;
            private set
            {
                if (_voteCategoryIdWarningMessage != value)
                {
                    _voteCategoryIdWarningMessage = value;
                    OnPropertyChanged();
                    OnPropertyChanged(nameof(HasVoteCategoryIdWarning));
                }
            }
        }

        public bool HasVoteCategoryIdWarning => !string.IsNullOrEmpty(_voteCategoryIdWarningMessage);

        public ObservableCollection<Group> Groups
        {
            get => _groups;
            set
            {
                if (_groups != null)
                {
                    _groups.CollectionChanged -= Groups_CollectionChanged;
                    foreach (var g in _groups) UnhookGroupEvents(g);
                }
                _groups = value;
                if (_groups != null)
                {
                    _groups.CollectionChanged += Groups_CollectionChanged;
                    foreach (var g in _groups) HookGroupEvents(g);
                }
                OnPropertyChanged();
                ValidateGroupIds();
            }
        }

        private ObservableCollection<VoteCategory> _voteCategories = new ObservableCollection<VoteCategory>();
        public ObservableCollection<VoteCategory> VoteCategories
        {
            get => _voteCategories;
            set
            {
                if (_voteCategories != null)
                {
                    _voteCategories.CollectionChanged -= VoteCategories_CollectionChanged;
                    foreach (var c in _voteCategories) UnhookVoteCategoryEvents(c);
                }
                _voteCategories = value;
                if (_voteCategories != null)
                {
                    _voteCategories.CollectionChanged += VoteCategories_CollectionChanged;
                    foreach (var c in _voteCategories) HookVoteCategoryEvents(c);
                }
                OnPropertyChanged();
                ValidateVoteCategoryIds();
            }
        }

        public static int[] Hours { get; } = Enumerable.Range(0, 24).ToArray();
        public static int[] Minutes { get; } = Enumerable.Range(0, 60).ToArray();

        public VotingPeriodConfig Config
        {
            get => _config;
            set
            {
                if (_config != null)
                {
                    _config.PropertyChanged -= Config_PropertyChanged;
                }
                _config = value;
                if (_config != null)
                {
                    _config.PropertyChanged += Config_PropertyChanged;
                }
                OnPropertyChanged();
            }
        }

        public ObservableCollection<CategoryViewModel> SelectableCategories { get; private set; }
        public ObservableCollection<CategoryViewModel> SelectableVoteCategoryTargets { get; private set; }

        public Group SelectedGroup
        {
            get => _selectedGroup;
            set
            {
                _selectedGroup = value;
                OnPropertyChanged();
                UpdateCategoryViewModels();
                ValidateGroupIds();
            }
        }

        private VoteCategory? _selectedVoteCategory;
        public VoteCategory? SelectedVoteCategory
        {
            get => _selectedVoteCategory;
            set
            {
                _selectedVoteCategory = value;
                OnPropertyChanged();
                UpdateVoteCategoryViewModels();
                ValidateVoteCategoryIds();
            }
        }

        public ICommand SelectFolderCommand { get; }
        public ICommand SaveCommand { get; }
        public ICommand AddGroupCommand { get; }
        public ICommand RemoveGroupCommand { get; }
        public ICommand SelectImageCommand { get; }
        public ICommand AddVoteCategoryCommand { get; }
        public ICommand RemoveVoteCategoryCommand { get; }

        public MainViewModel()
        {
            if (_config != null)
            {
                _config.PropertyChanged += Config_PropertyChanged;
            }
            if (_groups != null)
            {
                _groups.CollectionChanged += Groups_CollectionChanged;
                foreach (var g in _groups) HookGroupEvents(g);
            }
            if (_voteCategories != null)
            {
                _voteCategories.CollectionChanged += VoteCategories_CollectionChanged;
                foreach (var c in _voteCategories) HookVoteCategoryEvents(c);
            }

            SelectFolderCommand = new RelayCommand(SelectFolder);
            SaveCommand = new RelayCommand(SaveFile, CanSave);
            AddGroupCommand = new RelayCommand(AddGroup, CanAddGroup);
            RemoveGroupCommand = new RelayCommand(RemoveGroup, CanRemoveGroup);
            SelectImageCommand = new RelayCommand(SelectImage, CanSelectImage);
            AddVoteCategoryCommand = new RelayCommand(AddVoteCategory, CanAddVoteCategory);
            RemoveVoteCategoryCommand = new RelayCommand(RemoveVoteCategory, CanRemoveVoteCategory);

            PropertyChanged += (s, e) => {
                // SelectedGroupやSelectedVoteCategoryやConfigの変更を検知
                if (e.PropertyName == nameof(SelectedGroup) || 
                    e.PropertyName == nameof(SelectedVoteCategory) || 
                    e.PropertyName == nameof(Config))
                {
                    SetDirty();
                }
            };

            SelectableCategories = new ObservableCollection<CategoryViewModel>();
            SelectableVoteCategoryTargets = new ObservableCollection<CategoryViewModel>();
        }

        private void Groups_CollectionChanged(object? sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            if (e.OldItems != null)
            {
                foreach (Group g in e.OldItems) UnhookGroupEvents(g);
            }
            if (e.NewItems != null)
            {
                foreach (Group g in e.NewItems) HookGroupEvents(g);
            }
            SetDirty();
            ValidateGroupIds();
        }

        private void HookGroupEvents(Group? group)
        {
            if (group != null)
            {
                group.PropertyChanged += Group_PropertyChanged;
            }
        }

        private void UnhookGroupEvents(Group? group)
        {
            if (group != null)
            {
                group.PropertyChanged -= Group_PropertyChanged;
            }
        }

        private void Group_PropertyChanged(object? sender, PropertyChangedEventArgs e)
        {
            SetDirty();
            if (e.PropertyName == nameof(Group.Id))
            {
                ValidateGroupIds();
            }
        }

        public void ValidateGroupIds()
        {
            // 全グループの重複状態を更新
            var idCounts = Groups
                .Where(g => !string.IsNullOrWhiteSpace(g.Id))
                .GroupBy(g => g.Id.Trim())
                .ToDictionary(g => g.Key, g => g.Count());

            foreach (var g in Groups)
            {
                bool isDup = !string.IsNullOrWhiteSpace(g.Id) &&
                             idCounts.TryGetValue(g.Id.Trim(), out int count) &&
                             count > 1;
                g.HasDuplicateId = isDup;
            }

            // 選択中グループの警告メッセージを更新
            if (SelectedGroup == null)
            {
                IdWarningMessage = null;
                return;
            }

            if (string.IsNullOrWhiteSpace(SelectedGroup.Id))
            {
                IdWarningMessage = "⚠️ IDが入力されていません。";
                return;
            }

            var trimmedId = SelectedGroup.Id.Trim();
            var duplicateGroups = Groups
                .Where(g => !ReferenceEquals(g, SelectedGroup) &&
                            string.Equals(g.Id?.Trim(), trimmedId, StringComparison.OrdinalIgnoreCase))
                .ToList();

            if (duplicateGroups.Count > 0)
            {
                var names = string.Join(", ", duplicateGroups.Select(g => string.IsNullOrWhiteSpace(g.Name) ? "(名称未設定)" : $"「{g.Name}」"));
                IdWarningMessage = $"⚠️ ID '{SelectedGroup.Id}' は他の団体 ({names}) と重複しています！";
            }
            else
            {
                IdWarningMessage = null;
            }
        }

        private void VoteCategories_CollectionChanged(object? sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            if (e.OldItems != null)
            {
                foreach (VoteCategory c in e.OldItems) UnhookVoteCategoryEvents(c);
            }
            if (e.NewItems != null)
            {
                foreach (VoteCategory c in e.NewItems) HookVoteCategoryEvents(c);
            }
            SetDirty();
            ValidateVoteCategoryIds();
        }

        private void HookVoteCategoryEvents(VoteCategory? category)
        {
            if (category != null)
            {
                category.PropertyChanged += VoteCategory_PropertyChanged;
            }
        }

        private void UnhookVoteCategoryEvents(VoteCategory? category)
        {
            if (category != null)
            {
                category.PropertyChanged -= VoteCategory_PropertyChanged;
            }
        }

        private void VoteCategory_PropertyChanged(object? sender, PropertyChangedEventArgs e)
        {
            SetDirty();
            if (e.PropertyName == nameof(VoteCategory.Id))
            {
                ValidateVoteCategoryIds();
            }
        }

        public void ValidateVoteCategoryIds()
        {
            var idCounts = VoteCategories
                .Where(c => !string.IsNullOrWhiteSpace(c.Id))
                .GroupBy(c => c.Id.Trim())
                .ToDictionary(c => c.Key, c => c.Count());

            foreach (var c in VoteCategories)
            {
                bool isDup = !string.IsNullOrWhiteSpace(c.Id) &&
                             idCounts.TryGetValue(c.Id.Trim(), out int count) &&
                             count > 1;
                c.HasDuplicateId = isDup;
            }

            if (SelectedVoteCategory == null)
            {
                VoteCategoryIdWarningMessage = null;
                return;
            }

            if (string.IsNullOrWhiteSpace(SelectedVoteCategory.Id))
            {
                VoteCategoryIdWarningMessage = "⚠️ IDが入力されていません。";
                return;
            }

            var trimmedId = SelectedVoteCategory.Id.Trim();
            var duplicateCats = VoteCategories
                .Where(c => !ReferenceEquals(c, SelectedVoteCategory) &&
                            string.Equals(c.Id?.Trim(), trimmedId, StringComparison.OrdinalIgnoreCase))
                .ToList();

            if (duplicateCats.Count > 0)
            {
                var names = string.Join(", ", duplicateCats.Select(c => string.IsNullOrWhiteSpace(c.Name) ? "(名称未設定)" : $"「{c.Name}」"));
                VoteCategoryIdWarningMessage = $"⚠️ ID '{SelectedVoteCategory.Id}' は他の賞 ({names}) と重複しています！";
            }
            else
            {
                VoteCategoryIdWarningMessage = null;
            }
        }

        private void Config_PropertyChanged(object? sender, PropertyChangedEventArgs e)
        {
            SetDirty();
        }

        public void SetDirty()
        {
            if (!_isDirty)
            {
                _isDirty = true;
                OnPropertyChanged(nameof(IsDirty)); // UIに通知
            }
        }

        public bool IsDirty => _isDirty;

        private void UpdateCategoryViewModels()
        {
            SelectableCategories.Clear();
            if (SelectedGroup == null) return;

            foreach (GroupCategory categoryEnum in Enum.GetValues(typeof(GroupCategory)))
            {
                var cvm = new CategoryViewModel(categoryEnum, UpdateModelCategory)
                {
                    IsSelected = SelectedGroup.Categories.Contains(categoryEnum)
                };
                SelectableCategories.Add(cvm);
            }
        }

        private void UpdateModelCategory(GroupCategory category, bool isSelected)
        {
            if (SelectedGroup == null) return;

            if (isSelected && !SelectedGroup.Categories.Contains(category))
            {
                SelectedGroup.Categories.Add(category);
                SetDirty();
            }
            else if (!isSelected && SelectedGroup.Categories.Contains(category))
            {
                SelectedGroup.Categories.Remove(category);
                SetDirty();
            }
        }

        private void UpdateVoteCategoryViewModels()
        {
            SelectableVoteCategoryTargets.Clear();
            if (SelectedVoteCategory == null) return;

            foreach (GroupCategory categoryEnum in Enum.GetValues(typeof(GroupCategory)))
            {
                var cvm = new CategoryViewModel(categoryEnum, UpdateModelVoteCategoryTarget)
                {
                    IsSelected = SelectedVoteCategory.TargetCategories.Contains(categoryEnum)
                };
                SelectableVoteCategoryTargets.Add(cvm);
            }
        }

        private void UpdateModelVoteCategoryTarget(GroupCategory category, bool isSelected)
        {
            if (SelectedVoteCategory == null) return;

            if (isSelected && !SelectedVoteCategory.TargetCategories.Contains(category))
            {
                SelectedVoteCategory.TargetCategories.Add(category);
                SetDirty();
            }
            else if (!isSelected && SelectedVoteCategory.TargetCategories.Contains(category))
            {
                SelectedVoteCategory.TargetCategories.Remove(category);
                SetDirty();
            }
        }

        private void SelectFolder(object obj)
        {
            var dialog = new CommonOpenFileDialog { IsFolderPicker = true, Title = "vote_options.dartが含まれるフォルダを選択" };
            if (dialog.ShowDialog() == CommonFileDialogResult.Ok) FolderPath = dialog.FileName;
        }

        private void LoadData()
        {
            _dartFilePath = Path.Combine(FolderPath, "lib", "config", "vote_options.dart");
            if (!File.Exists(_dartFilePath))
            {
                StatusMessage = "エラー: vote_options.dart が見つかりません。";
                Groups.Clear();
                VoteCategories.Clear();
                Config = new VotingPeriodConfig();
                _originalDartCode = null;
                return;
            }

            try
            {
                _originalDartCode = File.ReadAllText(_dartFilePath);
                var voteData = DartParser.Parse(_originalDartCode);

                Config = voteData.Config;
                Groups = new ObservableCollection<Group>(voteData.AllGroups);
                VoteCategories = new ObservableCollection<VoteCategory>(voteData.VoteCategories);
                SelectedGroup = Groups.FirstOrDefault();
                SelectedVoteCategory = VoteCategories.FirstOrDefault();
                StatusMessage = $"読込完了: 団体 {Groups.Count}件、賞 {VoteCategories.Count}件のデータを読み込みました。";
            }
            catch (Exception ex)
            {
                StatusMessage = $"エラー: ファイルの解析に失敗しました。 {ex.Message}";
                _originalDartCode = null;
            }
        }

        private bool CanSave(object obj) => !string.IsNullOrEmpty(_originalDartCode);
        private void SaveFile(object obj)
        {
            if (!CanSave(null)) return;

            var duplicateGroups = Groups
                .Where(g => !string.IsNullOrWhiteSpace(g.Id))
                .GroupBy(g => g.Id.Trim())
                .Where(g => g.Count() > 1)
                .Select(g => g.Key)
                .ToList();

            if (duplicateGroups.Count > 0)
            {
                var message = $"以下の団体のIDが重複しています：\n\n・{string.Join("\n・", duplicateGroups)}\n\n重複したまま保存しますか？";
                var result = MessageBox.Show(message, "団体ID重複の警告", MessageBoxButton.YesNo, MessageBoxImage.Warning);
                if (result != MessageBoxResult.Yes)
                {
                    StatusMessage = "保存が中断されました（団体IDが重複しています）。";
                    return;
                }
            }

            var duplicateCats = VoteCategories
                .Where(c => !string.IsNullOrWhiteSpace(c.Id))
                .GroupBy(c => c.Id.Trim())
                .Where(g => g.Count() > 1)
                .Select(g => g.Key)
                .ToList();

            if (duplicateCats.Count > 0)
            {
                var message = $"以下の賞のIDが重複しています：\n\n・{string.Join("\n・", duplicateCats)}\n\n重複したまま保存しますか？";
                var result = MessageBox.Show(message, "賞ID重複の警告", MessageBoxButton.YesNo, MessageBoxImage.Warning);
                if (result != MessageBoxResult.Yes)
                {
                    StatusMessage = "保存が中断されました（賞IDが重複しています）。";
                    return;
                }
            }

            var voteData = new VoteData 
            { 
                Config = this.Config, 
                AllGroups = this.Groups.ToList(),
                VoteCategories = this.VoteCategories.ToList()
            };

            try
            {
                string updatedCode = DartWriter.Write(_originalDartCode, voteData);
                File.WriteAllText(_dartFilePath, updatedCode);
                StatusMessage = $"保存完了: {DateTime.Now:HH:mm:ss} にファイルを保存しました。";
                _originalDartCode = updatedCode;
                _isDirty = false;
                OnPropertyChanged(nameof(IsDirty));
            }
            catch (Exception ex)
            {
                StatusMessage = $"エラー: ファイルの保存に失敗しました。{ex.Message}";
            }
        }

        private bool CanAddGroup(object obj) => !string.IsNullOrEmpty(_folderPath);
        private void AddGroup(object obj)
        {
            var newGroup = new Group { Id = $"new_{DateTime.Now.Ticks}", Name = "新しい団体" };
            Groups.Add(newGroup);
            SelectedGroup = newGroup;
        }

        private bool CanRemoveGroup(object obj) => SelectedGroup != null;
        private void RemoveGroup(object obj)
        {
            if (SelectedGroup != null)
            {
                Groups.Remove(SelectedGroup);
                SelectedGroup = Groups.FirstOrDefault();
            }
        }

        private bool CanAddVoteCategory(object obj) => !string.IsNullOrEmpty(_folderPath);
        private void AddVoteCategory(object obj)
        {
            var newCategory = new VoteCategory { Id = $"award_{DateTime.Now.Ticks}", Name = "新しい賞" };
            VoteCategories.Add(newCategory);
            SelectedVoteCategory = newCategory;
        }

        private bool CanRemoveVoteCategory(object obj) => SelectedVoteCategory != null;
        private void RemoveVoteCategory(object obj)
        {
            if (SelectedVoteCategory != null)
            {
                VoteCategories.Remove(SelectedVoteCategory);
                SelectedVoteCategory = VoteCategories.FirstOrDefault();
            }
        }

        private bool CanSelectImage(object obj) => SelectedGroup != null;
        private void SelectImage(object obj)
        {
            if (SelectedGroup == null) return;

            string assetsPath = Path.GetFullPath(Path.Combine(FolderPath, "..", "..", "assets"));
            if (!Directory.Exists(assetsPath))
            {
                MessageBox.Show($"assetsフォルダが見つかりません。\n期待したパス: {assetsPath}", "エラー", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            var dialog = new OpenFileDialog
            {
                Filter = "画像ファイル (*.jpg;*.jpeg;*.png;*.gif)|*.jpg;*.jpeg;*.png;*.gif",
                InitialDirectory = assetsPath,
                Title = "画像を選択"
            };

            if (dialog.ShowDialog() == true)
            {
                Uri fileUri = new Uri(dialog.FileName);
                Uri assetsUri = new Uri(assetsPath + Path.DirectorySeparatorChar);
                string relativePath = Uri.UnescapeDataString(assetsUri.MakeRelativeUri(fileUri).ToString());
                SelectedGroup.ImagePath = $"assets/{relativePath}";
                OnPropertyChanged(nameof(SelectedGroup));
                OnPropertyChanged(nameof(Groups)); // Force update if ImagePath is bound in a list
            }
        }

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string name = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }
    }
}