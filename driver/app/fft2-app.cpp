#include <stdio.h>
#include <stdlib.h>

using namespace std;

double a[32][32], b[32][32], c[32][32];
int wa, ha, wb, hb, wc, hc;

void read_matrix (FILE* f, double mat[][32], int *w, int *h);
void write_matrix (FILE *f, const double mat[][32], const int w, const int h);

int main (void)
{
  FILE *fa, *fb, *fc;
  fa = fopen ("mat-a.in",  "r");
  fb = fopen ("mat-b.in",  "r");
  fc = fopen ("mat-c.out", "w");

  read_matrix(fa, a, &wa, &ha);
  write_matrix(fc, a, wa, ha);

  fclose (fa);
  fclose (fb);
  fclose (fc);
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
        fprintf (f, "%lf ", mat[i][j]), printf ("%lf ", mat[i][j]);
      else
        fprintf (f, "\n"), printf("\n");
}
