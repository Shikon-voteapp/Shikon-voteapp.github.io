using ShikonSettingApp;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace ShikonSettingApp
{
    /// <summary>
    /// C#オブジェクトからDartコードの文字列を生成し、ファイルに書き込むクラスです。
    /// </summary>
    public static class DartWriter
    {
        private static readonly Regex ConfigRegex = new Regex(@"final VotingPeriodConfig defaultVotingPeriod = VotingPeriodConfig\(.*?\);", RegexOptions.Singleline | RegexOptions.Compiled);
        private static readonly Regex AllGroupsRegex = new Regex(@"final List<Group> allGroups = \[.*?\];", RegexOptions.Singleline | RegexOptions.Compiled);
        private static readonly Regex VoteCategoriesRegex = new Regex(@"final List<VoteCategory> voteCategories = \[.*?\];", RegexOptions.Singleline | RegexOptions.Compiled);

        /// <summary>
        /// 編集後のVoteDataオブジェクトを元に、元のDartコードを更新して返します。
        /// </summary>
        public static string Write(string originalDartCode, VoteData voteData)
        {
            string newConfigCode = GenerateConfigCode(voteData.Config);
            string newGroupsCode = GenerateGroupsCode(voteData.AllGroups);
            string newCategoriesCode = GenerateVoteCategoriesCode(voteData.VoteCategories);

            string updatedCode = ConfigRegex.Replace(originalDartCode, newConfigCode);
            updatedCode = AllGroupsRegex.Replace(updatedCode, newGroupsCode);
            updatedCode = VoteCategoriesRegex.Replace(updatedCode, newCategoriesCode);

            return updatedCode;
        }

        private static string GenerateConfigCode(VotingPeriodConfig config)
        {
            var sb = new StringBuilder();
            sb.AppendLine("final VotingPeriodConfig defaultVotingPeriod = VotingPeriodConfig(");
            sb.AppendLine($"  startDate: DateTime({config.StartDate:yyyy, M, d, H, m}), // {config.StartDate:yyyy年M月d日 H:mm}");
            sb.AppendLine($"  endDate: DateTime({config.EndDate:yyyy, M, d, H, m}), // {config.EndDate:yyyy年M月d日 H:mm}");
            sb.AppendLine($"  maintenanceEnabled: {config.MaintenanceEnabled.ToString().ToLower()},");
            sb.AppendLine($"  maintenanceStartHour: {config.MaintenanceStartHour},");
            sb.AppendLine($"  maintenanceStartMinute: {config.MaintenanceStartMinute},");
            sb.AppendLine($"  maintenanceEndHour: {config.MaintenanceEndHour},");
            sb.AppendLine($"  maintenanceEndMinute: {config.MaintenanceEndMinute},");
            sb.Append(");");
            return sb.ToString();
        }

        private static string GenerateGroupsCode(System.Collections.Generic.List<Group> groups)
        {
            var sb = new StringBuilder();
            sb.AppendLine("final List<Group> allGroups = [");

            for (int i = 0; i < groups.Count; i++)
            {
                var group = groups[i];
                sb.AppendLine("  Group(");
                sb.AppendLine($"    id: '{EscapeSingleQuotes(group.Id)}',");
                sb.AppendLine($"    name: '{EscapeSingleQuotes(group.Name)}',");
                sb.AppendLine($"    groupName: '{EscapeSingleQuotes(group.GroupName)}',");
                sb.AppendLine($"    description: '''{EscapeTripleQuotes(group.Description)}''',");
                sb.AppendLine($"    imagePath: '{group.ImagePath.Replace("\\", "/")}',");
                sb.AppendLine($"    floor: {group.Floor},");

                string categories = string.Join(", ", group.Categories.Select(c => $"GroupCategory.{c}"));
                sb.AppendLine($"    categories: [{categories}],");

                sb.Append("  )");
                if (i < groups.Count - 1) sb.Append(",");
                sb.AppendLine();
            }

            sb.Append("];");
            return sb.ToString();
        }

        private static string GenerateVoteCategoriesCode(System.Collections.Generic.List<VoteCategory> categories)
        {
            var sb = new StringBuilder();
            sb.AppendLine("final List<VoteCategory> voteCategories = [");

            for (int i = 0; i < categories.Count; i++)
            {
                var cat = categories[i];
                sb.AppendLine("  VoteCategory(");
                sb.AppendLine($"    id: '{EscapeSingleQuotes(cat.Id)}',");
                sb.AppendLine($"    name: '{EscapeSingleQuotes(cat.Name)}',");
                sb.AppendLine($"    description: '''{EscapeTripleQuotes(cat.Description)}''',");
                if (!string.IsNullOrWhiteSpace(cat.ShortHelpText))
                {
                    sb.AppendLine($"    shortHelpText: '''{EscapeTripleQuotes(cat.ShortHelpText)}''',");
                }

                if (cat.TargetCategories == null || cat.TargetCategories.Count == 0)
                {
                    sb.AppendLine("    groups: allGroups,");
                }
                else if (cat.TargetCategories.Count == 1)
                {
                    sb.AppendLine("    groups:");
                    sb.AppendLine($"        allGroups.where((group) => group.categories.contains(GroupCategory.{cat.TargetCategories[0]})).toList(),");
                }
                else
                {
                    sb.AppendLine("    groups:");
                    sb.AppendLine("        allGroups");
                    sb.AppendLine("            .where(");
                    sb.AppendLine("              (group) =>");
                    var conditions = cat.TargetCategories.Select(c => $"                  group.categories.contains(GroupCategory.{c})");
                    sb.AppendLine(string.Join(" ||\n", conditions) + ",");
                    sb.AppendLine("            )");
                    sb.AppendLine("            .toList(),");
                }

                if (!string.IsNullOrWhiteSpace(cat.HelpUrl))
                {
                    sb.AppendLine($"    helpUrl: '{EscapeSingleQuotes(cat.HelpUrl)}',");
                }

                if (cat.CanSkip)
                {
                    sb.AppendLine("    canSkip: true,");
                }

                sb.Append("  )");
                if (i < categories.Count - 1) sb.Append(",");
                sb.AppendLine();
            }

            sb.Append("];");
            return sb.ToString();
        }

        private static string EscapeSingleQuotes(string value) => value?.Replace("'", "\\'") ?? "";
        private static string EscapeTripleQuotes(string value) => value?.Replace("'''", "''\\\'") ?? "";
    }
}