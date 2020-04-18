const doc = """
Welcome to Easy Galkon Sprites Bulk Import.
This tool imports images from the "bulk-import" folder in the working folder
Images imported are appended to the end of the filesystem.
This is useful when you want to add multiple images.
"""
import ../src/[cache, sprite], os, sequtils

const
    WorkingDirName = "working"
    BulkImportDirName = "bulk-import"

let workingDirPath = getCurrentDir() / WorkingDirName
let bulkImportDirPath = workingDirPath / BulkImportDirName

discard existsOrCreateDir(workingDirPath)

echo doc

let hasImagesToImport = existsOrCreateDir(bulkImportDirPath) and toSeq(walkdir(
        bulkImportDirPath)).len != 0

if not hasImagesToImport:
    echo "There are no images to import."
    quit(QuitSuccess)

echo "Opening workspace..."
let fs = openWorkingDirectory(workingDirPath)

echo "Walking through images from the " & BulkImportDirName & " folder..."

let pattern = bulkImportDirPath / "*.png"
for imgFilePath in walkFiles(pattern):
    let added = fs.appendNewSpriteFromFile(imgFilePath)
    echo "Added " & imgFilePath & " as id: " & $added.id

echo "Creating a new working directory with the new sprites..."
fs.createWorkingDirectory(workingDirPath)

echo "Complete!"
