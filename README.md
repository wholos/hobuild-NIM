# hobuild
Build system for unix!

hobuild - has a file extension of ```.hob```, and should always be named ```build.hob```, the syntax is simple

```
p = variable
block; = block
!() = variable reference in brackets
```

Example build.hob
```
p INT = "echo"

test;
    !(INT) 'hi'
```
and write in terminal ```hobuild test```

How to build?
``` sh
nim c hobuild.nim
```

How to install?
``` sh
sudo cp hobuild /usr/bin/hobuild
```
