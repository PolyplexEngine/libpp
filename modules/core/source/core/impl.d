module core.impl;
import core.surface;

/*
                Surface implementation details
*/
__gshared void delegate(ISurface surface, SurfaceBounds* bounds) handleSurfaceBoundsChange;
__gshared SurfaceBounds delegate(ISurface surface) handleSurfaceBoundsUpdate;
__gshared ISurface delegate() createNewSurface;