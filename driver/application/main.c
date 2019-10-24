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

#define LOG2W_REG_ADDR 0
#define WIDTH_REG_ADDR 4
#define LOG2H_REG_ADDR 8
#define HEIGHT_REG_ADDR 12 
#define CMD_REG_ADDR 16
#define STATUS_REG_ADDR 20

#define FIXED_POINT_FRACTIONAL_BITS 16
#define MAX_FFT_SIZE 64
#define MAX_BRAM_BUFF 10000

int double2int(double input)
{
    if (input < 0) {
        return -(int)((-input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
    }
    return (int)((input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
}

double int2double(int input)
{
  if (input < 0) {
    return -(-((double)input) / pow(2,FIXED_POINT_FRACTIONAL_BITS));
  }
return (((double)input) / pow(2,FIXED_POINT_FRACTIONAL_BITS));
}

char *int2bin(int a, char *buffer, int buf_size) { // primarily used for debug
    buffer += (buf_size - 1);
    int i;
    for (i = 31; i >= 0; i--) {
        *buffer-- = (a & 1) + '0';
        a >>= 1;
    }
    return buffer;
}

int log2w, width, log2h, height;
int a_re[MAX_FFT_SIZE*MAX_FFT_SIZE],
  a_im[MAX_FFT_SIZE*MAX_FFT_SIZE];

void write_ip(int addr, int val)
{
  int fd, ret;
  char buffer[100];
  sprintf(buffer,"%d,%d",addr,val);
  fd = open("/dev/driver_ip", O_RDWR|O_NDELAY);
  ret = write(fd, buffer, strlen(buffer));
  if (ret < 0) {
    printf("write error to IP!\n");
  }
  close(fd);
}

char bram_buff[MAX_BRAM_BUFF];

void arr2str(int *a, int MAX_NUM)
{
	int i=0;
	int pos_a=0, pos_buff=0;
	char one_num[11];
  /* printf("%s",one_num); */
	for (pos_a=0;pos_a<MAX_NUM;++pos_a)
    {
      sprintf(one_num,"%d",a[pos_a]);
      for (i = 0; one_num[i]!='\0'; ++i)
        {
          bram_buff[pos_buff++] = one_num[i];
        }
      bram_buff[pos_buff++] = ',';
    }
	bram_buff[pos_buff++]='0';
	bram_buff[pos_buff]='\0';
}

void write_bram_re(int *a)
{
  printf("writing to BRAM RE!\n");
  int fd, ret;
  arr2str(a, width*height);
  fd = open("/dev/bramRE", O_RDWR|O_NDELAY);
  ret = write(fd, bram_buff, strlen(bram_buff));
  if (ret < 0)
    {
      printf("write error to BRAM RE!\n");
    }
  close(fd);
}

void read_bram_re(int *a)
{
  printf("reading from BRAM RE!\n");
  int fd, ret;
  arr2str(a, width*height);
  fd = open("/dev/bramRE", O_RDWR|O_NDELAY);
  int j;
  for(j = 0; j < width*height; j ++){
    ret = read(fd, bram_buff, 10);
  }
  close(fd);
}

void write_bram_im(int *a)
{
  printf("writing to BRAM IM!\n");
  int fd, ret;
  arr2str(a, width*height);
  fd = open("/dev/IMbram", O_RDWR|O_NDELAY);
  ret = write(fd, bram_buff, strlen(bram_buff));
  if (ret < 0)
    {
      printf("write error to BRAM IM!\n");
    }
  close(fd);
}

void read_bram_im(int *a)
{
  printf("reading from BRAM IM!\n");
  int fd, ret;
  arr2str(a, width*height);
  fd = open("/dev/IMbram", O_RDWR|O_NDELAY);
  int j;
  for(j = 0; j < width*height; j ++){
    ret = read(fd, bram_buff, 10);
  }
  close(fd);
}

int a_re_new[100];
int a_im_new[100];

int main(void)
{

  double image[]={
                 1.0, 0.0, 0.0, 0.0, // mat A
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0,

                 0.0, 0.0, 0.0, 0.0, // matB
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0
  };

  double image2[]={
                 0.0, 0.0, 0.0, 0.0, // matB
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0,

                 1.0, 2.0, 3.0, 4.0, // mat A
                 5.0, 6.0, 7.0, 8.0,
                 9.0, 10.0, 11.0, 12.0,
                 13.0, 14.0, 15.0, 16.0,

                 0.0, 0.0, 0.0, 0.0, // matB
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0,
                 0.0, 0.0, 0.0, 0.0
  };

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

  log2w = 2;
  width = 4;
  log2h = 2;
  height = 4;

  printf("Integer value is %d\n" , log2w);
  printf("Integer value is %d\n" , width);
  printf("Integer value is %d\n" , log2h);
  printf("Integer value is %d\n", height);

  /*
    ----------------------------
    write to IP
    ----------------------------
  */

 // write_ip(LOG2W_REG_ADDR,log2w-1);
 // write_ip(WIDTH_REG_ADDR,width-1);
 // write_ip(LOG2H_REG_ADDR,log2h-1);
 // write_ip(HEIGHT_REG_ADDR,height-1);

  printf("Wrote to IP\n");
  /*
    ----------------------------
    read vals
    ----------------------------
  */

  int i,j;
  for (i = 0; i < height; ++i)
    {
      for (j = 0; j < width; ++j)
        {
          a_re[i*width+j] = double2int(image[i*width+j]);
          a_im[i*width+j] = double2int(image2[i*width+j]);
        }
    }

  /*
    ----------------------------
    write to BRAM RE
    ----------------------------
  */

  write_bram_re(a_re);
  write_bram_im(a_im);

  printf("Wrote to BRAM\n");
  /*
    ----------------------------
    start IP
    ----------------------------
  */

//  write_ip(CMD_REG_ADDR,1);
//  write_ip(CMD_REG_ADDR,0);

  printf("Started IP\n");
  /*
    ----------------------------
    read from BRAM RE
    ----------------------------
  */

  read_bram_re(a_re_new);
  read_bram_im(a_im_new);

  printf("Read from bram\n");
  /*
    ----------------------------
    cout the matrix
    ----------------------------
  */
 
printf("tamaraa\n");
  for (i=0;i<height;++i)
	{
		for( j=0;j<width;++j){
			printf("%d %d\n", a_re_new[i*width+j],a_im_new[i*width+j]);
}
}

  printf("Printing results\n");
  for (i = 0; i < height; ++i)
    {
      for (j = 0; j < width; ++j)
        {
          printf("%f %f\n", int2double(a_re_new[i*width+j]), int2double(a_im_new[i*width+j]));
        }
    }

	return 0;
}

