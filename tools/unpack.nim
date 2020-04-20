const doc = """
Welcome to Easy Galkon Sprites Unpacker.
This tool unpacks images and their metadata from the cache (sprites.dat and sprites.idx) into a workspace folder.
This allows the user to edit sprites using tools already provided by the OS (eg. Windows Explorer and Notepad on Windows)
"""
import ../src/[cache, workspace], os

const
    InputDirName = "input"
    WorkingDirName = "working"

let inputDirPath = getCurrentDir() / InputDirName
let workingDirPath = getCurrentDir() / WorkingDirName

discard existsOrCreateDir(inputDirPath)
discard existsOrCreateDir(workingDirPath)

echo doc
echo "Opening cache..."
let fs = openCache(inputDirPath)

echo "Creating working directory..."
fs.createWorkingDirectory(workingDirPath)

echo "Complete! Created metadata and sprites in " &
    workingDirPath