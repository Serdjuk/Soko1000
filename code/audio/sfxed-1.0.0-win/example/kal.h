#ifndef _SFX_H
#define _SFX_H

enum sfx_enum {
	// sfx
	SFX1 = 1,
	// sfx
	SFX2,
	// sfx
	SFX3,
	// sfx
	SFX4,
	// sfx
	SFX5,
	// sfx
	SFX6,
	// sfx
	SFX7,
};

const struct beeper_sfx sfx_table[] = {
	{ 1, 15, 60, 127, 2 },
	{ 1, 10, 40, 127, 3 },
	{ 1, 15, 20, 127, 0 },
	{ 1, 15, 20, 127, 5 },
	{ 1, 15, 40, 127, 6 },
	{ 1, 8, 60, 127, 7 },
	{ 2, 20, 255, 70, 0 },
};

#endif /* _SFX_H */
