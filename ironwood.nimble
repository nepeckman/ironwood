# Package

version       = "0.0.1"
author        = "Nicolas Peckman"
description   = "Pokemon analysis software"
license       = "GPLv3"
srcDir        = "src"
bin           = @["ironwood"]

# Dependencies

requires "nim >= 0.18.0"
requires "uuids 0.1.9"

task damage, "Compiles and runs damage program":
  exec "nimble c -o:./build/damage -r src/engine/damage"
