module polyplex.utils.sdlbool;
import derelict.sdl2.sdl;

bool FromSDL(SDL_bool b) {
	if (b == SDL_bool.SDL_TRUE) return true;
	return false;
}

SDL_bool ToSDL(bool b) {
	if (b) return SDL_bool.SDL_TRUE;
	return SDL_bool.SDL_FALSE;
}