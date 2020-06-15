Download from [![Download link](https://dev.azure.com/bontarka/swiftshader-dist-win/_apis/build/status/pal1000.swiftshader-dist-win?branchName=master)](https://dev.azure.com/bontarka/swiftshader-dist-win/_build?view=runs)

Binaries packages are created automatically on Azure Pipelines every 8 hours if there are changes either here or with swiftshader itself. Builds will end quickly, under 10 minutes and with no binaries posted if there is no change.

Each binaries package has a life span of 30 days since creation per default Azure Pipelines runs retention policy.

Legacy Direct3D drivers are available [here](https://github.com/pal1000/swiftshader-dist-win/releases/download/1.0.4g/swiftshader-legacy-D3D-2020_03_30.7z).
### How to use
For OpenGL ES just copy `libEGL.dll`, `libGLES_CM.dll` and `libGLESv2.dll` from `x86\bin` / `x64\bin` depending on program architecture to program location. Same for legacy Direct3D drivers, `d3d8.dll` and `d3d9.dll`.

For Vulkan there are a few options (you pick one or more, first is the easiest):
- Run `swiftshader-vulkan-setup.cmd` and follow the instructions (requires Vulkan loader, see paragraph bellow if you don't have any GPU with Vulkan support);
- copy swiftshader DLL named`vulkan-1.dll` from `x86\bin` / `x64\bin` depending on program architecture to program location to use swiftshader instalable client driver directly bypassing Vulkan loader;
- [register swiftshader instalable client driver to Vulkan loder](https://github.com/KhronosGroup/Vulkan-Loader/blob/master/loader/LoaderAndLayerInterface.md#icd-discovery) (expert method as it relies on registry changes, but it's a set and forget method if you keep unpacking swiftshader binaries on same location).

Standalone Vulkan loader also known as Vulkan runtime is available [here](https://vulkan.lunarg.com/sdk/home#windows) - [Direct download](https://sdk.lunarg.com/sdk/download/latest/windows/vulkan-runtime.exe). But you may not need it if there is at least one GPU with Vulkan support on the system, because it's typically installed by Vulkan enabled graphics drivers. Though it won't hurt to update it, especially when GPU driver updates are missing in a long time.
### Problems reporting
Only problems with binaries packaging are accepted here, otherwise look for help with SwiftShader directly, see links from next paragraph. So avoid reporting here problems with crashing applications unless you are absolutely certain it's due to build process or deployment tools. Absolutely don't report glitched rendering. That's 100% due to SwiftShader itself.

As for SwiftShader itself there are 2 support resources:
- a [forum](https://groups.google.com/forum/#!forum/swiftshader) - requires Google account to post;
- a [general bug tracker](https://g.co/swiftshaderbugs) - requires Google account to access and some tickets are private and can only be accessed by certain users.
### Planned improvements
This product will become easier to use over time as deployment tools that automate usage methods described in [How to use](#how-to-use) section will gradually become available inside binaries packages. Check [development roadmap](https://github.com/pal1000/swiftshader-dist-win/blob/master/roadmap.md) for detailed progress.
