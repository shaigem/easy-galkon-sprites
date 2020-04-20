import cache, yaml, os, streams

const 
    MetadataFileName = "metadata.yaml"
    SpritesDirName = "sprites"

proc openWorkingDirectory*(workingDirectoryPath: string): FileSystem =
    result = FileSystem()
    let imgDir = workingDirectoryPath / SpritesDirName

    # load the master metadata file for the sprites
    let metaFileStream = try: openFileStream(workingDirectoryPath / MetadataFileName, fmRead)
            except: quit("Problem loading " & MetadataFileName & "! " & getCurrentExceptionMsg())
    metaFileStream.load(result.sprites)

    let spritesLength = result.sprites.len()
    for id in 0 ..< spritesLength:
        if result.sprites[id].id != id:
            echo "ERROR: Trying to read sprite " & $id & " but read " & $result.sprites[id].id & " instead."
            echo "Did you delete an image out of order?"
            echo "Remember that you can only delete sprites with the highest id."
            echo "Check " & MetadataFileName & " for issues."
            quit()
        let imgPath = imgDir / $id & SpriteExtension
        if not fileExists(imgPath):
            echo("ERROR: Sprite image file " & $id & " is missing!")
            echo("Did you forget to delete it from " & MetadataFileName & "?")
            quit()
        let file = readFile(imgPath)
        result.sprites[id].data = cast[seq[int8]](file)

proc createWorkingDirectory*(fs: FileSystem, workingDirectoryPath: string) =
    discard existsOrCreateDir(workingDirectoryPath)
    var metadataStream = newFileStream(workingDirectoryPath / MetadataFileName, fmWrite)
    defer: metadataStream.close()
    fs.sprites.dump(metadataStream)
    fs.dumpImages(workingDirectoryPath / SpritesDirName)