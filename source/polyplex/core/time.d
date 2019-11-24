module polyplex.core.time;
import std.format;
import polyplex.utils.strutils;

/**
	An ingame timespan
*/
class GameTimeSpan {
private:
	double ticks;

public:
	/**
		Gets the base value (a tick)
	*/
	@property double BaseValue() {
		return ticks;
	}

	/**
		Sets the base value (a tick)
	*/
	@property void BaseValue(double ticks) {
		this.ticks = ticks;
	}

	/**
		Gets the amount of milliseconds as a long
	*/
	@property ulong LMilliseconds() {
		return cast(ulong)Milliseconds;
	}

	/**
		Gets the amount of seconds as a long
	*/
	@property ulong LSeconds() {
		return cast(ulong)Seconds;
	}

	/**
		Gets the amount of minutes as a long
	*/
	@property ulong LMinutes() {
		return cast(ulong)Minutes;
	}

	/**
		Gets the amount of hours as a long
	*/
	@property ulong LHours() {
		return cast(ulong)Hours;
	}

	/**
		Gets the amount of milliseconds as a double
	*/
	@property double Milliseconds() {
		return ticks;
	}

	/**
		Gets the amount of milliseconds as a double
	*/
	@property double Seconds() {
		return ticks / 1000;
	}

	/**
		Gets the amount of milliseconds as a double
	*/
	@property double Minutes() {
		return Seconds / 60;
	}

	/**
		Gets the amount of milliseconds as a double
	*/
	@property double Hours() {
		return Minutes / 60;
	}

	/**
		Constructs a new game timespan instance
	*/
	this(ulong ticks) {
		this.ticks = ticks;
	}

	static {

		/**
			Create a new time span from specified seconds
		*/
		GameTimeSpan FromSeconds(ulong seconds) {
			return new GameTimeSpan(seconds * 1000);
		}

		/**
			Create a new time span from specified minutes
		*/
		GameTimeSpan FromMinutes(ulong minutes) {
			return FromSeconds(minutes * 60);
		}
		
		/**
			Create a new time span from specified hours
		*/
		GameTimeSpan FromHours(ulong hours) {
			return FromMinutes(hours * 60);
		}
	}

	/// Binary op
	GameTimeSpan opBinary(string op)(GameTimeSpan other) {
		return new GameTime(mixin(q{this.ticks %s other.ticks}.format(op)));
	}

	/**
		Calculates the ratio of this timespan compared to the other timespan
	*/
	float RatioOf(GameTimeSpan other) {
		return cast(float) this.ticks / cast(float) other.ticks;
	}

	/**
		Returns a human-friendly timespan string
	*/
	override
	string toString() {
		return "%d:%d:%d:%d".format(LHours, LMinutes % 60, LSeconds % 60, LMilliseconds % 60);
	}

	/**
		Format time using the polyplex formatter
	*/
	deprecated
	string FormatTime(string formatstring) {
		return Format(formatstring, LHours, LMinutes % 60, LSeconds % 60, LMilliseconds % 60);
	}
}

/**
	A container for game time
*/
class GameTime {
public:
	/**
		Creates a new gametime instance
	*/
	this(GameTimeSpan total, GameTimeSpan delta) {
		TotalTime = total;
		DeltaTime = delta;
	}

	/**
		The total time the game has been running
	*/
	GameTimeSpan TotalTime;

	/**
		The time between this and the last frame
	*/
	GameTimeSpan DeltaTime;

package(polyplex.core):

	/*
		Internal tools to update the delta and total time a bit more cleanly
	*/

	void updateDelta(double delta) {
		DeltaTime.BaseValue = delta;
	}

	void updateTotal(double total) {
		TotalTime.BaseValue = total;
	}
}
