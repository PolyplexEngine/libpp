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
    uint msLagTiming;
    size_t syncSource;

public:
    /**
        Creates a new SyncGroup which keeps Music instances synchronized.
        set msLagTiming to the timing you expect to be counting as lagg
        (as reference, 16 ms is 60 FPS)
        (default 500 (2 FPS))

        The first track in the group is the one that will be the sync source by default.
    */
    this(Music[] group, uint msLagTiming = 500) {
        this.group = group;
        this.msLagTiming = msLagTiming;
    }

    /// Sets the synchronization clock.
    void SetSyncSource(Music mus) {
        foreach(i; 0 .. group.length) {
            if (group[i] == mus) 
                syncSource = i;
        }
    }

    /// Call every frame to make sure that XRuns are handled.
    void Update() {
        // If Xruns have been unhandled.
        if (group[syncSource].XRuns > 0)
            Resync();
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