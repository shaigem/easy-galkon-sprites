const doc = """
Welcome to Easy Galkon Sprites Packer.
This tool creates a new cache (sprites.dat and sprites.idx) from the "working" folder
and outputs the new cache into a folder called "output-cache".
"""
import ../src/cache, os

const
    WorkingDirName = "working"
    OutputDirName = "output-cache"

let outputDirPath = getCurrentDir() / OutputDirName
let workingDirPath = getCurrentDir() / WorkingDirName

discard existsOrCreateDir(workingDirPath)
discard existsOrCreateDir(outputDirPath)

echo doc
echo "Opening workspace..."
let fs = openWorkingDirectory(workingDirPath)

echo "Creating new sprites.idx and sprites.dat..."
fs.createCache(outputDirPath)

echo "Complete! Created new cache in " &
    outputDirPath