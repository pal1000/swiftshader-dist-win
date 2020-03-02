### Download
[![Download link](https://dev.azure.com/bontarka/swiftshader-dist-win/_apis/build/status/pal1000.swiftshader-dist-win?branchName=master)](https://dev.azure.com/bontarka/swiftshader-dist-win/_build/latest?definitionId=1&branchName=master)

Binary packages are created automatically on Azure Pipelines every 8 hours if there are changes either here or with swiftshader itself. Builds will end quickly, under 10 minutes and with no binaries posted if there is no change.

### How to use
For OpenGL ES just copy `libEGL.dll`, `libGLES_CM.dll` and `libGLESv2.dll` to program location.
For Vulkan you can either copy swiftshader DLL named`vulkan-1.dll` to program location to use swiftshader instalable client driver directly bypassing Vulkan loader or you can [register swiftshader instalable client driver to Vulkan loder](https://github.com/KhronosGroup/Vulkan-Loader/blob/master/loader/LoaderAndLayerInterface.md#icd-discovery).

This product will become easier to use at version 1.1 when deployment tools that automate this deployment methods will become available. Check [development roadmap](https://github.com/pal1000/swiftshader-dist-win/blob/master/roadmap.md) for detailed progress.
