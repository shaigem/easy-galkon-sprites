import yaml
import streams
import endians
import strutils
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
    var id = int16(sprite.id)
    if id != -1:
        result.write(ParseCode.ReadId)

        bigEndian16(addr id, addr id)
        result.write(id)

    let name = sprite.name
    if not name.isEmptyOrWhitespace:
        result.write(ParseCode.ReadName)

        var length = int16(name.len())
        bigEndian16(addr length, addr length)
        result.write(length)

        result.write(name)

    var offsetX = int16(sprite.offsetX)
    if offsetX != 0:
        result.write(ParseCode.ReadOffsetX)

        bigEndian16(addr offsetX, addr offsetX)
        result.write(offsetX)

    var offsetY = int16(sprite.offsetY)
    if offsetY != 0:
        result.write(ParseCode.ReadOffsetY)

        bigEndian16(addr offsetY, addr offsetY)
        result.write(offsetY)

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
                result.id = dataFileStream.readInt16()
                bigEndian16(addr result.id, addr result.id)
            of ParseCode.ReadName:
                var length = dataFileStream.readInt16()
                bigEndian16(addr length, addr length)
                let name = dataFileStream.readStr(length)
                result.name = if name == EmptyName: "" else: name
            of ParseCode.ReadOffsetX:
                result.offsetX = dataFileStream.readInt16()
                bigEndian32(addr result.offsetX, addr result.offsetX)
            of ParseCode.ReadOffsetY:
                result.offsetY = dataFileStream.readInt16()
                bigEndian32(addr result.offsetY, addr result.offsetY)
            of ParseCode.ReadData:
                var dataLength = indexFileStream.readInt32()
                bigEndian32(addr dataLength, addr dataLength)
                var data = newSeq[int8](dataLength)
                for i in 0 ..< dataLength:
                    data[i] = dataFileStream.readInt8()
                result.data = data
