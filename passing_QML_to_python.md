Pass parameters from Quickshell (QML) to Python using the Process API. Store the Python script path and your parameters in an array. Append arguments individually for accuracy.Here is how you do it:

```QML
import Quickshell
import Quickshell.Io

Process {
    id: pythonProcess
    
    // Pass the python executable, the script path, and parameters
    command: ["python3", "/path/to/script.py", "parameter1", "parameter2"]
    
    // Start the process
    running: true
}
```
In your Python (script.py) file, import sys and use sys.argv to read the passed parameters. The first argument (sys.argv[0]) is always the script's name.

```python
import sys

# Print all arguments passed from Quickshell
for i, arg in enumerate(sys.argv):
    print(f"Argument {i}: {arg}")
```