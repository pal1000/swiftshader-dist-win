### Download
[![Download link](https://dev.azure.com/bontarka/swiftshader-dist-win/_apis/build/status/pal1000.swiftshader-dist-win?branchName=master)](https://dev.azure.com/bontarka/swiftshader-dist-win/_build?view=runs)

Binaries packages are created automatically on Azure Pipelines every 8 hours if there are changes either here or with swiftshader itself. Builds will end quickly, under 10 minutes and with no binaries posted if there is no change.

Each binaries package has a life span of 30 days since creation per default Azure Pipelines runs retention policy.

### How to use
For OpenGL ES just copy `libEGL.dll`, `libGLES_CM.dll` and `libGLESv2.dll` to program location.

For Vulkan you can either copy swiftshader DLL named`vulkan-1.dll` to program location to use swiftshader instalable client driver directly bypassing Vulkan loader or you can [register swiftshader instalable client driver to Vulkan loder](https://github.com/KhronosGroup/Vulkan-Loader/blob/master/loader/LoaderAndLayerInterface.md#icd-discovery).

Standalone Vulkan loader also known as Vulkan runtime is available [here](https://vulkan.lunarg.com/sdk/home#windows) - [Direct download](https://sdk.lunarg.com/sdk/download/latest/windows/vulkan-runtime.exe). But you may not need it if there is at least one GPU with Vulkan support on the system, because it's typically installed by Vulkan enabled graphics drivers. Though it won't hurt to update it, especially when GPU driver updates are missing in a long time.
### Planned improvements
This product will become easier to use over time as deployment tools that automate usage methods described in `How to use` section will gradually become available inside binaries packages. Check [development roadmap](https://github.com/pal1000/swiftshader-dist-win/blob/master/roadmap.md) for detailed progress.
