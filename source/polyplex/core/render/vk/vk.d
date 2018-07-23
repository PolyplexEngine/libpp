module polyplex.core.render.vk.vk;
import derelict.vulkan;
import derelict.vulkan.base;
import derelict.sdl2.sdl;
import std.conv;
import std.stdio;

public struct Version {
	public int Major;
	public int Minor;
	public int Patch;
	public @property uint VKVersion() { return VK_MAKE_VERSION(Major, Minor, Patch); }
	public @property string ToString() { return to!string(Major) ~ "." ~ to!string(Minor) ~ "." ~ to!string(Patch); }

	public static Version VulkanAPIVersion() { return Version(VK_VERSION_MAJOR(VK_API_VERSION), VK_VERSION_MINOR(VK_API_VERSION), VK_VERSION_PATCH(VK_API_VERSION)); }
}

public struct ApplicationInfo {
	private VkApplicationInfo info;

	public VkApplicationInfo AppInfo() { return info; }

	this(string appname, string enginename, Version appVersion, Version engineVersion, Version apiVersion) {
		info = VkApplicationInfo();
		info.sType = VkStructureType.VK_STRUCTURE_TYPE_APPLICATION_INFO;
		info.pApplicationName = appname.ptr;
		info.pEngineName = enginename.ptr;
		info.applicationVersion = appVersion.VKVersion;
		info.engineVersion = engineVersion.VKVersion;
		info.apiVersion = apiVersion.VKVersion;
	}

	public VkStructureType Type() {
		return info.sType;
	}

	public VkApplicationInfo* ptr() {
		return &info;
	}

	public string AppName() {
		return info.pApplicationName.text;
	}

	public string EngineName() {
		return info.pEngineName.text;
	}

	public uint EngineVersion() {
		return info.engineVersion;
	}

	public uint APIVersion() {
		return info.apiVersion;
	}

	public uint AppVersion() {
		return info.applicationVersion;
	}
/*
	public InstanceCreateInfo CreateInfo() {
		return new InstanceCreateInfo(this);
	}*/
}
