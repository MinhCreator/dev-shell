To parse the modern hyprland.lua configuration format in Python, the most effective and native solution is using the hyprland-config library on GitHub. It features a built-in load_lua() function specifically engineered to round-trip parse the new Hyprland Lua configuration format introduced in version 0.55.

## Method 1: Using the hyprland-config Library (Recommended)This approach handles the Lua parsing under the hood, resolves variables, preserves formatting, and allows you to programmatically read or modify values.

### 1. Installation Install the package via pip. Ensure you have Python 3.12+ and a local system lua interpreter (5.3+) installed.

```bash
pip install hyprland-config
```

### 2. Python Script

```python
from hyprland_config import load_lua

# Load your hyprland.lua configuration
config = load_lua("~/.config/hypr/hyprland.lua")

# Retrieve a specific configuration option
gaps_in = config.get("general:gaps_in")
print(f"Inner gaps: {gaps_in}")

# Modify a setting programmatically
config.set("general:gaps_in", 15)

# Save the changes atomically back to the file
config.save()
```

## Method 2: Generic Lua AST Parsing (For Abstract Analysis)If you need to analyze the file structure as a pure code tree (AST) rather than looking up Hyprland-specific configuration options, you can use a generic Abstract Syntax Tree parser like py-lua-parser.

### 1. Installation

```bash
pip install luaparser
```

### 2. Python Script

```python
from luaparser import ast

# Read the file contents
with open("~/.config/hypr/hyprland.lua", "r") as f:
    lua_code = f.read()

# Parse into an Abstract Syntax Tree
tree = ast.parse(lua_code)

# Example: Print the structural representation of the nodes
print(ast.to_pretty_str(tree))
Hãy thận trọng khi sử dụng mã.Method 3: Executing and Extracting via Python subprocessIf you want to evaluate what the configuration actually outputs dynamically, you can feed the script directly into your system's Lua interpreter using Python's subprocess module.pythonimport subprocess

# Simple script to execute a print statement inside the context of the config
lua_command = 'dofile(os.getenv("HOME") .. "/.config/hypr/hyprland.lua"); print(hl.config.general.gaps_in)'

try:
    result = subprocess.run(
        ["lua", "-e", lua_command],
        capture_output=True,
        text=True,
        check=True
    )
    print("Value from Lua:", result.stdout.strip())
except subprocess.CalledProcessError as e:
    print("Error parsing via Lua:", e.stderr)
```
