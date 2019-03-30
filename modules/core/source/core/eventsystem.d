module core.eventsystem;



package __gshared Event[] eventBuffer;
__gshared bool PollEvent(Event* event) {
    scope(exit) {
        // once the function exits, push the polled event onto the queue
        if (event !is null) eventBuffer ~= *event;
    }
    return PollEventImpl(event);
}

/// Event polling delegate, assigned from backend.
__gshared bool delegate(Event* event) PollEventImpl;
//package __gshared 

/// Window event type
enum EventType : ubyte {
    WindowEvent,
    KeyboardEvent,
    MouseEvent
}

enum ButtonState : ubyte {
    Pressed = 1,
    Released = 0
}

/// Events that a window can invoke
enum WindowEvents : ubyte {
    Shown,
    Hidden,
    Exposed,
    Moved,
    Resized,
    SizeChanged,
    Minimized,
    Maximized,
    Restored,
    Enter,
    Leave,
    FocusGained,
    FocusLost,
    Close,
    TakeFocus
}

/// Events that a mouse can have
enum MouseEvents : ubyte {
    Move,
    Button,
    Wheel
}

private template EventBase() {
    EventType Type;
    size_t Timestamp;
    size_t ContextId;
}

struct Event {
    mixin EventBase!();
    WindowEvent Window;
    KeyboardEvent Keyboard;
    MouseEvent Mouse;
}

struct WindowEvent {
    mixin EventBase!();

    /// The sub-event
    WindowEvents Event;

    /// Event-dependant data X
    size_t X;

    /// Event dependant data Y
    size_t Y;
}

struct KeyboardEvent {
    mixin EventBase!();
    ButtonState State;
}

struct MouseEvent {
    /// Which mouse event was invoked
    MouseEvents Event;

    /// Mouse move event
    MouseMoveEvent Move;

    /// Mouse button event
    MouseButtonEvent Button;

    /// Mouse scroll event
    MouseWheelEvent Scroll;
}

struct MouseMoveEvent {
    mixin EventBase!();

    /// Where on X axis the mouse is, relative to surface
    size_t X;

    /// Where on Y axis the mouse is, relative to surface
    size_t Y;

    /// State of button
    ButtonState State;

    /// Where on X axis the mouse is, relative to surface
    size_t RelativeX;

    /// Where on Y axis the mouse is, relative to surface
    size_t RelativeY;
}

struct MouseButtonEvent {
    mixin EventBase!();

    /// Which mouse button was modified
    /// MouseButtons has the button mappings
    ubyte Button;

    /// Which state it changed to
    /// MouseButtonState has the state mapping
    ubyte State;

    /// Where on X axis the mouse is, relative to surface
    size_t X;

    /// Where on Y axis the mouse is, relative to surface
    size_t Y;
}

struct MouseWheelEvent {
    mixin EventBase!();

    /// The amount scrolled horizontally
    size_t X;

    /// The amount scrolled vertically
    size_t Y;

    /// Flags about the event (RESERVED)
    ubyte Flags;
}