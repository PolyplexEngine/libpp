module polyplex.core.content.audio;
//import derelict.sdl2.mixer;
import polyplex.math;
import sev.event;
/*
private static int ids = 0;

public static void ClearAllSound() {
	Sound.StopAll();
	ids = 0;
	Mix_AllocateChannels(ids);
}

public abstract class Sound {
	protected int id;



	this(Mix_Music* music) {

	}

	this(Mix_Chunk* sample) {

	}

	public abstract void Play(bool repeat = false, int fadein = 0);
	public abstract void Pause();
	public abstract void Stop(int fadeout = 0);
	public abstract void Volume(float volume);

	public static StopAll() {
		Mix_HaltChannel(-1);
	}

	public static FadeOutAll(int ms) {
		Mix_FadeOutChannel(-1, ms);
	}

}

public class Music : Sound {
	private static Music CurrentPlaying;
	Mix_Music* music;
	public Event OnTrackEnd = new Event();

	this(Mix_Chunk* sample) {
		super(sample);
		throw new Exception("Tried to load sample as music!");
	}

	this(Mix_Music* music) {
		super(music);
		this.music = music;
	}

	~this() {
		Mix_FreeMusic(music);
	}

	protected void track_end_callback() {
		this.OnTrackEnd(null, null);
		CurrentPlaying = null;
	};

	public override void Play(bool repeat = false, int fadein = 0) {
		//Stop last track if a track is currently playing.
		if (!(CurrentPlaying is null)) {
			CurrentPlaying.Stop(fadein);
			while(!(CurrentPlaying is null)) {
				//Wait... Don't know if this is a good idea.
			}
		}

		//Hook Music Finished callback to cb, then play music.
		//TODO: Execute track end callback when track ends.
		//Mix_HookMusicFinished(cast(void*)&this.track_end_callback);
		if (repeat) Mix_FadeInMusic(music, -1, fadein);
		else Mix_FadeInMusic(music, 1, fadein);
		CurrentPlaying = this;
	}

	public override void Stop(int fadeout = 0) {
		if (!(CurrentPlaying is null) && CurrentPlaying == this) {
			Mix_FadeOutMusic(fadeout);
		}
	}

	public override void Pause() {
		if (!(CurrentPlaying is null) && CurrentPlaying == this) {
			
		}
	}

	public override void Volume(float vol) {
		Mix_VolumeMusic(cast(int)(vol/MIX_MAX_VOLUME));
	}
}

public class Audio : Sound {
	private Mix_Chunk* sample;

	this(Mix_Chunk* sample) {
		super(sample);
		this.sample = sample;
		this.id = ids;
		ids++;
		Mix_AllocateChannels(ids);
	}
	
	this(Mix_Music* music) {
		super(music);
		throw new Exception("Tried to load music as sample!");
	}

	~this() {
		
	}

	public override void Play(bool repeat = false, int fadein = 0) {
		if (repeat) Mix_FadeInChannel(id, sample, -1, fadein);
		else Mix_FadeInChannel(id, sample, 1, fadein);
	}
}*/