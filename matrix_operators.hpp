#pragma once
#include<stdio.h>
#include<math.h>
#define PI 3.141592653589793238462643383279502884197

void inline alloc_matrix(int height, int width, double ***matrix){
  *matrix = new double *[height];
  for(int i = 0; i <height; i++)
    (*matrix)[i] = new double[width];
}

void inline copy_matrix(int height, int width, double **src, double **dest){
  for(int i = 0; i <height; i++)
    for (int j = 0; j <width; j++)
      dest[i][j] = src[i][j];
}

void inline print_matrix(int height, int width, double **matrix){
  for(int i = 0; i <height; i++){
    for (int j=0; j <width; j++)
      printf("%.2f ",(matrix)[i][j]);
    printf("\n");
  }
}
