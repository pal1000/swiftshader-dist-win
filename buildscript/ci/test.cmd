@git clone -q --branch=master https://github.com/google/swiftshader C:\projects\swiftshader
@cd C:\projects\swiftshader
@FOR /F tokens^=^*^ USEBACKQ^ eol^= %%a IN (`git log -1 --format=format:"%aD"`) DO @set commitdate=%%a
@FOR /F tokens^=^*^ USEBACKQ^ eol^= %%a IN (`git log -1 --format=format:"%s"`) DO @set commitmessage=%%a
@FOR /F tokens^=^*^ USEBACKQ^ eol^= %%a IN (`git log -1 --format=format:"%H"`) DO @set commithash=%%a
@rem appveyor UpdateBuild -Message "%commitmessage%" -CommitId "%commithash%" -Committed "%commitdate%"