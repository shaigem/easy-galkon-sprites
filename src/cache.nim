import sprite
import os
import streams
import zip/gzipfiles
import binaryprimatives

type FileSystem* = ref object
    sprites*: seq[Sprite]

const
    DataFileName = "sprites.dat"
    IndexFileName = "sprites.idx"
    SpriteExtension* = ".png"

proc appendNewSpriteFromFile*(fs: FileSystem, filename: string): Sprite =
    let file = try: readFile(filename)
        except: quit("Problem creating sprite from file: " & filename & "! " & getCurrentExceptionMsg()) 
    result = Sprite()
    let newId = fs.sprites.high() + 1
    result.id = int16(newId)
    result.data = cast[seq[int8]](file)
    fs.sprites.add(result)

proc dumpImages*(fs: FileSystem, outputDirectory: string) =
    discard existsOrCreateDir(outputDirectory)
    for sprite in fs.sprites:
        var imgStream = newFileStream(outputDirectory / $sprite.id & SpriteExtension, fmWrite)
        defer: imgStream.close()
        for b in sprite.data:
            imgStream.write(b)

proc openCache*(cachePath: string) :  FileSystem =
    result = FileSystem()
    let
        indexFileName = cachePath / IndexFileName
        dataFileName = cachePath / DataFileName
        indexFileStream = try: newGzFileStream(indexFileName, fmRead) 
            except: quit("Problem loading " & IndexFileName & "! " & getCurrentExceptionMsg())
        dataFileStream = try: newGzFileStream(dataFileName, fmRead) 
            except: quit("Problem loading " & DataFileName & "! " & getCurrentExceptionMsg())
    defer: 
        indexFileStream.close()
        dataFileStream.close()

    let numSprites = indexFileStream.readInt32BigEndian()
    for i in 0 ..< numSprites:
        discard indexFileStream.readInt32()
        var sprite = newSpriteFromStreams(indexFileStream, dataFileStream)
        result.sprites.add(sprite)

proc createCache*(fs: FileSystem, outputDirPath: string) =
    discard existsOrCreateDir(outputDirPath)
    let
        indexFileName = outputDirPath / IndexFileName
        dataFileName = outputDirPath / DataFileName
        indexFileStream = try: newGzFileStream(indexFileName, fmWrite)
            except: quit("Problem creating " & IndexFileName & "! " & getCurrentExceptionMsg())        
        dataFileStream = try: newGzFileStream(dataFileName, fmWrite)
            except: quit("Problem creating " & DataFileName & "! " & getCurrentExceptionMsg())
    defer: 
        indexFileStream.close()
        dataFileStream.close()

    let spritesLength = int32(fs.sprites.len())
    indexFileStream.writeInt32BigEndian(spritesLength)

    # encode the sprites to the data file
    for id in 0 ..< spritesLength:
        let sprite = fs.sprites[id]
        var encodedSprite = sprite.encode().readAll()
        dataFileStream.write(encodedSprite)

    # encode the index information to the index file
    for id in 0 ..< spritesLength:
        let sprite = fs.sprites[id]
        let id = int32(sprite.id)
        indexFileStream.writeInt32BigEndian(id)
        let dataLength = int32(sprite.data.len())
        indexFileStream.writeInt32BigEndian(dataLength)