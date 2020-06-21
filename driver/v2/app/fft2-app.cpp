#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

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
void write_ip     (const int wa, const int ha,
                   const int wb, const int hb);
void write_bramre (const double mata[][32], const double matb[][32],
                   const int wa, const int ha,
                   const int wb, const int hb);
void write_bramim (const double mata[][32], const double matb[][32],
                   const int wa, const int ha,
                   const int wb, const int hb);
void read_bramre  (double mata[][32], double matb[][32],
                   const int wa, const int ha,
                   const int wb, const int hb);
void read_bramim  (double mata[][32], double matb[][32],
                   const int wa, const int ha,
                   const int wb, const int hb);
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
  print_matrix(b_re, wb, hb);

  wc = setBitNumber(wa+wb-1);
  hc = setBitNumber(ha+hb-1);
  wa = wb = wc;
  ha = hb = hc;

  printf("\nStarting fft2 over A and B.\n");
  write_bramre (a_re, b_re, wa, ha, wb, hb);
  write_bramim (zero_mat, zero_mat, wa, ha, wb, hb);
  write_ip (wa, ha, wb, hb);
  read_bramre(a_re, b_re, wa, ha, wb, hb);
  usleep(1000);
  read_bramim(a_im, b_im, wa, ha, wb, hb);
  usleep(1000);

  printf("a_re = \n");
  print_matrix(a_re, wa, ha);
  printf("\na_im = \n");
  print_matrix(a_im, wa, ha);

  printf("b_im = \n");
  print_matrix(b_re, wb, hb);
  printf("\nb_im = \n");
  print_matrix(b_im, wb, hb);

  // printf ("wc = %d, hc = %d\n", wc, hc);

  for (int i = 0; i < hc; ++i)
    for (int j = 0; j < wc; ++j)
      {
        c_re[i][j] = a_re[i][j]*b_re[i][j] - a_im[i][j]*b_im[i][j];
        c_im[i][j] = - (a_re[i][j]*b_im[i][j] + a_im[i][j]*b_re[i][j]);
      }

  printf("\nStarting fft2 over C.\n");
  write_bramre (c_re, zero_mat, wc, hc, 0, 0);
  write_bramim (c_im, zero_mat, wc, hc, 0, 0);
  write_ip (wc, hc, 0, 0);
  read_bramre(c_re, zero_mat, wc, hc, 0, 0);
  read_bramim(c_im, zero_mat, wc, hc, 0, 0);

  for (int i = 0; i < hc; ++i)
    for (int j = 0; j < wc; ++j)
      {
        c_re[i][j] /= wc*hc;
        c_im[i][j] /= wc*hc;
      }

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

void write_ip (const int wa, const int ha, const int wb, const int hb)
{
  FILE *fft2;
  fft2 = fopen ("/dev/xlnx,fft2", "w");
  fprintf (fft2, "%d, %d, %d, %d\n", wa, ha, wb, hb);
  printf ("[APP] %d, %d, %d, %d \n", wa, ha, wb, hb);
  fclose (fft2);
}

void write_bramre(const double mata[][32], const double matb[][32],
                  const int wa, const int ha,
                  const int wb, const int hb)
{
  FILE *bramre;
  for (int i = 0; i < ha; ++i)
    for (int j = 0; j < wa; ++j)
      {
        bramre = fopen ("/dev/xlnx,bram_re", "w");
        fprintf(bramre, "%d, %d\n", i*wa+j, double2int32(mata[i][j]));
        fclose (bramre);
      }

  for (int i = 0; i < hb; ++i)
    for (int j = 0; j < wb; ++j)
      {
        bramre = fopen ("/dev/xlnx,bram_re", "w");
        fprintf(bramre, "%d, %d\n", i*wa+j+1024, double2int32(matb[i][j]));
        fclose (bramre);
      }
}

void write_bramim(const double mata[][32], const double matb[][32],
                  const int wa, const int ha,
                  const int wb, const int hb)
{
  FILE *bramim;
  for (int i = 0; i < ha; ++i)
    for (int j = 0; j < wa; ++j)
      {
        bramim = fopen ("/dev/xlnx,bram_im", "w");
        fprintf(bramim, "%d, %d\n", i*wa+j, double2int32(mata[i][j]));
        fclose (bramim);
      }

  for (int i = 0; i < hb; ++i)
    for (int j = 0; j < wb; ++j)
      {
        bramim = fopen ("/dev/xlnx,bram_im", "w");
        fprintf(bramim, "%d, %d\n", i*wa+j+1024, double2int32(matb[i][j]));
        fclose (bramim);
      }
}

void read_bramre(double mata[][32], double matb[][32],
                 const int wa, const int ha,
                 const int wb, const int hb)
{
  char endstr[100];
  FILE *bramre;
  bramre = fopen ("/dev/xlnx,bram_re", "r");
  int n;
  for (int i = 0; i < ha; ++i)
    for (int j = 0; j < wa; ++j)
      {
        fscanf (bramre, "%d", &n);
        mata[i][j] = int2double(n);
      }

  for (int i = 0; i < hb; ++i)
    for (int j = 0; j < wb; ++j)
      {
        fscanf (bramre, "%d", &n);
        matb[i][j] = int2double(n);
      }
  fgets(endstr, 100, bramre); // needed to simulate cat
  fgets(endstr, 100, bramre); // needed to simulate cat
  fclose (bramre);
}

void read_bramim(double mata[][32], double matb[][32],
                 const int wa, const int ha,
                 const int wb, const int hb)
{
  char endstr[100];
  FILE *bramim;
  bramim = fopen ("/dev/xlnx,bram_im", "r");
  int n;
  for (int i = 0; i < ha; ++i)
    for (int j = 0; j < wa; ++j)
      {
        fscanf (bramim, "%d", &n);
        mata[i][j] = int2double(n);
      }

  for (int i = 0; i < hb; ++i)
    for (int j = 0; j < wb; ++j)
      {
        fscanf (bramim, "%d", &n);
        matb[i][j] = int2double(n);
      }
  fgets(endstr, 100, bramim); // needed to simulate cat
  fgets(endstr, 100, bramim); // needed to simulate cat
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
