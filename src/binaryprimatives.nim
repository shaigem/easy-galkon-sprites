import streams, endians

proc writeInt16BigEndian*(s: Stream, x: int16) {.inline.} =
    bigEndian16(unsafeAddr(x), unsafeAddr(x))
    s.write(x)

proc writeInt32BigEndian*(s: Stream, x: int32) {.inline.} =
    bigEndian32(unsafeAddr(x), unsafeAddr(x))
    s.write(x)

proc readInt16BigEndian*(s: Stream): int16 {.inline.} =
    result = s.readInt16()
    bigEndian16(unsafeAddr(result), unsafeAddr(result))

proc readInt32BigEndian*(s: Stream): int32 {.inline.} =
    result = s.readInt32()
    bigEndian32(unsafeAddr(result), unsafeAddr(result))
