#!/bin/sh
find src -name '*.elm' -or -name '*.js' | entr elm make src/Example.elm --output=index.html
