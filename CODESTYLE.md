# Coding Guidelines
These code guidelines should be followed when developing for Polyplex, right now not all of polyplex adheres to this, but should do when 1.0 is ready.
Please note that these guidelines are based of the MonoGame Guidelines, adapted for D and the Polyplex prefered codestyle. And it will be expanded on as time goes.

## Tabs & Indentation
Tab characters (\0x09) are to be used in code.

## Bracing
Open braces should always be at the end of an statement. Contents of the brace should be indented by a single tab. For example:
```d
if (someExpression) {
	DoSomething();
	DoAnotherThing();
} else {
	DoSomethingElse();
	DoAnotherThingElse();
}
```

`case` statements should be indented from the switch statement like this:
```d
switch (someExpression) {
	case 0:
		DoSomething();
		break;

	case 1:
		DoSomethingElse();
		break;
}
```

Braces are not used for single statement blocks immediately following a `for`, `foreach`, `if`, `do`, etc.
```
for (int i = 0; i < 100; ++i) DoSomething(i);
```

## Properties
If a property only does one thing, it should be put in one line.
Properties that set values should have `value` as the name of the setting argument.

Example:
```d
public class Foo {
	private int bar;

	public @property int Bar() { return bar; }
	public @property void Bar(int value) { bar = value; }
}
```

## Commenting
Comments should be used to describe intention, algorithmic overview, and/or logical flow.  It would be ideal, if from reading the comments alone, someone other than the author could understand a function's intended behavior and general operation. While there are no minimum comment requirements and certainly some very small routines need no commenting at all, it is hoped that most routines will have comments reflecting the programmer's intent and approach.

Comments must provide added value or explanation to the code. Simply describing the code is not helpful or useful.
```d
	// Wrong
	// Set count to 1
	count = 1;

	// Right
	// Set the initial reference count so it isn't cleaned up next frame
	count = 1;
```

### Documentation Comments
Please creation documentation comments as multiline comments
Example:
```d
public class Foo 
{
	/**
		MyMethod does some cool stuff!
	*/
	public void MyMethod(int bar)
	{
		// ...
	}
}
```

### Comment Style
The // (two slashes) style of comment tags should be used in most situations. Where ever possible, place comments above the code instead of beside it.
```d
	// This is required for WebClient to work through the proxy
	GlobalProxySelection.Select = new WebProxy("http://itgproxy");

	// Create object to access Internet resources
	WebClient myClient = new WebClient();
```

## Spacing
Spaces improve readability by decreasing code density. Here are some guidelines for the use of space characters within code:

Do use a single space after a comma between function arguments.
```d
Console.In.Read(myChar, 0, 1);  // Right
Console.In.Read(myChar,0,1);    // Wrong
```

Do not use a space after the parenthesis and function arguments
```d
CreateFoo(myChar, 0, 1)         // Right
CreateFoo( myChar, 0, 1 )       // Wrong
```

Do not use spaces between a function name and parenthesis.
```d
CreateFoo()                     // Right
CreateFoo ()                    // Wrong
```

Do not use spaces inside brackets.
```d
x = dataArray[index];           // Right
x = dataArray[ index ];         // Wrong
```

Do use a single space before flow control statements
```d
while (x == y)                  // Right
while(x==y)                     // Wrong
```

Do use a single space before and after binary operators
```d
if (x == y)                     // Right
if (x==y)                       // Wrong
```

Do not use a space between a unary operator and the operand
```d
++i;                            // Right
++ i;                           // Wrong
```

Do not use a space before a semi-colon. Do use a space after a semi-colon if there is more on the same line
```d
for (int i = 0; i < 100; ++i)   // Right
for (int i=0 ; i<100 ; ++i)     // Wrong
```

## Naming
* Do not use Hungarian notation
* Do not use an underscore prefix for member variables, e.g. `_foo`
* Do use snake_casing for private member variables, function, property and event names (words all lowercase, with underscores between each word)
* Do use snake_casing for parameters
* Do use snake_casing for local variables
* Do use PascalCasing for public member variables, function, property, event, and class names (all words initial uppercase)
* Do prefix interfaces names with **I**
* Do not prefix enums, classes, or delegates with any letter

The reasons to extend the public rules (no Hungarian, underscore prefix for member variables, etc.) is to produce a consistent source code appearance. In addition a goal is to have clean readable source. Code legibility should be a primary goal.

## File Organization
* Class members should be grouped logically, and encapsulated into regions (Fields, Properties, Events, Constructors, Methods, Private interface implementations, Nested types)
* `import` statements should be at the top of the file.
```d
import std.stdio;
import sev.events;

public class MyClass : IFoo 
{
	int foo;

	public @property int Foo() { return foo; }
	public @property void Foo(int value) {
		FooChanged();
		foo = value;
	}

	public Event FooChanged;

	public this()
	{
		// ...
	}

	void DoSomething()
	{
		// ...
	}

	void FindSomething()
	{
		// ...
	}

	void IFoo.DoSomething()
	{
		DoSomething();
	}

	class NestedType
	{
		// ...
	}
}
```
