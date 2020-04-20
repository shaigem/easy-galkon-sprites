# Package

version = "0.2.1"
author = "Ronnie Tran"
description = "Collection of tools that assists in " &
"managing files that uses Galkon's sprite cache format."
license = "MIT"
srcDir = "src"
bin = @["egs"]
skipDirs = @["test", "tools"]


# Dependencies
requires "nim >= 1.2.0"
requires "yaml >= 0.13.1"
requires "zip >= 0.2.1"
