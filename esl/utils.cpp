#include "utils.hpp"

char flip(char c) {return (c == '0')? '1': '0';}

string twos_complement(string bin)
{
  int n = bin.length();
  int i;

  string ones, twos;
  ones = twos = "";

  //  for ones complement flip every bit
  for (i = 0; i < n; i++)
    ones += flip(bin[i]);

  //  for two's complement go from right to left in
  //  ones complement and if we get 1 make, we make
  //  them 0 and keep going left when we get first
  //  0, make that 1 and go out of loop
  twos = ones;
  for (i = n - 1; i >= 0; i--)
    {
      if (ones[i] == '1')
        twos[i] = '0';
      else
        {
          twos[i] = '1';
          break;
        }
    }

  // If No break : all are 1  as in 111  or  11111;
  // in such case, add extra 1 at beginning
  if (i == -1)
    twos = '1' + twos;

  // cout << "1's complement: " << ones << endl;
  // cout << "2's complement: " << twos << endl; 
  return twos;
}

double to_fixed (unsigned char *buf)
{
  string concated = "";
  for (int i = 0; i<CHARS_AMOUNT; ++i) // concatenate char array into eg. "10101101000"
    concated += bitset<CHAR_LEN>((int)buf[i]).to_string();
  // cout << "concated = " << concated << endl;
  double multiplier = 1;
  if (concated[0] == '1')
    {
      concated = twos_complement(concated);
      multiplier = -1;
    }
  // cout << "concated = " << concated << endl;
  double sum = 0;
  for (int i = 0; i<DATA_WIDTH; ++i)
    {
      // cout << "[" << i << "] sum = " << sum << endl;
      sum += (concated[i]-'0') * pow(2.0, DATA_WIDTH - FIXED_POINT_WIDTH - i - 1);
    }
  // cout << "sum = " << sum << endl;
  return sum*multiplier;
}

void to_char (unsigned char *buf, string s)
{
  s.erase(0,2); // remove "0b"
  s.erase(DATA_WIDTH-FIXED_POINT_WIDTH, 1); // remove the dot
  char single_char[CHAR_LEN];
  for (int i = 0; i<CHARS_AMOUNT; ++i)
    {
      s.copy(single_char,CHAR_LEN,i*CHAR_LEN); // copy 8 letters (0s and 1s) to char array
      int char_int = stoi(single_char, nullptr, 2); // binary string -> int
      buf[i] = (unsigned char) char_int;
    }
}

void to_uchar(unsigned char *c, num_t d)
{
  to_char(c,d.to_bin());
}

// fix_t to_fixed (unsigned char *buf)
// {
//   int val_i;
//   double val_d;
//   fix_t val(DATA_WIDTH, FIXED_POINT_WIDTH);
//   for (unsigned i = 0; i != CHARS_AMOUNT; ++i)
//     {
//       val_i += (int)buf[i] << (CHAR_LEN * (CHARS_AMOUNT - 1 - i));
//     }
//   val_d = (double)val_i;
//   val = val_d;
//   val  >>= FIXED_POINT_WIDTH;
//   return val;
// }

// void to_char (unsigned char *buf, fix_t val)
// {
//   for (unsigned i = 0; i != CHARS_AMOUNT; ++i)
//     {
//       buf[i] = (char)val >> (CHAR_LEN * (CHARS_AMOUNT - 1 - i));
//     }
// }

int to_int (unsigned char *buf)
{
  int sum = 0;
  sum += ((int)buf[0]) << 24;
  sum += ((int)buf[1]) << 16;
  sum += ((int)buf[2]) << 8;
  sum += ((int)buf[3]);
  return sum;
}

void to_uchar (unsigned char *buf, int d)
{
  buf[0] = (char) (d >> 24);
  buf[1] = (char) (d >> 16);
  buf[2] = (char) (d >> 8);
  buf[3] = (char) (d);
}

int highest_bit(int n)
{
  int ret = 0;
  while (n>0) n>>=1,++ret;
  return ret;
}

int log(int n)
{
  // log(4) = 2
  // log(5) = 3
  // ...
  // log(8) = 3
  // log(9) = 4
  // ...
  int log_val = highest_bit(n) - 1;
  // std::cout << "pow = " << (1<<log_val) << " log = " << log_val << std::endl;
  if (1<<log_val != n) log_val+=1;
  return log_val;
}

// e.g. 1 001 001 010 -> 1 111 111 111 -> 10 000 000 000
int setBitNumber(int n)
{
  n |= n >> 1;
  n |= n >> 2;
  n |= n >> 4;
  n |= n >> 8;
  n |= n >> 16;
  n = n + 1;
  return n;
}
