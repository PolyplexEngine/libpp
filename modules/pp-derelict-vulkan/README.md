# DerelictVulkan
Dynamic Vulkan api bindings

Don't expect it to work until version 1.0.0

Currently only __Windows__ and __Posix__(__Xlib__, __XCB__) is supported.
Feel free to make pull request for other OSes.

On __Posix__ to use __Xlib__ or/and __XCB__ specific functionality:
- Add required library to your dependencies list
- Add related version flag(s):
  - **VK_USE_PLATFORM_XLIB_KHR**
  - **VK_USE_PLATFORM_XCB_KHR**
