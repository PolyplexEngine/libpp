module polyplex.core.render.vk.vk;
import derelict.vulkan;
import derelict.vulkan.base;
import derelict.sdl2.sdl;
import std.conv;
import std.stdio;

public class Version {
	public int Major;
	public int Minor;
	public int Patch;
	public @property uint VKVersion() { return VK_MAKE_VERSION(Major, Minor, Patch); }
	public @property string ToString() { return to!string(Major) ~ "." ~ to!string(Minor) ~ "." ~ to!string(Patch); }
}

public class ApplicationInfo {
	private VkApplicationInfo info;

	public @property VkApplicationInfo AppInfo() { return info; }

	this(string appname, string enginename, Version appVersion, Version engineVersion, Version apiVersion) {
		info = VkApplicationInfo();
		info.sType = VkStructureType.VK_STRUCTURE_TYPE_APPLICATION_INFO;
		info.pApplicationName = appname.ptr;
		info.pEngineName = enginename.ptr;
		info.applicationVersion = appVersion.VKVersion;
		info.engineVersion = engineVersion.VKVersion;
		info.apiVersion = apiVersion.VKVersion;
	}

	public @property VkStructureType Type() {
		return info.sType;
	}

	public @property string AppName() {
		return info.pApplicationName.text;
	}

	public @property string EngineName() {
		return info.pEngineName.text;
	}

	public @property uint EngineVersion() {
		return info.engineVersion;
	}

	public @property uint APIVersion() {
		return info.apiVersion;
	}

	public @property uint AppVersion() {
		return info.applicationVersion;
	}

	public @property InstanceCreateInfo CreateInfo() {
		return new InstanceCreateInfo(this);
	}
}

public class InstanceCreateInfo {
	VkInstanceCreateInfo info;

	this(ApplicationInfo info) {
		this.info = VkInstanceCreateInfo();
		this.info.sType = VkStructureType.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
	}
}

public class Instance {
	VkInstance instance;

	this(InstanceCreateInfo createInfo) {
		
	}
}

public class Surface {
	this(SDL_Window* window) {
		SDL_SysWMinfo wminfo;
		if (!SDL_GetWindowWMInfo(window, &wminfo)) {
			throw new Error(to!string(SDL_GetError()));
		}
	}
}