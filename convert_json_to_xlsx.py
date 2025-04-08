import json
import os
import tkinter as tk
from tkinter import filedialog, messagebox
import pandas as pd
from pathlib import Path

def json_to_excel():
    # メインウィンドウを作成（非表示）
    root = tk.Tk()
    root.withdraw()
    
    # JSONファイル選択ダイアログを表示
    json_path = filedialog.askopenfilename(
        title="JSONファイルを選択してください",
        filetypes=[("JSONファイル", "*.json"), ("すべてのファイル", "*.*")]
    )
    
    if not json_path:
        messagebox.showinfo("", "ファイルが選択されませんでした。プログラムを終了します。")
        return
    
    try:
        # JSONファイルを読み込み
        with open(json_path, 'r', encoding='utf-8') as f:
            json_data = json.load(f)
        
        # "votes"キーの中のデータを処理
        if "votes" in json_data:
            votes_data = json_data["votes"]
            
            # 各投票データを行に変換
            rows = []
            for vote_id, vote_info in votes_data.items():
                # 基本情報を取得
                row = {
                    "uuid": vote_info.get("uuid", ""),
                    "timestamp": vote_info.get("timestamp", "")
                }
                
                # selections内の情報を展開
                if "selections" in vote_info:
                    selections = vote_info["selections"]
                    for key, value in selections.items():
                        row[key] = value
                
                rows.append(row)
            
            # DataFrameに変換
            df = pd.DataFrame(rows)
            
            # 保存先フォルダ選択ダイアログを表示
            save_folder = filedialog.askdirectory(
                title="保存先フォルダを選択してください"
            )
            
            if not save_folder:
                messagebox.showinfo("", "保存先フォルダが選択されませんでした。プログラムを終了します。")
                return
            
            # 元のファイル名を取得して拡張子を.xlsxに変更
            original_filename = Path(json_path).stem
            excel_filename = original_filename + ".xlsx"
            excel_path = os.path.join(save_folder, excel_filename)
            
            # Excelファイルとして保存
            df.to_excel(excel_path, index=False)
            
            # 成功メッセージをメッセージボックスで表示
            messagebox.showinfo("", f"変換が完了しました。ファイルを保存しました:\n{excel_path}")
        else:
            messagebox.showinfo("", "指定されたJSONファイルに'votes'キーが見つかりませんでした。")
        
    except Exception as e:
        messagebox.showerror("", f"エラーが発生しました: {str(e)}")

if __name__ == "__main__":
    json_to_excel()