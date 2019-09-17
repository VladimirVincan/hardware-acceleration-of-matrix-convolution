#ifndef _UTILS_HPP_
#define _UTILS_HPP_

#include <string>
#include <iostream>
#include <string.h>
#include <bitset>
#include <math.h>

using namespace std;

static const int MATRIX_SIZE = 64;
static const int DATA_WIDTH = 32;
static const int FIXED_POINT_WIDTH = 16;
static const int CHAR_LEN = 8;
static const int CHARS_AMOUNT = DATA_WIDTH / CHAR_LEN;
static const int RAM_SIZE = MATRIX_SIZE * MATRIX_SIZE * CHARS_AMOUNT;

double to_fixed (unsigned char *);
void to_char (unsigned char *, string);

#endif // _UTILS_HPP_
