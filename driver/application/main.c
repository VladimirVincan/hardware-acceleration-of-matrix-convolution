#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>
#include <stdint.h>
#include <math.h>

#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <fcntl.h>
#include <sys/mman.h>
#include <errno.h> 

#define LOG2W_REG_ADDR 0x00
#define WIDTH_REG_ADDR 0x04
#define LOG2H_REG_ADDR 0x08
#define HEIGHT_REG_ADDR 0x0c
#define CMD_REG_ADDR 0x10
#define STATUS_REG_ADDR 0x14

typedef int32_t fixed_point_t;
#define FIXED_POINT_FRACTIONAL_BITS 16
/*
fixed_point_t double2int(double input)
{
    if (input < 0) {
        printf("here\n");
        return -(fixed_point_t)(round(-input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
    }
    return (fixed_point_t)(round(input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
}

char *int2bin(fixed_point_t a, char *buffer, int buf_size) {
    buffer += (buf_size - 1);
    for (int i = 31; i >= 0; i--) {
        *buffer-- = (a & 1) + '0';
        a >>= 1;
    }
    return buffer;
}
*/
int main(void)
{
//float image[]={4,4,4,4, 15.4736, 8.30876, 11.0691 , 10.1429 ,14.3318, 11.8821, 18.4516 ,5.40088 ,2.55646 ,2.90927, 4.63963 ,2.93407, 2.6015 ,19.5911, 9.71343, 5.299531,5.4736, 8.30876, 11.0691 , 10.1429 ,14.3318, 11.8821, 18.4516 ,5.40088 ,2.55646 ,2.90927, 4.63963 ,2.93407, 2.6015 ,19.5911, 9.71343, 5.29953
//};

  double image[]={
                 1.0, 0.0, 0.0, 0.0, // mat A
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0,

                 1.0, 0.0, 0.0, 0.0, // matB
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0
  };
char niz[] = "21,22,23,24,25,26,27,28,29,30,31,32,33,34,36,37,38";

	FILE* fp;
	int x,y;
	int log2w = 2, width = 4, log2h = 2, height = 4;

  // TEST for int2bin and double2int
  /* char c[33]; */
  /* c[32] = '\0'; */
  /* int2bin(float_to_fixed(0.5),c, 32); */
  /* printf("%s\n", c); */
  /* int2bin(float_to_fixed(-0.5),c, 32); */
  /* printf("%s\n", c); */
  /* int2bin(float_to_fixed(1.0),c, 32); */
  /* printf("%s\n", c); */

  /*
    ----------------------------
    extract height and width
    ----------------------------
  */

  /* log2w  = image[0]; */
  /* width  = image[1]; */
  /* log2h  = image[2]; */
  /* height = image[3]; */

  //printf("Integer value is %d\n" , log2w);
  //printf("Integer value is %d\n" , width);
  //printf("Integer value is %d\n" , log2h);
  //printf("Integer value is %d\n", height);

  /*
    ----------------------------
    write to IP
    ----------------------------
  */

/*
  	fp = fopen("/dev/vga", "w"); // where to write to?
   if(fp == NULL)
     {
         printf("Cannot open /dev/vga for write\n");
         return -1;
     }
   fprintf(fp, "%d", LOG2W_ADDR_REG, log2w-1);
   fclose(fp);

  	fp = fopen("/dev/vga", "w"); // where to write to?
   if(fp == NULL)
     {
         printf("Cannot open /dev/vga for write\n");
         return -1;
     }
   fprintf(fp, "%d", WIDTH_ADDR_REG, width-1);
   fclose(fp);

  	fp = fopen("/dev/vga", "w"); // where to write to?
   if(fp == NULL)
     {
         printf("Cannot open /dev/vga for write\n");
         return -1;
     }
   fprintf(fp, "%d", LOG2H_ADDR_REG, log2h-1);
   fclose(fp);

  	fp = fopen("/dev/vga", "w"); // where to write to?
   if(fp == NULL)
     {
         printf("Cannot open /dev/vga for write\n");
         return -1;
     }
   fprintf(fp, "%d", HEIGHT_ADDR_REG, height-1);
   fclose(fp);
*/
  /*
    ----------------------------
    write to BRAM RE - values from file
    ----------------------------
  */
int fd;
int ret;
fd = open("/dev/bramRE", O_RDWR|O_NDELAY);
char buff[1024];


ret = write(fd, niz, strlen(niz));
  if (ret < 0) {
    printf("write error!\n");
    ret = errno;
    return 0;
  }
close(fd);

fd = open("/dev/bramRE", O_RDWR|O_NDELAY);
      printf("after write \n");

int j;
for(j = 0; j < 64; j ++){
    ret = read(fd, buff, 10);
    printf("%s \n", buff);
}
close(fd);

/*
  for (y=0; y<height; ++y)
    {
      for (x=0; x<width; ++x)
        {
          fp = fopen("/dev/vga", "w");
          if (fp == NULL)
            {
              printf("Cannot open /dev/vga for write\n");
              return -1;
            }
          fprintf(fp, "%d,%d,%#04x\n", x, y, double2int(image[y*width+x]) );
          fclose(fp);
          if (fp == NULL)
            {
              printf("Cannot close /dev/vga for write\n");
              return -1;
            }
        }
    }
*/
  /*
    ----------------------------
    write to BRAM IM - all zeros
    ----------------------------
  */
/*
  for (y=0; y<height; ++y)
    {
      for (x=0; x<width; ++x)
        {
          fp = fopen("/dev/vga", "w");
          if (fp == NULL)
            {
              printf("Cannot open /dev/vga for write\n");
              return -1;
            }
          fprintf(fp, "%d,%d,%#04x\n", x, y, 0 );
          fclose(fp);
          if (fp == NULL)
            {
              printf("Cannot close /dev/vga for write\n");
              return -1;
            }
        }
    }
*/
	return 0;
}

