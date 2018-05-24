module polyplex.utils.random;
import rnd = std.random;

public class Random {
	private rnd.Random random;
	private int seed;

	this() {
		import core.stdc.time;
		this.seed = cast(int)time(null);
		random = rnd.Random(this.seed);
	}

	this (int seed) {
		this.seed = seed;
		random = rnd.Random(seed);
	}

	public int Next() {
		advance_seed();
		return rnd.uniform!int(random);
	}

	public int Next(int max) {
		advance_seed();
		return rnd.uniform(0, max, random);
	}

	public int Next(int min, int max) {
		advance_seed();
		return rnd.uniform(min, max, random);
	}
	
	public float NextFloat() {
		advance_seed();
		return rnd.uniform01!float(random);	
	}

	public double NextDouble() {
		advance_seed();
		return rnd.uniform01!double(random);	
	}

	private void advance_seed() {
		this.seed++;
		random.seed(this.seed);
	}
}
