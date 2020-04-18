const doc = """
Welcome to Galkon's Sprite Packer (GSP).
TODO explain wat this does

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