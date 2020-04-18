import yaml
import streams
import strutils
import binaryprimatives

const EmptyName = "None"

type Sprite* = object
    id*: int16
    name*: string
    offsetX*: int16
    offsetY*: int16
    data*: seq[int8]
# the sprite's data will not be serialized into yaml
markAsTransient(Sprite, data)

type ParseCode {.pure.} = enum
    Terminate = 0
    ReadId = 1
    ReadName = 2
    ReadOffsetX = 3
    ReadOffsetY = 4
    ReadData = 5

proc encode*(sprite: Sprite): Stream =
    result = newStringStream()
    let id = int16(sprite.id)
    if id != -1:
        result.write(ParseCode.ReadId)
        result.writeInt16BigEndian(id)

    let name = sprite.name
    if not name.isEmptyOrWhitespace:
        result.write(ParseCode.ReadName)
        let length = int16(name.len())
        result.writeInt16BigEndian(length)
        result.write(name)

    let offsetX = int16(sprite.offsetX)
    if offsetX != 0:
        result.write(ParseCode.ReadOffsetX)
        result.writeInt16BigEndian(offsetX)

    let offsetY = int16(sprite.offsetY)
    if offsetY != 0:
        result.write(ParseCode.ReadOffsetY)
        result.writeInt16BigEndian(offsetY)

    let data = sprite.data
    if data.len != 0:
        result.write(ParseCode.ReadData)
        for i in data:
            result.write(i)
    result.write(ParseCode.Terminate)
    result.setPosition(0)

proc newSpriteFromStreams*(indexFileStream: Stream,
        dataFileStream: Stream): Sprite =
    while true:
        let code = ParseCode(dataFileStream.readInt8())
        case code:
            of ParseCode.Terminate:
                break
            of ParseCode.ReadId:
                result.id = dataFileStream.readInt16BigEndian()
            of ParseCode.ReadName:
                let length = dataFileStream.readInt16BigEndian()
                let name = dataFileStream.readStr(length)
                result.name = if name == EmptyName: "" else: name
            of ParseCode.ReadOffsetX:
                result.offsetX = dataFileStream.readInt16BigEndian()
            of ParseCode.ReadOffsetY:
                result.offsetY = dataFileStream.readInt16BigEndian()
            of ParseCode.ReadData:
                let dataLength = indexFileStream.readInt32BigEndian()
                var data = newSeq[int8](dataLength)
                for i in 0 ..< dataLength:
                    data[i] = dataFileStream.readInt8()
                result.data = data
