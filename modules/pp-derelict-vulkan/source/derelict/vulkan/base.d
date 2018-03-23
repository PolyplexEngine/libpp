/*
** Copyright (c) 2015-2016 The Khronos Group Inc.
**
** Permission is hereby granted, free of charge, to any person obtaining a
** copy of this software and/or associated documentation files (the
** "Materials"), to deal in the Materials without restriction, including
** without limitation the rights to use, copy, modify, merge, publish,
** distribute, sublicense, and/or sell copies of the Materials, and to
** permit persons to whom the Materials are furnished to do so, subject to
** the following conditions:
**
** The above copyright notice and this permission notice shall be included
** in all copies or substantial portions of the Materials.
**
** THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
** IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
** MATERIALS OR THE USE OR OTHER DEALINGS IN THE MATERIALS.
*/
module derelict.vulkan.base;
extern(System):

//#include "vk_platform.h"

auto VK_MAKE_VERSION(int major, int minor, int patch) {
  return (major << 22) | (minor << 12) | patch;
}

auto VK_VERSION_MAJOR(uint ver) {
  return ver >> 22;
}

auto VK_VERSION_MINOR(uint ver) {
  return (ver >> 12) & 0x3ff;
}

auto VK_VERSION_PATCH(uint ver) {
  return ver & 0xfff;
}

package auto VK_DEFINE_HANDLE(string name) {
  return "struct " ~ name ~ "_T; \n alias " ~ name ~ " = " ~ name ~ "_T*;";
}

package auto VK_DEFINE_NON_DISPATCHABLE_HANDLE(string name) {
  // #if defined(__LP64__)    || defined(_WIN64) 
  //  || defined(__x86_64__)  || defined(_M_X64) 
  //  || defined(__ia64)      || defined (_M_IA64) 
  //  || defined(__aarch64__) || defined(__powerpc64__)
  return VK_DEFINE_HANDLE(name);
}

alias VkFlags      = uint;
alias VkBool32     = uint;
alias VkDeviceSize = ulong;
alias VkSampleMask = uint;

enum VK_VERSION_1_0 = 1;
enum VK_API_VERSION = VK_MAKE_VERSION(1, 0, 3); // Vulkan API version supported by this file
enum VK_NULL_HANDLE = null;

enum VK_TRUE  = 1;
enum VK_FALSE = 0;

enum VK_UUID_SIZE  = 16;
enum VK_WHOLE_SIZE = (~0UL);

enum VK_LOD_CLAMP_NONE    = 1000.0f;
enum VK_ATTACHMENT_UNUSED = (~0U);
enum VK_SUBPASS_EXTERNAL  = (~0U);

enum VK_QUEUE_FAMILY_IGNORED   = (~0U);
enum VK_REMAINING_MIP_LEVELS   = (~0U);
enum VK_REMAINING_ARRAY_LAYERS = (~0U);

enum VK_MAX_MEMORY_TYPES        = 32;
enum VK_MAX_MEMORY_HEAPS        = 16;
enum VK_MAX_EXTENSION_NAME_SIZE = 256;
enum VK_MAX_DESCRIPTION_SIZE    = 256;
enum VK_MAX_PHYSICAL_DEVICE_NAME_SIZE = 256;
