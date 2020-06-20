#include <stdio.h>
#include <stdlib.h>

using namespace std;

// ===================================
// DECLARATION
// ===================================

double
  a_re[32][32] = {0}, a_im[32][32] = {0},
  b_re[32][32] = {0}, b_im[32][32] = {0},
  c_re[32][32] = {0}, c_im[32][32] = {0};
double zero_mat[32][32] = {0};
int wa, ha, wb, hb, wc, hc;

void read_matrix  (FILE* f, double mat[][32], int *w, int *h);
void write_matrix (FILE *f, const double mat[][32], const int w, const int h);
void print_matrix (const double mat[][32], const int w, const int h);
void write_ip     (const int w, const int h);
void write_bramre (const double mat[][32], const int w, const int h);
void write_bramim (const double mat[][32], const int w, const int h);
void read_bramre  (double mat[][32], const int w, const int h);
void read_bramim  (double mat[][32], const int w, const int h);
int double2int32  (const double d);
double int2double (const int n);
void test_casting (void);
int setBitNumber(int n);

int main (void)
{
  // ===================================
  // INITIALIZATION
  // ===================================

  FILE *fa, *fb, *fc_re, *fc_im;
  
  fa = fopen ("mat-a.in",  "r");
  fb = fopen ("mat-b.in",  "r");
  fc_re = fopen ("mat-c-re.out", "w");
  fc_im = fopen ("mat-c-im.out", "w");

  // ===================================
  // CONVOLUTION
  // ===================================

  read_matrix (fa, a_re, &wa, &ha);
  read_matrix (fb, b_re, &wb, &hb);

  printf("input a_re = \n");
  print_matrix(a_re, wa, ha);
  printf("\ninput b_re = \n");
  print_matrix(a_im, wa, ha);

  printf("\nStarting fft2 over A.\n");
  write_bramre (a_re, wa, ha);
  write_bramim (zero_mat, wa, ha);
  write_ip (wa, ha);
  read_bramre(a_re, wa, ha);
  read_bramim(a_im, wa, ha);

  printf("a_re = \n");
  print_matrix(a_re, wa, ha);
  printf("\na_im = \n");
  print_matrix(a_im, wa, ha);

  printf("\nStarting fft2 over B.\n");
  write_bramre (b_re, wb, hb);
  write_bramim (zero_mat, wb, hb);
  write_ip (wb, hb);
  read_bramre(b_re, wb, hb);
  read_bramim(b_im, wb, hb);

  printf("b_im = \n");
  print_matrix(b_re, wb, hb);
  printf("\nb_im = \n");
  print_matrix(b_im, wb, hb);

  wc = setBitNumber(wa+wb-1);
  hc = setBitNumber(ha+hb-1);

  // printf ("wc = %d, hc = %d\n", wc, hc);

  for (int i = 0; i < hc; ++i)
    for (int j = 0; j < wc; ++j)
      {
        c_re[i][j] = a_re[i][j] * b_re[i][j] - a_im[i][j] * b_im[i][j];
        c_im[i][j] = - (a_re[i][j] * b_im[i][j] + a_im[i][j] * b_re[i][j]);
      }

  printf("\nStarting fft2 over C.\n");
  write_bramre (c_re, wc, hc);
  write_bramim (c_im, wc, hc);
  write_ip (wc, hc);
  read_bramre(c_re, wc, hc);
  read_bramim(c_im, wc, hc);

  printf("c_re = \n");
  print_matrix(c_re, wc, hc);
  printf("\nc_im = \n");
  print_matrix(c_im, wc, hc);

  write_matrix(fc_re, c_re, wc, hc);
  write_matrix(fc_im, c_im, wc, hc);

  // ===================================
  // CLOSING
  // ===================================

  fclose (fa);
  fclose (fb);
  fclose (fc_re);
  fclose (fc_im);
  return 0;
}

void read_matrix (FILE* f, double mat[][32], int *w, int *h)
{
  fscanf (f, "%d %d", w, h);
  for (int i = 0; i < (*h); ++i)
    for (int j = 0; j < (*w); ++j)
      fscanf (f, "%lf", &mat[i][j]);
}

void write_matrix (FILE *f, const double mat[][32], const int w, const int h)
{
  for (int i = 0; i < h; ++i)
    for (int j = 0; j <= w; ++j)
      if (j != w)
        fprintf (f, "%lf ", mat[i][j]);
      else
        fprintf (f, "\n");
}

void write_ip (const int w, const int h)
{
  FILE *fft2;
  fft2 = fopen ("/dev/xlnx,fft2", "w");
  fprintf (fft2, "%d, %d \n", w, h);
  printf ("[APP] %d, %d \n", w, h);
  fclose (fft2);
}

void write_bramre(const double mat[][32], const int w, const int h)
{
  FILE *bramre;
  for (int i = 0; i < h; ++i)
    for (int j = 0; j < w; ++j)
      {
        bramre = fopen ("/dev/xlnx,bram_re", "w");
        fprintf(bramre, "%d, %d\n", i*w+j, double2int32(mat[i][j]));
        fclose (bramre);
      }
}

void write_bramim(const double mat[][32], const int w, const int h)
{
  FILE *bramim;
  for (int i = 0; i < h; ++i)
    for (int j = 0; j < w; ++j)
      {
        bramim = fopen ("/dev/xlnx,bram_im", "w");
        fprintf(bramim, "%d, %d\n", i*w+j, double2int32(mat[i][j]));
        fclose (bramim);
      }
}

void read_bramre(double mat[][32], const int w, const int h)
{
  FILE *bramre;
  bramre = fopen ("/dev/xlnx,bram_re", "r");
  int n;
  for (int i = 0; i < h; ++i)
    for (int j = 0; j < w; ++j)
      {
        fscanf (bramre, "%d", &n);
        mat[i][j] = int2double(n);
      }
  fclose (bramre);
}

void read_bramim(double mat[][32], const int w, const int h)
{
  FILE *bramim;
  bramim = fopen ("/dev/xlnx,bram_im", "r");
  int n;
  for (int i = 0; i < h; ++i)
    for (int j = 0; j < w; ++j)
      {
        fscanf (bramim, "%d", &n);
        mat[i][j] = int2double(n);
      }
  fclose (bramim);
}

int double2int32 (const double d)
{
  double dd = d;
  dd *= 1 << 16;
  return (int) dd;
}

double int2double (const int n)
{
  double d = (double) n;
  d /= 1<<16;
  return d;
}

void test_casting (void)
{
  double d = 1.0;
  printf("double = %d\n", double2int32(d));
  d = -1.0;
  printf("double = %d\n", double2int32(d));

  int n = 65536;
  printf("int = %lf\n", int2double(n));

  n = 655360;
  printf("int = %lf\n", int2double(n));

  n = 131072;
  printf("int = %lf\n", int2double(n));

  n = -131072;
  printf("int = %lf\n", int2double(n));

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

void print_matrix (const double mat[][32], const int w, const int h)
{
  for (int i = 0; i < h; ++i)
    for (int j = 0; j <= w; ++j)
      if (j != w)
        printf ("%lf ", mat[i][j]);
      else
        printf("\n");
}
