# Package

version       = "0.1.0"
author        = "Ronnie Tran"
description   = "Package for"
license       = "MIT"
srcDir        = "src"
bin           = @["gsbp"]
skipDirs      = @["test", "tools"]


# Dependencies

requires "nim >= 1.2.0"
requires "yaml >= 0.13.1"
requires "zip >= 0.2.1"