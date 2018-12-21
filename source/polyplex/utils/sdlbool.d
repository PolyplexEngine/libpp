module polyplex.utils.sdlbool;
import bindbc.sdl;

/**
	Converts an SDL_bool boolean in to an D boolean.
*/
bool FromSDL(SDL_bool b) {
	if (b == SDL_bool.SDL_TRUE) return true;
	return false;
}

/**
	Converts an D boolean in to an SDL_bool boolean.
*/
SDL_bool ToSDL(bool b) {
	if (b) return SDL_bool.SDL_TRUE;
	return SDL_bool.SDL_FALSE;
}