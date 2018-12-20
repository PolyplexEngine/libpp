module polyplex.core.audio.syncgroup;
import polyplex.core.audio;
import polyplex.core;
import polyplex.utils.logging;

/**
    SyncGroup is a rudementary and naive form of audio synchronization for music channels.
    It's recommended to implement your own algorithm to handle this.
    Feel free to look at the source for some hints on how to do this.
*/
public class SyncGroup {
private:
    Music[] group;
    size_t syncSource;
    size_t combinedXruns;

public:
    /**
        Creates a new SyncGroup which keeps Music instances synchronized.
        The first track in the group is the one that will be the sync source by default.
    */
    this(Music[] group) {
        this.group = group;
    }

    /// Sets the synchronization source
    void SetSyncSource(Music mus) {
        foreach(i; 0 .. group.length) {
            if (group[i] == mus) 
                syncSource = i;
        }
    }

    /// Call every frame to make sure that XRuns are handled.
    void Update() {
        // If Xruns have been unhandled.
        if (combinedXruns > 0)
            Resync();
        
        combinedXruns = 0;
        foreach(audio; group) combinedXruns += audio.XRuns;
    }

    /// Resyncronizes audio tracks
    void Resync() {
        size_t sourceTell = group[syncSource].Tell;
        foreach(track; group) {
            if (track.Playing) track.Stop();
            track.Seek(sourceTell);
            track.HandledXRun();
        }

        // Once resynced, start again.
        foreach(track; group) track.Play();
        Logger.Debug("Resynced SyncGroup...");
    }

    /// Play all audio tracks in the sync group
    void Play() {
        foreach(track; group) track.Play();
    }

    /// Pause all audio tracks in the sync group
    void Pause() {
        foreach(track; group) track.Pause();
    }

    /// Stop all audio tracks in the sync group
    void Stop() {
        foreach(track; group) track.Stop();
    }

    /*
		PITCH
	*/
    @property void Pitch(float val) { 
        foreach(track; group) 
            track.Pitch = val; 
    }

	/*
		GAIN
	*/
    @property void Gain(float val) { 
        foreach(track; group) 
            track.Gain = val; 
    }
}