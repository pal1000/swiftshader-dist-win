@rem modules\abi.cmd
@set x64=y

@rem modules\toolchain.cmd
@set selecttoolchain=1
@set addvcpp=n

@rem modules\discoverpython.cmd
@set pyselect=1

@rem modules\pythonpackages.cmd
@set pyupd=n

@rem modules\throttle.cmd
@set throttle=%NUMBER_OF_PROCESSORS%

@rem modules\swiftshader.cmd
@set buildswiftshader=y
@set srcupd=n
@set ninja=n
@set vk-swiftshader=y
@set gles-swiftshader=y
@set subzerojit=y
@set spirvtools=y
@set test-swiftshader=n
@set cleanbuild=y

@rem modules\envdump.cmd
@set enableenvdump=n