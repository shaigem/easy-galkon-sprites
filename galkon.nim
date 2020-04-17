import os
import streams
import untar/gzip
import endians
import yaml
import strutils

type Sprite = object
    id: int16
    name: string
    offsetX: int16
    offsetY: int16
    data: seq[int8]
# the sprite's data will not be serialized into yaml
markAsTransient(Sprite, data)

type ParseCode {.pure.} = enum
    Terminate = 0
    ReadId = 1
    ReadName = 2
    ReadOffsetX = 3
    ReadOffsetY = 4
    ReadData = 5

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
        indexFileStream = newGzStream(indexFileName)
        dataFileStream = newGzStream(dataFileName)
    defer: indexFileStream.close()
    defer: dataFileStream.close()

    var numSprites = indexFileStream.readInt32()
    bigEndian32(addr numSprites, addr numSprites)

    for i in 0 ..< numSprites:
        discard indexFileStream.readInt32()
        var sprite = Sprite()
        while true:
            let code = ParseCode(dataFileStream.readInt8())
            case code:
            of ParseCode.Terminate:
                break
            of ParseCode.ReadId:
                sprite.id = dataFileStream.readInt16()
                bigEndian16(addr sprite.id, addr sprite.id)
            of ParseCode.ReadName:
                var length = dataFileStream.readInt16()
                bigEndian16(addr length, addr length)
                sprite.name = dataFileStream.readStr(length)
            of ParseCode.ReadOffsetX:
                sprite.offsetX = dataFileStream.readInt16()
                bigEndian32(addr sprite.offsetX, addr sprite.offsetX)
            of ParseCode.ReadOffsetY:
                sprite.offsetY = dataFileStream.readInt16()
                bigEndian32(addr sprite.offsetY, addr sprite.offsetY)
            of ParseCode.ReadData:
                var dataLength = indexFileStream.readInt32()
                bigEndian32(addr dataLength, addr dataLength)
                var data = newSeq[int8](dataLength)
                for i in 0 ..< dataLength:
                    data[i] = dataFileStream.readInt8()
                sprite.data = data
        fs.sprites.add(sprite)
    return fs

proc createCache*(fs: FileSystem, outputDirPath: string) =
    let
        indexFileName = outputDirPath / IndexFileName
        dataFileName = outputDirPath / DataFileName
        indexFileStream = newFileStream(indexFileName, fmReadWrite)
        dataFileStream = newFileStream(dataFileName, fmReadWrite)
    defer: indexFileStream.close()
    defer: dataFileStream.close()
    var spritesLength = int32(fs.sprites.len())
    bigEndian32(addr spritesLength, addr spritesLength)
    indexFileStream.writeData(addr spritesLength, sizeof spritesLength)

    spritesLength = int32(fs.sprites.len())

    # now we write the image data
    for id in 0 ..< spritesLength:
        let sprite = fs.sprites[id]

        var id = int16(sprite.id)
        if id != -1:
            dataFileStream.write(ParseCode.ReadId)

            bigEndian16(addr id, addr id)
            dataFileStream.writeData(addr id, sizeof id)

        let name = sprite.name
        if not name.isEmptyOrWhitespace:
            dataFileStream.write(ParseCode.ReadName)

            var length = int16(name.len())
            bigEndian16(addr length, addr length)
            dataFileStream.writeData(addr length, sizeof length)

            dataFileStream.write(name)

        var offsetX = int16(sprite.offsetX)
        if offsetX != 0:
            dataFileStream.write(ParseCode.ReadOffsetX)

            bigEndian16(addr offsetX, addr offsetX)
            dataFileStream.writeData(addr offsetX, sizeof offsetX)

        var offsetY = int16(sprite.offsetY)
        if offsetY != 0:
            dataFileStream.write(ParseCode.ReadOffsetY)

            bigEndian16(addr offsetY, addr offsetY)
            dataFileStream.writeData(addr offsetY, sizeof offsetY)

        let data = sprite.data
        if data.len != 0:
            dataFileStream.write(ParseCode.ReadData)
            for i in data:
                dataFileStream.write(i)

        dataFileStream.write(ParseCode.Terminate)

    for id in 0 ..< spritesLength:
        let sprite = fs.sprites[id]

        var id = int32(sprite.id)
        bigEndian32(addr id, addr id)
        indexFileStream.writeData(addr id, sizeof id)

        var dataLength = int32(sprite.data.len())
        bigEndian32(addr dataLength, addr dataLength)
        indexFileStream.writeData(addr dataLength, sizeof dataLength)

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


let fs = openCache(r"C:\Users\Ronnie\Desktop\galkon_sprite")
fs.createWorkingDirectory()
fs.createCache("./")

