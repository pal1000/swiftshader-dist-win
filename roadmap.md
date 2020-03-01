# Development roadmap
### Get Swiftshader build working with most important build options manually configurable (v0.1)
- [x] use LLVM build from [mesa-dist-win](https://github.com/pal1000/mesa-dist-win) as blueprint;
- [x] cleanup unneeded parts that mesa-dist-win uses;
- [x] annonimize project name in source for easy code sharing;
- [x] implement manual build options configuration,
### Automatic build configuration (v0.2)
- [x] write build configuratiion profiles;
- [x] implement CI mode in which pauses and screen clears are skipped and questions have answears pre-filled.
### Spawn buildbot (v1.0)
Write CI script that:
- [x] gets swiftshader and this repository source code;
- [x] execuute build with each configuratiion profile;
- [x] collects artifacts;
- [x] publishes artifacts.
### Usability improvements (v1.1)
- [ ] link to Khronos document about Vulkan Loader ICD discovery in readme;
- [ ] implemnt system-wide legacy type vulkan driver deployment;
- [ ] implement launcher with swiftshader as unique Vulkan driver;
- [ ] implement per application deployment with swiftshader as unique Vulkan driver;
- [ ] implement system-wide vulkan driver deployment via fake GPU or dummy software component if possible;
- [ ] implement per application deployment of swiftshader OpenGL ES driver.
### Support build with GN as an alternative to cmake (v1.2)
- [ ] create choice for it and integrate with build configuration profiles;
- [ ] research for and use cmake build options equivalents if possible.
