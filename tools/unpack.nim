const doc = """
Welcome to Galkon's Sprite Unpacker (GSU).
TODO explain wat this does

"""
import ../src/cache, os

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