import re
import pandas as pd
import os
import tkinter as tk
from tkinter import filedialog, ttk, messagebox
from typing import List, Dict, Any

def dart_to_excel(dart_file_path: str, excel_output_path: str) -> None:
    """
    Convert a Dart file with Group objects to Excel format
    
    Args:
        dart_file_path: Path to the Dart file
        excel_output_path: Path to save the Excel file
    """
    try:
        with open(dart_file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Extract group data using regex
        group_pattern = r"Group\(\s*id:\s*'([^']*)',\s*name:\s*'([^']*)',\s*description:\s*'([^']*)',\s*imagePath:\s*'([^']*)',\s*floor:\s*(\d+),\s*categories:\s*\[(.*?)\],\s*\)"
        
        groups = re.findall(group_pattern, content, re.DOTALL)
        
        # Prepare data for DataFrame
        data = []
        for group in groups:
            id_val, name, description, image_path, floor, categories = group
            
            # Extract categories
            category_pattern = r"GroupCategory\.(\w+)"
            categories_list = re.findall(category_pattern, categories)
            categories_str = ", ".join(categories_list)
            
            data.append({
                'ID': id_val,
                'Name': name,
                'Description': description,
                'ImagePath': image_path,
                'Floor': int(floor),
                'Categories': categories_str
            })
        
        # Create DataFrame and export to Excel
        df = pd.DataFrame(data)
        df.to_excel(excel_output_path, index=False)
        return True, f"Successfully converted Dart file to Excel: {excel_output_path}"
    except Exception as e:
        return False, f"Error: {str(e)}"

def excel_to_dart(excel_file_path: str, dart_template_file: str, dart_output_path: str) -> None:
    """
    Convert Excel format back to Dart file with Group objects
    
    Args:
        excel_file_path: Path to the Excel file
        dart_template_file: Path to the original Dart file (for template)
        dart_output_path: Path to save the new Dart file
    """
    try:
        # Read Excel file
        df = pd.read_excel(excel_file_path)
        
        # Read template Dart file to get the structure
        with open(dart_template_file, 'r', encoding='utf-8') as f:
            template_content = f.read()
        
        # Extract the parts before and after the group definitions
        parts = template_content.split("final List<Group> allGroups = [")
        if len(parts) != 2:
            raise ValueError("Could not find the group list in the template file")
        
        header = parts[0] + "final List<Group> allGroups = ["
        
        # Find where the list ends and get the footer
        list_end_parts = parts[1].split("];")
        if len(list_end_parts) < 2:
            raise ValueError("Could not find the closing bracket of group list in the template file")
        
        footer = list_end_parts[1]  # Everything after the closing bracket
        
        # Generate new group definitions
        group_definitions = []
        
        for _, row in df.iterrows():
            # Parse categories
            categories = row['Categories'].split(", ")
            categories_str = ", ".join([f"GroupCategory.{cat}" for cat in categories])
            
            # Create Group object string
            group_def = f"""
  Group(
    id: '{row['ID']}',
    name: '{row['Name']}',
    description: '{row['Description']}',
    imagePath: '{row['ImagePath']}',
    floor: {int(row['Floor'])},
    categories: [{categories_str}],
  ),"""
            group_definitions.append(group_def)
        
        # Combine into final content with the proper closing bracket
        final_content = header + "".join(group_definitions) + "\n];" + footer
        
        # Write to output file
        with open(dart_output_path, 'w', encoding='utf-8') as f:
            f.write(final_content)
        
        return True, f"Successfully converted Excel to Dart file: {dart_output_path}"
    except Exception as e:
        return False, f"Error: {str(e)}"

class ConverterApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Dart-Excel Converter")
        self.root.geometry("600x450")
        self.root.resizable(True, True)
        
        # Set some padding and styling
        style = ttk.Style()
        style.configure('TFrame', padding=10)
        style.configure('TButton', padding=5)
        style.configure('TLabel', padding=5)
        
        # Create main frame
        self.main_frame = ttk.Frame(root)
        self.main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Mode selection
        self.mode_frame = ttk.LabelFrame(self.main_frame, text="Conversion Mode")
        self.mode_frame.pack(fill=tk.X, padx=5, pady=5)
        
        self.mode_var = tk.StringVar(value="dart_to_excel")
        self.dart_to_excel_radio = ttk.Radiobutton(
            self.mode_frame, text="Dart to Excel", variable=self.mode_var, 
            value="dart_to_excel", command=self.toggle_mode)
        self.dart_to_excel_radio.pack(side=tk.LEFT, padx=5)
        
        self.excel_to_dart_radio = ttk.Radiobutton(
            self.mode_frame, text="Excel to Dart", variable=self.mode_var, 
            value="excel_to_dart", command=self.toggle_mode)
        self.excel_to_dart_radio.pack(side=tk.LEFT, padx=5)
        
        # File selection frames
        self.input_frame = ttk.LabelFrame(self.main_frame, text="Input File")
        self.input_frame.pack(fill=tk.X, padx=5, pady=5)
        
        self.input_path = tk.StringVar()
        self.input_entry = ttk.Entry(self.input_frame, textvariable=self.input_path, width=50)
        self.input_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5, pady=5)
        
        self.input_button = ttk.Button(self.input_frame, text="Browse...", command=self.browse_input)
        self.input_button.pack(side=tk.RIGHT, padx=5, pady=5)
        
        # Template file (for Excel to Dart mode)
        self.template_frame = ttk.LabelFrame(self.main_frame, text="Template Dart File")
        self.template_frame.pack(fill=tk.X, padx=5, pady=5)
        
        self.template_path = tk.StringVar()
        self.template_entry = ttk.Entry(self.template_frame, textvariable=self.template_path, width=50)
        self.template_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5, pady=5)
        
        self.template_button = ttk.Button(self.template_frame, text="Browse...", command=self.browse_template)
        self.template_button.pack(side=tk.RIGHT, padx=5, pady=5)
        
        # Output file
        self.output_frame = ttk.LabelFrame(self.main_frame, text="Output File")
        self.output_frame.pack(fill=tk.X, padx=5, pady=5)
        
        self.output_path = tk.StringVar()
        self.output_entry = ttk.Entry(self.output_frame, textvariable=self.output_path, width=50)
        self.output_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5, pady=5)
        
        self.output_button = ttk.Button(self.output_frame, text="Browse...", command=self.browse_output)
        self.output_button.pack(side=tk.RIGHT, padx=5, pady=5)
        
        # Convert button
        self.convert_button = ttk.Button(self.main_frame, text="Convert", command=self.convert)
        self.convert_button.pack(pady=10)
        
        # Status display
        self.status_frame = ttk.LabelFrame(self.main_frame, text="Status")
        self.status_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.status_text = tk.Text(self.status_frame, height=5, wrap=tk.WORD)
        self.status_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Initialize UI based on mode
        self.toggle_mode()
    
    def toggle_mode(self):
        mode = self.mode_var.get()
        
        if mode == "dart_to_excel":
            self.input_frame.config(text="Input Dart File")
            self.output_frame.config(text="Output Excel File")
            self.template_frame.pack_forget()
        else:  # excel_to_dart
            self.input_frame.config(text="Input Excel File")
            self.output_frame.config(text="Output Dart File")
            self.template_frame.pack(fill=tk.X, padx=5, pady=5, after=self.input_frame)
    
    def browse_input(self):
        mode = self.mode_var.get()
        
        if mode == "dart_to_excel":
            file_types = [("Dart Files", "*.dart"), ("All Files", "*.*")]
            title = "Select Dart File"
        else:
            file_types = [("Excel Files", "*.xlsx *.xls"), ("All Files", "*.*")]
            title = "Select Excel File"
        
        filename = filedialog.askopenfilename(
            title=title,
            filetypes=file_types
        )
        
        if filename:
            self.input_path.set(filename)
            
            # Auto-suggest output filename
            if not self.output_path.get():
                if mode == "dart_to_excel":
                    output = os.path.splitext(filename)[0] + ".xlsx"
                else:
                    output = os.path.splitext(filename)[0] + ".dart"
                self.output_path.set(output)
    
    def browse_template(self):
        filename = filedialog.askopenfilename(
            title="Select Template Dart File",
            filetypes=[("Dart Files", "*.dart"), ("All Files", "*.*")]
        )
        
        if filename:
            self.template_path.set(filename)
    
    def browse_output(self):
        mode = self.mode_var.get()
        
        if mode == "dart_to_excel":
            file_types = [("Excel Files", "*.xlsx"), ("All Files", "*.*")]
            default_ext = ".xlsx"
            title = "Save Excel File As"
        else:
            file_types = [("Dart Files", "*.dart"), ("All Files", "*.*")]
            default_ext = ".dart"
            title = "Save Dart File As"
        
        filename = filedialog.asksaveasfilename(
            title=title,
            filetypes=file_types,
            defaultextension=default_ext
        )
        
        if filename:
            self.output_path.set(filename)
    
    def convert(self):
        # Clear status text
        self.status_text.delete(1.0, tk.END)
        
        mode = self.mode_var.get()
        input_path = self.input_path.get()
        output_path = self.output_path.get()
        
        # Validate inputs
        if not input_path or not output_path:
            self.status_text.insert(tk.END, "Error: Please select input and output files.\n")
            return
        
        if mode == "excel_to_dart":
            template_path = self.template_path.get()
            if not template_path:
                self.status_text.insert(tk.END, "Error: Please select a template Dart file.\n")
                return
            
            success, message = excel_to_dart(input_path, template_path, output_path)
        else:
            success, message = dart_to_excel(input_path, output_path)
        
        # Display result
        self.status_text.insert(tk.END, message + "\n")
        
        if success:
            messagebox.showinfo("Success", message)
            
            # Ask if user wants to open the output file
            if messagebox.askyesno("Open File", "Do you want to open the output file?"):
                try:
                    import subprocess
                    if os.name == 'nt':  # Windows
                        os.startfile(output_path)
                    elif os.name == 'posix':  # macOS, Linux
                        if sys.platform == 'darwin':  # macOS
                            subprocess.call(('open', output_path))
                        else:  # Linux
                            subprocess.call(('xdg-open', output_path))
                except Exception as e:
                    messagebox.showwarning("Warning", f"Could not open file: {str(e)}")

if __name__ == "__main__":
    import sys
    
    root = tk.Tk()
    app = ConverterApp(root)
    root.mainloop()