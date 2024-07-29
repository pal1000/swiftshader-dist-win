@echo ------------------------------------------------------------
@echo BUILDING SWIFTSHADER WITH LLVM10 BACKEND FOR X86 ARHITECTURE
@echo ------------------------------------------------------------

@rem modules\abi.cmd
@set x64=n

@rem modules\toolchain.cmd
@set selecttoolchain=1
@set addvcpp=n

@rem modules\discoverpython.cmd
@set pyselect=1

@rem modules\pythonpackages.cmd
@set pyupd=n

@rem modules\throttle.cmd
@rem Throttle LLVM10 backend build to 1 CPU to avoid heap exhaustion
@set throttle=1

@rem modules\swiftshader.cmd
@set buildswiftshader=y
@set srcupd=n
@set ninja=n
@set subzerojit=n
@set spirvtools=y
@set test-swiftshader=n
@set cleanbuild=y

@rem modules\envdump.cmd
@set enableenvdump=n