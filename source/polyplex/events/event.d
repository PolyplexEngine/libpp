module polyplex.events.event;
import std.variant;

alias EventHandler = void delegate(void* sender, void* data);

public abstract class Event {
	private EventHandler[] handlers;
	this() { }

	void opCall(void* sender, void* data) {
		foreach(EventHandler h; handlers) {
			h(sender, data);
		}
	}

	void opCall(void* sender) {
		foreach(EventHandler h; handlers) {
			h(sender, null);
		}
	}

	Event opAddAssign(EventHandler handler) {
		handlers.length++;
		handlers[$-1] = handler;
		return this;
	}

	Event opSubAssign(EventHandler handler) {
		int remove = 0;
		for (int i = 0; i < handlers.length; i++) {
			if (handlers[i] == handler) {
				handlers[i] = null;
				remove++;
			}
			if (handlers[i-1] is null) {
				handlers[i-1] = handlers[i];
				handlers[i] = null;
			}
		}
		handlers.length -= remove;
		return this;
	}
}

public class BasicEvent : Event {
	this() { super(); }
}