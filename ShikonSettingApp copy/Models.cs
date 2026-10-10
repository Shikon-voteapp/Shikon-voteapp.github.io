using System;
using System.Collections.Generic;

// このファイルは vote_options.dart のデータ構造をC#で表現します。

namespace ShikonSettingApp
{
    /// <summary>
    /// DartのGroupCategory enumに対応します。
    /// </summary>
    public enum GroupCategory
    {
        Tenji,
        Moyoshi,
        Gakunen,
        Roten,
        Stage,
        Performance,
        Band,
        other
    }

    /// <summary>
    /// 投票期間の設定を保持します。
    /// </summary>
    public class VotingPeriodConfig : System.ComponentModel.INotifyPropertyChanged
    {
        private DateTime _startDate = DateTime.Now;
        private DateTime _endDate = DateTime.Now.AddDays(1);
        private bool _maintenanceEnabled = true;
        private int _maintenanceStartHour = 1;
        private int _maintenanceStartMinute = 0;
        private int _maintenanceEndHour = 2;
        private int _maintenanceEndMinute = 0;

        public DateTime StartDate
        {
            get => _startDate;
            set
            {
                if (_startDate != value)
                {
                    _startDate = value;
                    OnPropertyChanged();
                    OnPropertyChanged(nameof(StartDateOnly));
                    OnPropertyChanged(nameof(StartHour));
                    OnPropertyChanged(nameof(StartMinute));
                }
            }
        }

        public DateTime? StartDateOnly
        {
            get => _startDate.Date;
            set
            {
                if (value.HasValue)
                {
                    var d = value.Value;
                    StartDate = new DateTime(d.Year, d.Month, d.Day, _startDate.Hour, _startDate.Minute, _startDate.Second);
                }
            }
        }

        public int StartHour
        {
            get => _startDate.Hour;
            set
            {
                if (value >= 0 && value <= 23 && _startDate.Hour != value)
                {
                    StartDate = new DateTime(_startDate.Year, _startDate.Month, _startDate.Day, value, _startDate.Minute, _startDate.Second);
                }
            }
        }

        public int StartMinute
        {
            get => _startDate.Minute;
            set
            {
                if (value >= 0 && value <= 59 && _startDate.Minute != value)
                {
                    StartDate = new DateTime(_startDate.Year, _startDate.Month, _startDate.Day, _startDate.Hour, value, _startDate.Second);
                }
            }
        }

        public DateTime EndDate
        {
            get => _endDate;
            set
            {
                if (_endDate != value)
                {
                    _endDate = value;
                    OnPropertyChanged();
                    OnPropertyChanged(nameof(EndDateOnly));
                    OnPropertyChanged(nameof(EndHour));
                    OnPropertyChanged(nameof(EndMinute));
                }
            }
        }

        public DateTime? EndDateOnly
        {
            get => _endDate.Date;
            set
            {
                if (value.HasValue)
                {
                    var d = value.Value;
                    EndDate = new DateTime(d.Year, d.Month, d.Day, _endDate.Hour, _endDate.Minute, _endDate.Second);
                }
            }
        }

        public int EndHour
        {
            get => _endDate.Hour;
            set
            {
                if (value >= 0 && value <= 23 && _endDate.Hour != value)
                {
                    EndDate = new DateTime(_endDate.Year, _endDate.Month, _endDate.Day, value, _endDate.Minute, _endDate.Second);
                }
            }
        }

        public int EndMinute
        {
            get => _endDate.Minute;
            set
            {
                if (value >= 0 && value <= 59 && _endDate.Minute != value)
                {
                    EndDate = new DateTime(_endDate.Year, _endDate.Month, _endDate.Day, _endDate.Hour, value, _endDate.Second);
                }
            }
        }

        public bool MaintenanceEnabled
        {
            get => _maintenanceEnabled;
            set
            {
                if (_maintenanceEnabled != value)
                {
                    _maintenanceEnabled = value;
                    OnPropertyChanged();
                }
            }
        }

        public int MaintenanceStartHour
        {
            get => _maintenanceStartHour;
            set
            {
                int val = Math.Clamp(value, 0, 23);
                if (_maintenanceStartHour != val)
                {
                    _maintenanceStartHour = val;
                    OnPropertyChanged();
                }
            }
        }

        public int MaintenanceStartMinute
        {
            get => _maintenanceStartMinute;
            set
            {
                int val = Math.Clamp(value, 0, 59);
                if (_maintenanceStartMinute != val)
                {
                    _maintenanceStartMinute = val;
                    OnPropertyChanged();
                }
            }
        }

        public int MaintenanceEndHour
        {
            get => _maintenanceEndHour;
            set
            {
                int val = Math.Clamp(value, 0, 23);
                if (_maintenanceEndHour != val)
                {
                    _maintenanceEndHour = val;
                    OnPropertyChanged();
                }
            }
        }

        public int MaintenanceEndMinute
        {
            get => _maintenanceEndMinute;
            set
            {
                int val = Math.Clamp(value, 0, 59);
                if (_maintenanceEndMinute != val)
                {
                    _maintenanceEndMinute = val;
                    OnPropertyChanged();
                }
            }
        }

        public event System.ComponentModel.PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([System.Runtime.CompilerServices.CallerMemberName] string name = null)
        {
            PropertyChanged?.Invoke(this, new System.ComponentModel.PropertyChangedEventArgs(name));
        }
    }

    /// <summary>
    /// 団体の情報を保持します。
    /// </summary>
    public class Group : System.ComponentModel.INotifyPropertyChanged
    {
        private string _id = string.Empty;
        private string _name = string.Empty;
        private string _groupName = string.Empty;
        private string _description = string.Empty;
        private string _imagePath = string.Empty;
        private int _floor;
        private List<GroupCategory> _categories = new List<GroupCategory>();
        private bool _hasDuplicateId;

        public string Id
        {
            get => _id;
            set
            {
                if (_id != value)
                {
                    _id = value;
                    OnPropertyChanged();
                }
            }
        }

        public string Name
        {
            get => _name;
            set
            {
                if (_name != value)
                {
                    _name = value;
                    OnPropertyChanged();
                }
            }
        }

        public string GroupName
        {
            get => _groupName;
            set
            {
                if (_groupName != value)
                {
                    _groupName = value;
                    OnPropertyChanged();
                }
            }
        }

        public string Description
        {
            get => _description;
            set
            {
                if (_description != value)
                {
                    _description = value;
                    OnPropertyChanged();
                }
            }
        }

        public string ImagePath
        {
            get => _imagePath;
            set
            {
                if (_imagePath != value)
                {
                    _imagePath = value;
                    OnPropertyChanged();
                }
            }
        }

        public int Floor
        {
            get => _floor;
            set
            {
                if (_floor != value)
                {
                    _floor = value;
                    OnPropertyChanged();
                }
            }
        }

        public List<GroupCategory> Categories
        {
            get => _categories;
            set
            {
                if (_categories != value)
                {
                    _categories = value;
                    OnPropertyChanged();
                }
            }
        }

        public bool HasDuplicateId
        {
            get => _hasDuplicateId;
            set
            {
                if (_hasDuplicateId != value)
                {
                    _hasDuplicateId = value;
                    OnPropertyChanged();
                }
            }
        }

        public event System.ComponentModel.PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([System.Runtime.CompilerServices.CallerMemberName] string name = null)
        {
            PropertyChanged?.Invoke(this, new System.ComponentModel.PropertyChangedEventArgs(name));
        }
    }
    public class VoteCategory : System.ComponentModel.INotifyPropertyChanged
    {
        private string _id = string.Empty;
        private string _name = string.Empty;
        private string _description = string.Empty;
        private string _shortHelpText = string.Empty;
        private string _helpUrl = string.Empty;
        private bool _canSkip = false;
        private List<GroupCategory> _targetCategories = new List<GroupCategory>();
        private bool _hasDuplicateId;

        public string Id
        {
            get => _id;
            set
            {
                if (_id != value)
                {
                    _id = value;
                    OnPropertyChanged();
                }
            }
        }

        public string Name
        {
            get => _name;
            set
            {
                if (_name != value)
                {
                    _name = value;
                    OnPropertyChanged();
                }
            }
        }

        public string Description
        {
            get => _description;
            set
            {
                if (_description != value)
                {
                    _description = value;
                    OnPropertyChanged();
                }
            }
        }

        public string ShortHelpText
        {
            get => _shortHelpText;
            set
            {
                if (_shortHelpText != value)
                {
                    _shortHelpText = value;
                    OnPropertyChanged();
                }
            }
        }

        public string HelpUrl
        {
            get => _helpUrl;
            set
            {
                if (_helpUrl != value)
                {
                    _helpUrl = value;
                    OnPropertyChanged();
                }
            }
        }

        public bool CanSkip
        {
            get => _canSkip;
            set
            {
                if (_canSkip != value)
                {
                    _canSkip = value;
                    OnPropertyChanged();
                }
            }
        }

        public List<GroupCategory> TargetCategories
        {
            get => _targetCategories;
            set
            {
                if (_targetCategories != value)
                {
                    _targetCategories = value;
                    OnPropertyChanged();
                }
            }
        }

        public bool HasDuplicateId
        {
            get => _hasDuplicateId;
            set
            {
                if (_hasDuplicateId != value)
                {
                    _hasDuplicateId = value;
                    OnPropertyChanged();
                }
            }
        }

        public event System.ComponentModel.PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([System.Runtime.CompilerServices.CallerMemberName] string name = null)
        {
            PropertyChanged?.Invoke(this, new System.ComponentModel.PropertyChangedEventArgs(name));
        }
    }

    /// <summary>
    /// vote_options.dartファイル全体のデータをまとめるクラスです。
    /// </summary>
    public class VoteData
    {
        public VotingPeriodConfig Config { get; set; } = new VotingPeriodConfig();
        public List<Group> AllGroups { get; set; } = new List<Group>();
        public List<VoteCategory> VoteCategories { get; set; } = new List<VoteCategory>();
    }
}