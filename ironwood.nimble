# Package

version       = "0.0.1"
author        = "Nicolas Peckman"
description   = "Pokemon analysis software"
license       = "GPLv3"
srcDir        = "src"
bin           = @["ironwood"]

# Dependencies

requires "nim >= 0.18.0"
requires "uuids 0.1.10"

task testengine, "Runs tests against the game engine":
  exec "mkdir -p ./build/tests"
  exec "nimble c -o:./build/tests/engine tests/engine/engine_test.nim"
  exec "./build/tests/engine"
