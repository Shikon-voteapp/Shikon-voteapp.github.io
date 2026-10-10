using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace ShikonSettingApp
{
    /// <summary>
    /// vote_options.dart ファイルを解析するクラスです。
    /// </summary>
    public static class DartParser
    {
        // 正規表現は複数行にまたがるブロックを効率的に見つけるためにSinglelineオプションを使用します。
        private static readonly Regex ConfigRegex = new Regex(@"final VotingPeriodConfig defaultVotingPeriod = VotingPeriodConfig\((.*?)\);", RegexOptions.Singleline | RegexOptions.Compiled);
        private static readonly Regex AllGroupsRegex = new Regex(@"final List<Group> allGroups = \[(.*?)\];", RegexOptions.Singleline | RegexOptions.Compiled);
        private static readonly Regex VoteCategoriesRegex = new Regex(@"final List<VoteCategory> voteCategories = \[(.*?)\];", RegexOptions.Singleline | RegexOptions.Compiled);
        private static readonly Regex GroupRegex = new Regex(@"Group\((.*?)\)", RegexOptions.Singleline | RegexOptions.Compiled);

        /// <summary>
        /// Dartファイルのテキストコンテンツを解析し、VoteDataオブジェクトを返します。
        /// </summary>
        public static VoteData Parse(string dartCode)
        {
            var voteData = new VoteData
            {
                Config = ParseConfig(dartCode),
                AllGroups = ParseGroups(dartCode),
                VoteCategories = ParseVoteCategories(dartCode)
            };
            return voteData;
        }

        private static VotingPeriodConfig ParseConfig(string dartCode)
        {
            var config = new VotingPeriodConfig();
            var match = ConfigRegex.Match(dartCode);
            if (!match.Success) return config;

            string content = match.Groups[1].Value;

            var startDateMatch = Regex.Match(content, @"startDate:\s*DateTime\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d+))?(?:,\s*(\d+))?\)");
            if (startDateMatch.Success)
            {
                int year = int.Parse(startDateMatch.Groups[1].Value);
                int month = int.Parse(startDateMatch.Groups[2].Value);
                int day = int.Parse(startDateMatch.Groups[3].Value);
                int hour = startDateMatch.Groups[4].Success ? int.Parse(startDateMatch.Groups[4].Value) : 0;
                int minute = startDateMatch.Groups[5].Success ? int.Parse(startDateMatch.Groups[5].Value) : 0;
                config.StartDate = new DateTime(year, month, day, hour, minute, 0);
            }

            var endDateMatch = Regex.Match(content, @"endDate:\s*DateTime\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d+))?(?:,\s*(\d+))?\)");
            if (endDateMatch.Success)
            {
                int year = int.Parse(endDateMatch.Groups[1].Value);
                int month = int.Parse(endDateMatch.Groups[2].Value);
                int day = int.Parse(endDateMatch.Groups[3].Value);
                int hour = endDateMatch.Groups[4].Success ? int.Parse(endDateMatch.Groups[4].Value) : 0;
                int minute = endDateMatch.Groups[5].Success ? int.Parse(endDateMatch.Groups[5].Value) : 0;
                config.EndDate = new DateTime(year, month, day, hour, minute, 0);
            }

            config.MaintenanceEnabled = ExtractValue(content, "maintenanceEnabled", bool.Parse, true);
            config.MaintenanceStartHour = ExtractValue(content, "maintenanceStartHour", int.Parse, 1);
            config.MaintenanceStartMinute = ExtractValue(content, "maintenanceStartMinute", int.Parse, 0);
            config.MaintenanceEndHour = ExtractValue(content, "maintenanceEndHour", int.Parse, 2);
            config.MaintenanceEndMinute = ExtractValue(content, "maintenanceEndMinute", int.Parse, 0);

            return config;
        }

        private static List<Group> ParseGroups(string dartCode)
        {
            var groups = new List<Group>();
            var listMatch = AllGroupsRegex.Match(dartCode);
            if (!listMatch.Success) return groups;

            string listContent = listMatch.Groups[1].Value;
            var groupMatches = GroupRegex.Matches(listContent);

            foreach (Match match in groupMatches)
            {
                string content = match.Groups[1].Value;
                var group = new Group
                {
                    Id = ExtractStringValue(content, "id"),
                    Name = ExtractStringValue(content, "name"),
                    GroupName = ExtractStringValue(content, "groupName"),
                    Description = ExtractStringValue(content, "description", isMultiLine: true),
                    ImagePath = ExtractStringValue(content, "imagePath"),
                    Floor = ExtractValue(content, "floor", int.Parse, 0),
                    Categories = ParseCategories(content)
                };
                groups.Add(group);
            }
            return groups;
        }

        private static List<GroupCategory> ParseCategories(string groupContent)
        {
            var categories = new List<GroupCategory>();
            var match = Regex.Match(groupContent, @"categories: \[(.*?)\]", RegexOptions.Singleline);
            if (!match.Success) return categories;

            string categoriesContent = match.Groups[1].Value;
            var categoryMatches = Regex.Matches(categoriesContent, @"GroupCategory\.(\w+)");

            foreach (Match catMatch in categoryMatches)
            {
                if (Enum.TryParse<GroupCategory>(catMatch.Groups[1].Value, true, out var category))
                {
                    categories.Add(category);
                }
            }
            return categories;
        }

        private static List<VoteCategory> ParseVoteCategories(string dartCode)
        {
            var categories = new List<VoteCategory>();
            var listMatch = VoteCategoriesRegex.Match(dartCode);
            if (!listMatch.Success) return categories;

            string listContent = listMatch.Groups[1].Value;
            var blocks = ExtractVoteCategoryBlocks(listContent);

            foreach (string content in blocks)
            {
                var category = new VoteCategory
                {
                    Id = ExtractStringValue(content, "id"),
                    Name = ExtractStringValue(content, "name"),
                    Description = ExtractStringValue(content, "description"),
                    ShortHelpText = ExtractStringValue(content, "shortHelpText"),
                    HelpUrl = ExtractStringValue(content, "helpUrl"),
                    CanSkip = ExtractValue(content, "canSkip", bool.Parse, false),
                    TargetCategories = ParseTargetCategories(content)
                };
                categories.Add(category);
            }

            return categories;
        }

        private static List<string> ExtractVoteCategoryBlocks(string listContent)
        {
            var blocks = new List<string>();
            int index = 0;
            while (index < listContent.Length)
            {
                int start = listContent.IndexOf("VoteCategory(", index, StringComparison.Ordinal);
                if (start == -1) break;

                int openParen = start + "VoteCategory".Length;
                int depth = 0;
                int end = -1;
                for (int i = openParen; i < listContent.Length; i++)
                {
                    if (listContent[i] == '(') depth++;
                    else if (listContent[i] == ')')
                    {
                        depth--;
                        if (depth == 0)
                        {
                            end = i;
                            break;
                        }
                    }
                }

                if (end != -1)
                {
                    blocks.Add(listContent.Substring(openParen + 1, end - openParen - 1));
                    index = end + 1;
                }
                else
                {
                    break;
                }
            }
            return blocks;
        }

        private static List<GroupCategory> ParseTargetCategories(string content)
        {
            var result = new List<GroupCategory>();
            var groupsMatch = Regex.Match(content, @"groups:\s*(.*?)(?:,\s*\w+:|$)", RegexOptions.Singleline);
            string searchIn = groupsMatch.Success ? groupsMatch.Groups[1].Value : content;

            var matches = Regex.Matches(searchIn, @"GroupCategory\.(\w+)");
            foreach (Match m in matches)
            {
                if (Enum.TryParse<GroupCategory>(m.Groups[1].Value, true, out var cat))
                {
                    if (!result.Contains(cat))
                    {
                        result.Add(cat);
                    }
                }
            }
            return result;
        }

        private static string ExtractStringValue(string text, string key, bool isMultiLine = false)
        {
            var multiMatch = Regex.Match(text, $@"{key}:\s*'''(.*?)'''", RegexOptions.Singleline);
            if (multiMatch.Success) return multiMatch.Groups[1].Value.Trim();

            var singleMatch = Regex.Match(text, $@"{key}:\s*'(.*?)'", RegexOptions.Singleline);
            if (singleMatch.Success) return singleMatch.Groups[1].Value.Trim();

            return string.Empty;
        }

        private static T ExtractValue<T>(string text, string key, Func<string, T> converter, T defaultValue)
        {
            var match = Regex.Match(text, $@"{key}:\s*([\w\.]+)");
            if (match.Success)
            {
                try { return converter(match.Groups[1].Value); }
                catch { return defaultValue; }
            }
            return defaultValue;
        }
    }
}