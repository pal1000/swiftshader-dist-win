@echo -----------------------------------------------------------
@echo BUILDING SWIFTSHADER WITH LLVM7 BACKEND FOR X64 ARHITECTURE
@echo -----------------------------------------------------------

@set llvmtenbroken=n

@rem modules\abi.cmd
@set x64=y

@rem modules\toolchain.cmd
@set selecttoolchain=1
@set addvcpp=n

@rem modules\discoverpython.cmd
@set pyselect=1

@rem modules\pythonpackages.cmd
@set pyupd=n
@IF EXIST %devroot%\%projectname%\buildscript\assets\ciparallel.* set pyupd=y
@IF /I "%llvmtenbroken%"=="y" set pyupd=y

@rem modules\throttle.cmd
@set throttle=%NUMBER_OF_PROCESSORS%

@rem modules\swiftshader.cmd
@set buildswiftshader=y
@set srcupd=n
@set ninja=n
@set vk-swiftshader=y
@set gles-swiftshader=y
@set subzerojit=n
@set newllvm=n
@set test-swiftshader=n
@set cleanbuild=y

@rem modules\envdump.cmd
@set enableenvdump=n
@IF EXIST %devroot%\%projectname%\buildscript\assets\ciparallel.* set enableenvdump=y
@IF /I "%llvmtenbroken%"=="y" set enableenvdump=y