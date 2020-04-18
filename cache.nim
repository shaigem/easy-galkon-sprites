import sprite
import os
import streams
import zip/gzipfiles
import endians
import yaml

type FileSystem = ref object
    sprites*: seq[Sprite]

const
    DataFileName = "sprites.dat"
    IndexFileName = "sprites.idx"
    SpriteExtension = ".png"

proc openWorkingDirectory*(): FileSystem =
    var fs = FileSystem()
    let imgDir = getCurrentDir() / "working" / "images"

    # load the master metadata file for the sprites
    let metaFileStream = openFileStream("./working/metadata.yaml", fmRead)
    metaFileStream.load(fs.sprites)

    let spritesLength = fs.sprites.len()
    for id in 0 ..< spritesLength:
        let imgPath = imgDir / $id & SpriteExtension
        if not fileExists(imgPath): # TODO defragmentation
            quit("TODO useful error message on missing id: " & $id)
        let file = readFile(imgPath)
        fs.sprites[id].data = cast[seq[int8]](file)
    return fs

proc openCache*(cachePath: string): FileSystem =
    var fs = FileSystem()
    let
        indexFileName = cachePath / IndexFileName
        dataFileName = cachePath / DataFileName
        indexFileStream = newGzFileStream(indexFileName, fmRead)
        dataFileStream = newGzFileStream(dataFileName, fmRead)
    defer: indexFileStream.close()
    defer: dataFileStream.close()

    var numSprites = indexFileStream.readInt32()
    bigEndian32(addr numSprites, addr numSprites)
    for i in 0 ..< numSprites:
        discard indexFileStream.readInt32()
        var sprite = newSpriteFromStreams(indexFileStream, dataFileStream)
        fs.sprites.add(sprite)
    return fs

proc createCache*(fs: FileSystem, outputDirPath: string) =
    discard existsOrCreateDir(outputDirPath) # TODO handle error
    let
        indexFileName = outputDirPath / IndexFileName
        dataFileName = outputDirPath / DataFileName
        indexFileStream = newGzFileStream(indexFileName, fmWrite)
        dataFileStream = newGzFileStream(dataFileName, fmWrite)
    defer: indexFileStream.close()
    defer: dataFileStream.close()
    var spritesLength = int32(fs.sprites.len())
    bigEndian32(addr spritesLength, addr spritesLength)
    indexFileStream.write(spritesLength)

    # get the sprites length again with the normal endian
    spritesLength = int32(fs.sprites.len())

    for id in 0 ..< spritesLength:
        let sprite = fs.sprites[id]
        var encodedSprite = sprite.encode().readAll()
        dataFileStream.write(encodedSprite)

    for id in 0 ..< spritesLength:
        let sprite = fs.sprites[id]
        var id = int32(sprite.id)
        bigEndian32(addr id, addr id)
        indexFileStream.write(id)
        var dataLength = int32(sprite.data.len())
        bigEndian32(addr dataLength, addr dataLength)
        indexFileStream.write(dataLength)

proc dumpImages*(fs: FileSystem) =
    for sprite in fs.sprites:
        var imgStream = newFileStream("./working/images/" & $sprite.id & ".png", fmWrite)
        defer:
            imgStream.close()
        for b in sprite.data:
            imgStream.write(b)

proc createWorkingDirectory(fs: FileSystem) =
    var metadataStream = newFileStream("./working/metadata.yaml", fmWrite)
    defer: metadataStream.close()
    fs.sprites.dump(metadataStream)
    fs.dumpImages()


let fs = openCache(getCurrentDir() / "cache")
fs.createWorkingDirectory()
fs.createCache("./test_cache")
