module polyplex.core.audio.source;
import polyplex.core.audio;
import derelict.openal;
import polyplex.math;

public class AudioSource {
	// Current buffer.
	private ALBuffer currbuff;

	// id of source.
	private ALuint id;
	
	// host device.
	public AudioDevice HostDevice;


	// Protect id from being modifying accidentally.
	public int Id() { return this.id; }

	/*
		PITCH
	*/
	public @property float Pitch() {
		float v = 0f;
		alGetSourcef(Id, AL_PITCH, &v);
		return v;
	}
	public @property void Pitch(float val) { alSourcef(Id, AL_PITCH, val); }

	/*
		GAIN
	*/
	public @property float Gain() {
		float v = 0f;
		alGetSourcef(Id, AL_GAIN, &v);
		return v;
	}
	public @property void Gain(float val) { alSourcef(Id, AL_GAIN, val); }

	/*
		MIN GAIN
	*/
	public @property float MinGain() {
		float v = 0f;
		alGetSourcef(Id, AL_MIN_GAIN, &v);
		return v;
	}
	public @property void MinGain(float val) { alSourcef(Id, AL_MIN_GAIN, val); }

	/*
		MAX GAIN
	*/
	public @property float MaxGain() {
		float v = 0f;
		alGetSourcef(Id, AL_MAX_GAIN, &v);
		return v;
	}
	public @property void MaxGain(float val) { alSourcef(Id, AL_MAX_GAIN, val); }

	/*
		MAX DISTANCE
	*/
	public @property float MaxDistance() {
		float v = 0f;
		alGetSourcef(Id, AL_MAX_DISTANCE, &v);
		return v;
	}
	public @property void MaxGain(float val) { alSourcef(Id, AL_MAX_DISTANCE, val); }

	/*
		ROLLOFF FACTOR
	*/
	public @property float RolloffFactor() {
		float v = 0f;
		alGetSourcef(Id, AL_ROLLOFF_FACTOR, &v);
		return v;
	}
	public @property void RolloffFactor(float val) { alSourcef(Id, AL_ROLLOFF_FACTOR, val); }

	/*
		CONE OUTER GAIN
	*/
	public @property float ConeOuterGain() {
		float v = 0f;
		alGetSourcef(Id, AL_CONE_OUTER_GAIN, &v);
		return v;
	}
	public @property void ConeOuterGain(float val) { alSourcef(Id, AL_CONE_OUTER_GAIN, val); }

	/*
		CONE INNER ANGLE
	*/
	public @property float ConeInnerAngle() {
		float v = 0f;
		alGetSourcef(Id, AL_CONE_INNER_ANGLE, &v);
		return v;
	}
	public @property void ConeInnerAngle(float val) { alSourcef(Id, AL_CONE_INNER_ANGLE, val); }

	/*
		CONE OUTER ANGLE
	*/
	public @property float ConeOuterAngle() {
		float v = 0f;
		alGetSourcef(Id, AL_CONE_OUTER_ANGLE, &v);
		return v;
	}
	public @property void ConeOuterAngle(float val) { alSourcef(Id, AL_CONE_OUTER_ANGLE, val); }

	/*
		REFERENCE DISTANCE
	*/
	public @property float ReferenceDistance() {
		float v = 0f;
		alGetSourcef(Id, AL_REFERENCE_DISTANCE, &v);
		return v;
	}
	public @property void ReferenceDistance(float val) { alSourcef(Id, AL_REFERENCE_DISTANCE, val); }

	/*
		POSITION
	*/
	public @property Vector3 Position() {
		Vector3 v = 0f;
		alGetSourcefv(Id, AL_POSITION, v.data.ptr);
		return v;
	}
	public @property void Position(Vector3 val) { alSourcefv(Id, AL_POSITION, val.data.ptr); }

	/*
		VELOCITY
	*/
	public @property Vector3 Velocity() {
		Vector3 v = 0f;
		alGetSourcefv(Id, AL_VELOCITY, v.data.ptr);
		return v;
	}
	public @property void Velocity(Vector3 val) { alSourcefv(Id, AL_VELOCITY, val.data.ptr); }

	/*
		DIRECTION
	*/
	public @property Vector3 Direction() {
		Vector3 v = 0f;
		alGetSourcefv(Id, AL_DIRECTION, v.data.ptr);
		return v;
	}
	public @property void Direction(Vector3 val) { alSourcefv(Id, AL_DIRECTION, val.data.ptr); }

	/*
		LOOPING
	*/
	public @property bool Looping() {
		int v = 0;
		alGetSourcei(Id, AL_LOOPING, &v);
		return (v == 1);
	}
	public @property void Looping(bool val) { alSourcei(Id, AL_LOOPING, cast(int)val); }

	public @property int ByteOffset() {
		int v = 0;
		alGetSourcei(Id, AL_BYTE_OFFSET, &v);
		return v;
	}

	public @property int SecondOffset() {
		int v = 0;
		alGetSourcei(Id, AL_SEC_OFFSET, &v);
		return v;
	}

	public @property int SampleOffset() {
		int v = 0;
		alGetSourcei(Id, AL_SAMPLE_OFFSET, &v);
		return v;
	}

	/*
		BUFFER
	*/
	public @property ALBuffer Buffer() {
		return this.currbuff;
	}
	public @property void Looping(ALBuffer val) { 
		alSourcei(Id, AL_BUFFER, cast(int)val.ALBuff);
		this.currbuff = val;
	}

	this(ALBuffer buff, AudioDevice dev = DefaultAudioDevice) {
		this(dev);
		this.currbuff = buff;
		alSourcei(this.Id, AL_BUFFER, this.currbuff.ALBuff);
	}

	this(AudioDevice dev = DefaultAudioDevice) {
		this.HostDevice = dev;
		alGenSources(1, &this.id);
	}

	~this() {
		alDeleteSources(1, &this.id);
	}

	public bool IsPlaying() {
		ALenum state;
		alGetSourcei(this.id, AL_SOURCE_STATE, &state);
		return (state == AL_PLAYING);
	}

	public void Play(bool looping, Vector3 position = Vector3.Zero) {
		this.Looping = looping;
		Listener.Position = position;
		Play();
	}

	public void Play() {
		alSourcePlay(this.id);
	}

	public void Pause() {
		alSourcePause(this.id);
	}
	
	public void Stop() {
		alSourceStop(this.id);
	}

	public void Rewind() {
		alSourceRewind(this.id);
	}
}