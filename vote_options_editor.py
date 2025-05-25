import customtkinter as ctk
import json
import os
from tkinter import filedialog, messagebox, font
from typing import List, Dict, Any
import re

# 共通フォント定義
try:
    COMMON_FONT = ("Yu Gothic UI", 12)
    TITLE_FONT = ("Yu Gothic UI", 24, "bold")
except Exception:
    COMMON_FONT = ("Meiryo", 12)
    TITLE_FONT = ("Meiryo", 24, "bold")

class Group:
    def __init__(self, id: str, name: str, description: str, image_path: str, floor: int, categories: List[str]):
        self.id = id
        self.name = name
        self.description = description
        self.image_path = image_path
        self.floor = floor
        self.categories = categories

    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'image_path': self.image_path,
            'floor': self.floor,
            'categories': self.categories
        }

class VoteCategory:
    def __init__(self, id: str, name: str, description: str, groups: List[Group], eligible_categories: List[str]):
        self.id = id
        self.name = name
        self.description = description
        self.groups = groups
        self.eligible_categories = eligible_categories

    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'groups': [g.to_dict() for g in self.groups],
            'eligible_categories': self.eligible_categories
        }

def generate_dart_code(groups: List[Group], categories: List[VoteCategory]) -> str:
    dart_code = """import 'package:shikon_voteapp/models/group.dart';

// config/vote_options.dart
/*
=======投票先一覧を設定する設定ファイル=======
*/

// すべての団体のリスト
final List<Group> allGroups = [
"""
    for group in groups:
        dart_code += f"""  Group(
    id: '{group.id}',
    name: '{group.name}',
    description: '{group.description}',
    imagePath: '{group.image_path}',
    floor: {group.floor},
    categories: [{', '.join([f'GroupCategory.{cat}' for cat in group.categories])}],
  ),
"""
    dart_code += """\n];

final List<VoteCategory> voteCategories = [
"""
    for category in categories:
        if not category.eligible_categories:
            groups_expr = 'allGroups'
        else:
            filter_expr = ' || '.join([
                f'group.categories.contains(GroupCategory.{cat})' for cat in category.eligible_categories
            ])
            groups_expr = f'allGroups.where((group) => {filter_expr}).toList()'
        dart_code += f"""  VoteCategory(
    id: '{category.id}',
    name: '{category.name}',
    description: '{category.description}',
    groups: {groups_expr},
    eligibleCategories: [{', '.join([f'GroupCategory.{cat}' for cat in category.eligible_categories])}],
  ),
"""
    dart_code += """\n];"""
    return dart_code

def parse_dart_file(file_path: str):
    # DartファイルからGroupとVoteCategoryを抽出する簡易パーサー
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Group抽出
    group_pattern = re.compile(r"Group\((.*?)\),", re.DOTALL)
    groups = []
    for match in group_pattern.finditer(content):
        block = match.group(1)
        id_ = re.search(r"id: '([^']+)'", block)
        name = re.search(r"name: '([^']+)'", block)
        description = re.search(r"description: '([^']+)'", block)
        image_path = re.search(r"imagePath: '([^']+)'", block)
        floor = re.search(r"floor: (\d+)", block)
        categories = re.findall(r"GroupCategory\.([A-Za-z_]+)", block)
        if id_ and name and description and image_path and floor:
            groups.append(Group(
                id=id_.group(1),
                name=name.group(1),
                description=description.group(1),
                image_path=image_path.group(1),
                floor=int(floor.group(1)),
                categories=categories
            ))
    # VoteCategory抽出
    category_pattern = re.compile(r"VoteCategory\((.*?)\),", re.DOTALL)
    categories = []
    for match in category_pattern.finditer(content):
        block = match.group(1)
        id_ = re.search(r"id: '([^']+)'", block)
        name = re.search(r"name: '([^']+)'", block)
        description = re.search(r"description: '([^']+)'", block)
        eligible_categories = re.findall(r"GroupCategory\.([A-Za-z_]+)", block)
        if id_ and name and description:
            categories.append(VoteCategory(
                id=id_.group(1),
                name=name.group(1),
                description=description.group(1),
                groups=[],
                eligible_categories=eligible_categories
            ))
    return groups, categories

class AddEditGroupDialog(ctk.CTkToplevel):
    def __init__(self, parent, group=None):
        super().__init__(parent)
        self.group = group
        self.result = None
        
        self.title("団体の追加" if not group else "団体の編集")
        self.geometry("600x800")
        
        # メインフレーム
        main_frame = ctk.CTkFrame(self)
        main_frame.pack(fill="both", expand=True)
        
        # スクロール可能なフレーム
        scroll_frame = ctk.CTkScrollableFrame(main_frame)
        scroll_frame.pack(fill="both", expand=True)
        
        # ID
        ctk.CTkLabel(scroll_frame, text="ID:", font=COMMON_FONT).pack(anchor="w", pady=(10,0))
        self.id_entry = ctk.CTkEntry(scroll_frame, font=COMMON_FONT)
        self.id_entry.pack(fill="x", pady=(0,10))
        if group:
            self.id_entry.insert(0, group.id)
        
        # 名前
        ctk.CTkLabel(scroll_frame, text="団体名:", font=COMMON_FONT).pack(anchor="w", pady=(10,0))
        self.name_entry = ctk.CTkEntry(scroll_frame, font=COMMON_FONT)
        self.name_entry.pack(fill="x", pady=(0,10))
        if group:
            self.name_entry.insert(0, group.name)
        
        # 説明
        ctk.CTkLabel(scroll_frame, text="説明:", font=COMMON_FONT).pack(anchor="w", pady=(10,0))
        self.description_text = ctk.CTkTextbox(scroll_frame, height=100, font=COMMON_FONT)
        self.description_text.pack(fill="x", pady=(0,10))
        if group:
            self.description_text.insert("1.0", group.description)
        
        # 画像パス
        ctk.CTkLabel(scroll_frame, text="画像パス:", font=COMMON_FONT).pack(anchor="w", pady=(10,0))
        self.image_path_entry = ctk.CTkEntry(scroll_frame, font=COMMON_FONT)
        self.image_path_entry.pack(fill="x", pady=(0,10))
        if group:
            self.image_path_entry.insert(0, group.image_path)
        
        # 階
        ctk.CTkLabel(scroll_frame, text="階:", font=COMMON_FONT).pack(anchor="w", pady=(10,0))
        self.floor_var = ctk.StringVar(value="1")
        floor_frame = ctk.CTkFrame(scroll_frame)
        floor_frame.pack(fill="x", pady=(0,10))
        for i in range(1, 5):
            ctk.CTkRadioButton(
                floor_frame,
                text=f"{i}階",
                variable=self.floor_var,
                value=str(i),
                font=COMMON_FONT
            ).pack(side="left", padx=10)
        if group:
            self.floor_var.set(str(group.floor))
        
        # カテゴリー
        ctk.CTkLabel(scroll_frame, text="カテゴリー:", font=COMMON_FONT).pack(anchor="w", pady=(10,0))
        self.category_vars = {}
        for category in ['Tenji', 'Moyoshi', 'Gakunen', 'Roten', 'Stage', 'Band', 'Performance']:
            var = ctk.BooleanVar(value=category in (group.categories if group else []))
            self.category_vars[category] = var
            ctk.CTkCheckBox(
                scroll_frame,
                text=category,
                variable=var,
                font=COMMON_FONT
            ).pack(anchor="w", pady=2)
        
        # ボタン
        button_frame = ctk.CTkFrame(main_frame)
        button_frame.pack(fill="x", pady=20)
        
        ctk.CTkButton(
            button_frame,
            text="保存",
            command=self.save,
            font=COMMON_FONT
        ).pack(side="right", padx=5)
        
        ctk.CTkButton(
            button_frame,
            text="キャンセル",
            command=self.cancel,
            font=COMMON_FONT
        ).pack(side="right", padx=5)
        
        self.grab_set()
        self.focus_set()
    
    def save(self):
        try:
            self.result = {
                'id': self.id_entry.get(),
                'name': self.name_entry.get(),
                'description': self.description_text.get("1.0", "end-1c"),
                'image_path': self.image_path_entry.get(),
                'floor': int(self.floor_var.get()),
                'categories': [cat for cat, var in self.category_vars.items() if var.get()]
            }
            self.destroy()
        except Exception as e:
            messagebox.showerror("エラー", str(e))
    
    def cancel(self):
        self.destroy()

class AddEditCategoryDialog(ctk.CTkToplevel):
    def __init__(self, parent, category=None):
        super().__init__(parent)
        self.category = category
        self.result = None
        
        self.title("カテゴリーの追加" if not category else "カテゴリーの編集")
        self.geometry("600x600")
        
        # メインフレーム
        main_frame = ctk.CTkFrame(self)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # スクロール可能なフレーム
        scroll_frame = ctk.CTkScrollableFrame(main_frame)
        scroll_frame.pack(fill="both", expand=True)
        
        # ID
        ctk.CTkLabel(scroll_frame, text="ID:", font=COMMON_FONT).pack(anchor="w", pady=(10,0))
        self.id_entry = ctk.CTkEntry(scroll_frame, font=COMMON_FONT)
        self.id_entry.pack(fill="x", pady=(0,10))
        if category:
            self.id_entry.insert(0, category.id)
        
        # 名前
        ctk.CTkLabel(scroll_frame, text="カテゴリー名:", font=COMMON_FONT).pack(anchor="w", pady=(10,0))
        self.name_entry = ctk.CTkEntry(scroll_frame, font=COMMON_FONT)
        self.name_entry.pack(fill="x", pady=(0,10))
        if category:
            self.name_entry.insert(0, category.name)
        
        # 説明
        ctk.CTkLabel(scroll_frame, text="説明:", font=COMMON_FONT).pack(anchor="w", pady=(10,0))
        self.description_text = ctk.CTkTextbox(scroll_frame, height=100, font=COMMON_FONT)
        self.description_text.pack(fill="x", pady=(0,10))
        if category:
            self.description_text.insert("1.0", category.description)
        
        # 対象カテゴリー
        ctk.CTkLabel(scroll_frame, text="対象カテゴリー:", font=COMMON_FONT).pack(anchor="w", pady=(10,0))
        self.category_vars = {}
        for category in ['Tenji', 'Moyoshi', 'Gakunen', 'Roten', 'Stage', 'Band', 'Performance']:
            var = ctk.BooleanVar(value=category in (category.eligible_categories if category else []))
            self.category_vars[category] = var
            ctk.CTkCheckBox(
                scroll_frame,
                text=category,
                variable=var,
                font=COMMON_FONT
            ).pack(anchor="w", pady=2)
        
        # ボタン
        button_frame = ctk.CTkFrame(main_frame)
        button_frame.pack(fill="x", pady=20)
        
        ctk.CTkButton(
            button_frame,
            text="保存",
            command=self.save,
            font=COMMON_FONT
        ).pack(side="right", padx=5)
        
        ctk.CTkButton(
            button_frame,
            text="キャンセル",
            command=self.cancel,
            font=COMMON_FONT
        ).pack(side="right", padx=5)
        
        self.grab_set()
        self.focus_set()
    
    def save(self):
        try:
            self.result = {
                'id': self.id_entry.get(),
                'name': self.name_entry.get(),
                'description': self.description_text.get("1.0", "end-1c"),
                'eligible_categories': [cat for cat, var in self.category_vars.items() if var.get()]
            }
            self.destroy()
        except Exception as e:
            messagebox.showerror("エラー", str(e))
    
    def cancel(self):
        self.destroy()

class VoteOptionsEditor(ctk.CTk):
    def __init__(self):
        super().__init__()
        # タブにもフォントが反映されるようTkDefaultFontを設定
        try:
            default_font = font.nametofont("TkDefaultFont")
            default_font.configure(family="Yu Gothic UI", size=12)
        except Exception:
            default_font = font.nametofont("TkDefaultFont")
            default_font.configure(family="Meiryo", size=12)
        self.title("投票オプション管理")
        self.geometry("1200x800")
        self.groups = []
        self.categories = []
        self.save_path = 'lib/config/vote_options.dart'  # デフォルト保存先
        self.setup_ui()
    
    def setup_ui(self):
        main_frame = ctk.CTkFrame(self)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)
        ctk.CTkLabel(
            main_frame,
            text="投票オプション管理",
            font=TITLE_FONT
        ).pack(pady=(0,20))
        self.tabview = ctk.CTkTabview(main_frame)
        self.tabview.pack(fill="both", expand=True)
        groups_tab = self.tabview.add("Groups")  # 英語化
        self.setup_groups_tab(groups_tab)
        categories_tab = self.tabview.add("Categories")  # 英語化
        self.setup_categories_tab(categories_tab)
        file_frame = ctk.CTkFrame(main_frame)
        file_frame.pack(fill="x", pady=20)
        ctk.CTkButton(
            file_frame,
            text="Dartをインポート",
            command=self.import_dart,
            font=COMMON_FONT
        ).pack(side="left", padx=5)
        ctk.CTkButton(
            file_frame,
            text="Dartをエクスポート",
            command=self.export_dart,
            font=COMMON_FONT
        ).pack(side="left", padx=5)
        ctk.CTkButton(
            file_frame,
            text="変更を保存",
            command=self.save_changes,
            font=COMMON_FONT
        ).pack(side="right", padx=5)
    
    def setup_groups_tab(self, tab):
        list_frame = ctk.CTkFrame(tab)
        list_frame.pack(fill="both", expand=True, padx=10, pady=10)
        self.groups_scroll = ctk.CTkScrollableFrame(list_frame)
        self.groups_scroll.pack(fill="both", expand=True)
        button_frame = ctk.CTkFrame(tab)
        button_frame.pack(fill="x", pady=10)
        ctk.CTkButton(
            button_frame,
            text="団体を追加",
            command=self.add_group,
            font=COMMON_FONT
        ).pack(side="left", padx=5)
        self.update_groups_list()
    
    def setup_categories_tab(self, tab):
        list_frame = ctk.CTkFrame(tab)
        list_frame.pack(fill="both", expand=True, padx=10, pady=10)
        self.categories_scroll = ctk.CTkScrollableFrame(list_frame)
        self.categories_scroll.pack(fill="both", expand=True)
        button_frame = ctk.CTkFrame(tab)
        button_frame.pack(fill="x", pady=10)
        ctk.CTkButton(
            button_frame,
            text="カテゴリーを追加",
            command=self.add_category,
            font=COMMON_FONT
        ).pack(side="left", padx=5)
        self.update_categories_list()
    
    def load_data(self):
        try:
            with open('vote_options.json', 'r', encoding='utf-8') as f:
                data = json.load(f)
                self.groups = [Group(**g) for g in data['groups']]
                self.categories = [VoteCategory(**c) for c in data['categories']]
        except FileNotFoundError:
            self.groups = []
            self.categories = []
    
    def save_data(self):
        data = {
            'groups': [g.to_dict() for g in self.groups],
            'categories': [c.to_dict() for c in self.categories]
        }
        with open('vote_options.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    def update_groups_list(self):
        for widget in self.groups_scroll.winfo_children():
            widget.destroy()
        # ヘッダー
        header = ctk.CTkFrame(self.groups_scroll, fg_color=("#333", "#333"))
        header.pack(fill="x", pady=2, padx=2)
        ctk.CTkLabel(header, text="ID", width=60, font=COMMON_FONT).pack(side="left", padx=4)
        ctk.CTkLabel(header, text="Name", width=200, font=COMMON_FONT).pack(side="left", padx=4)
        ctk.CTkLabel(header, text="Floor", width=50, font=COMMON_FONT).pack(side="left", padx=4)
        ctk.CTkLabel(header, text="Categories", width=200, font=COMMON_FONT).pack(side="left", padx=4)
        ctk.CTkLabel(header, text="Description", width=400, font=COMMON_FONT).pack(side="left", padx=4)
        ctk.CTkLabel(header, text="", width=120).pack(side="left")
        # 各団体を1行ずつ
        for idx, group in enumerate(self.groups):
            row = ctk.CTkFrame(self.groups_scroll, fg_color=("#222", "#222"), corner_radius=4)
            row.pack(fill="x", pady=2, padx=2)
            ctk.CTkLabel(row, text=group.id, width=60, font=COMMON_FONT, anchor="w").pack(side="left", padx=4)
            ctk.CTkLabel(row, text=group.name, width=200, font=COMMON_FONT, anchor="w").pack(side="left", padx=4)
            ctk.CTkLabel(row, text=str(group.floor), width=50, font=COMMON_FONT, anchor="w").pack(side="left", padx=4)
            ctk.CTkLabel(row, text=", ".join(group.categories), width=200, font=COMMON_FONT, anchor="w").pack(side="left", padx=4)
            ctk.CTkLabel(row, text=group.description, width=400, font=COMMON_FONT, anchor="w", wraplength=380).pack(side="left", padx=4)
            btn_frame = ctk.CTkFrame(row, fg_color="transparent")
            btn_frame.pack(side="left", padx=4)
            ctk.CTkButton(
                btn_frame, text="編集", font=COMMON_FONT,
                command=lambda idx=idx: self.edit_group(idx), width=50
            ).pack(side="left", padx=2)
            ctk.CTkButton(
                btn_frame, text="削除", font=COMMON_FONT,
                command=lambda idx=idx: self.delete_group(idx), width=50
            ).pack(side="left", padx=2)
    
    def update_categories_list(self):
        for widget in self.categories_scroll.winfo_children():
            widget.destroy()
        for cat_idx, category in enumerate(self.categories):
            cat_card = ctk.CTkFrame(self.categories_scroll, fg_color=("#222", "#222"), corner_radius=8)
            cat_card.pack(fill="x", pady=8, padx=8)
            # カテゴリー名・ID
            ctk.CTkLabel(cat_card, text=f"{category.name} ({category.id})", font=COMMON_FONT).pack(anchor="w", padx=10, pady=(6,0))
            # 対象カテゴリー
            ctk.CTkLabel(cat_card, text=f"対象: {', '.join(category.eligible_categories)}", font=COMMON_FONT).pack(anchor="w", padx=10)
            # 説明
            ctk.CTkLabel(cat_card, text=category.description, font=COMMON_FONT, wraplength=900, justify="left").pack(anchor="w", padx=10, pady=(0,6))
            # 団体リストヘッダー
            group_header = ctk.CTkFrame(cat_card, fg_color=("#333", "#333"))
            group_header.pack(fill="x", padx=10, pady=(0,2))
            ctk.CTkLabel(group_header, text="ID", width=60, font=COMMON_FONT).pack(side="left", padx=4)
            ctk.CTkLabel(group_header, text="Name", width=200, font=COMMON_FONT).pack(side="left", padx=4)
            ctk.CTkLabel(group_header, text="Floor", width=50, font=COMMON_FONT).pack(side="left", padx=4)
            ctk.CTkLabel(group_header, text="Categories", width=200, font=COMMON_FONT).pack(side="left", padx=4)
            ctk.CTkLabel(group_header, text="Description", width=400, font=COMMON_FONT).pack(side="left", padx=4)
            ctk.CTkLabel(group_header, text="", width=120).pack(side="left")
            # 団体リスト
            for idx, group in enumerate(category.groups):
                row = ctk.CTkFrame(cat_card, fg_color=("#222", "#222"), corner_radius=4)
                row.pack(fill="x", pady=2, padx=10)
                ctk.CTkLabel(row, text=group.id, width=60, font=COMMON_FONT, anchor="w").pack(side="left", padx=4)
                ctk.CTkLabel(row, text=group.name, width=200, font=COMMON_FONT, anchor="w").pack(side="left", padx=4)
                ctk.CTkLabel(row, text=str(group.floor), width=50, font=COMMON_FONT, anchor="w").pack(side="left", padx=4)
                ctk.CTkLabel(row, text=", ".join(group.categories), width=200, font=COMMON_FONT, anchor="w").pack(side="left", padx=4)
                ctk.CTkLabel(row, text=group.description, width=400, font=COMMON_FONT, anchor="w", wraplength=380).pack(side="left", padx=4)
                btn_frame = ctk.CTkFrame(row, fg_color="transparent")
                btn_frame.pack(side="left", padx=4)
                ctk.CTkButton(
                    btn_frame, text="編集", font=COMMON_FONT,
                    command=lambda g=group: self.edit_group_by_obj(g), width=50
                ).pack(side="left", padx=2)
                ctk.CTkButton(
                    btn_frame, text="削除", font=COMMON_FONT,
                    command=lambda g=group: self.delete_group_by_obj(g), width=50
                ).pack(side="left", padx=2)
    
    def edit_group_by_obj(self, group):
        idx = next((i for i, g in enumerate(self.groups) if g.id == group.id), None)
        if idx is not None:
            self.edit_group(idx)
            self.update_categories_list()

    def delete_group_by_obj(self, group):
        idx = next((i for i, g in enumerate(self.groups) if g.id == group.id), None)
        if idx is not None:
            self.delete_group(idx)
            self.update_categories_list()
    
    def add_group(self):
        dialog = AddEditGroupDialog(self)
        self.wait_window(dialog)
        if dialog.result:
            self.groups.append(Group(**dialog.result))
            self.update_groups_list()
    
    def edit_group(self, idx):
        dialog = AddEditGroupDialog(self, self.groups[idx])
        self.wait_window(dialog)
        if dialog.result:
            self.groups[idx] = Group(**dialog.result)
            self.update_groups_list()
    
    def delete_group(self):
        selection = self.groups_list.get("sel.first", "sel.last")
        if selection:
            index = int(selection.split("\n")[0].split("(")[1].split(")")[0])
            if messagebox.askyesno("確認", f"{self.groups[index].name}を削除してもよろしいですか？"):
                del self.groups[index]
                self.update_groups_list()
    
    def add_category(self):
        dialog = AddEditCategoryDialog(self)
        self.wait_window(dialog)
        if dialog.result:
            self.categories.append(VoteCategory(**dialog.result))
            self.update_categories_list()
    
    def import_dart(self):
        file_path = filedialog.askopenfilename(
            title="Dartファイルを選択",
            filetypes=[("Dart files", "*.dart")]
        )
        if file_path:
            try:
                groups, categories = parse_dart_file(file_path)
                self.groups = groups
                self.categories = categories
                self.update_groups_list()
                self.update_categories_list()
                messagebox.showinfo("成功", "Dartファイルをインポートしました")
            except Exception as e:
                messagebox.showerror("エラー", f"Dartインポートエラー: {str(e)}")
    
    def export_dart(self):
        file_path = filedialog.asksaveasfilename(
            title="Dartファイルを保存",
            defaultextension=".dart",
            filetypes=[("Dart files", "*.dart")]
        )
        if file_path:
            try:
                dart_code = generate_dart_code(self.groups, self.categories)
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(dart_code)
                messagebox.showinfo("成功", "Dartファイルをエクスポートしました")
            except Exception as e:
                messagebox.showerror("エラー", f"エクスポートエラー: {str(e)}")
    
    def save_changes(self):
        # Dartファイルとしてのみ保存
        try:
            dart_code = generate_dart_code(self.groups, self.categories)
            with open('lib/config/vote_options.dart', 'w', encoding='utf-8') as f:
                f.write(dart_code)
            messagebox.showinfo("成功", "変更を保存しました (Dartファイル)")
        except Exception as e:
            messagebox.showerror("エラー", f"保存エラー: {str(e)}")

if __name__ == "__main__":
    ctk.set_appearance_mode("dark")
    ctk.set_default_color_theme("blue")
    app = VoteOptionsEditor()
    app.mainloop() 