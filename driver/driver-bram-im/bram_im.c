#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/interrupt.h>
#include <linux/irq.h>
#include <linux/platform_device.h>
#include <asm/io.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/io.h>

#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>

#include <linux/version.h>
#include <linux/types.h>
#include <linux/kdev_t.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>

#include <linux/delay.h>

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Driver for IMBRAM");
#define DEVICE_NAME "IMbram"
#define DRIVER_NAME "IMbram_driver"

#define MATRIX_HEIGHT 8
#define MATRIX_WIDTH 8

//*************************************************************************
static int IMbram_probe(struct platform_device *pdev);
static int IMbram_open(struct inode *i, struct file *f);
static int IMbram_close(struct inode *i, struct file *f);
static ssize_t IMbram_read(struct file *f, char __user *buf, size_t len, loff_t *off);
static ssize_t IMbram_write(struct file *f, const char __user *buf, size_t count, loff_t *off);
static int __init IMbram_init(void);
static void __exit IMbram_exit(void);
static int IMbram_remove(struct platform_device *pdev);

static int intToStr(int val, char *pBuf, int bufLen, int base);
static char chToUpper(char ch);
static unsigned long strToInt(const char* pStr, int len, int base);

//*********************GLOBAL VARIABLES*************************************
static struct file_operations IMbram_fops =
{
	.owner = THIS_MODULE,
	.open = IMbram_open,
	.release = IMbram_close,
	.read = IMbram_read,
	.write = IMbram_write
};
static struct of_device_id IMbram_of_match[] = {
	{ .compatible = "xlnx,bram_im", },     // TODO
	{ /* end of list */ },
};

static struct platform_driver IMbram_driver = {
	.driver = {
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.of_match_table	= IMbram_of_match,
	},
	.probe		= IMbram_probe,
	.remove	= IMbram_remove,
};

struct IMbram_info {
	unsigned long mem_start;
	unsigned long mem_end;
	void __iomem *base_addr;
};

static struct IMbram_info *vp = NULL;

MODULE_DEVICE_TABLE(of, IMbram_of_match);

static struct cdev c_dev;
static dev_t first;
dev_t dev_id;
struct cdev *my_cdev;
static struct class *cl;
static int int_cnt;

//***************************************************
// PROBE AND REMOVE

static int IMbram_probe(struct platform_device *pdev)
{
	struct resource *r_mem;
	int rc = 0;

	printk(KERN_INFO "Probing\n");

	r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!r_mem) {
		printk(KERN_ALERT "invalid address\n");
		return -ENODEV;
	}
	vp = (struct IMbram_info *) kmalloc(sizeof(struct IMbram_info), GFP_KERNEL);
	if (!vp) {
		printk(KERN_ALERT "Cound not allocate IMbram device\n");
		return -ENOMEM;
	}

	vp->mem_start = r_mem->start;
	vp->mem_end = r_mem->end;


	if (!request_mem_region(vp->mem_start,vp->mem_end - vp->mem_start + 1, DRIVER_NAME))
	{
		printk(KERN_ALERT "Couldn't lock memory region at %p\n",(void *)vp->mem_start);
		rc = -EBUSY;
		goto error1;
	}
	else {
		printk(KERN_INFO "IMbram_init: Successfully allocated memory region for IMbram\n");
	}
	/*
	 * Map Physical address to Virtual address
	 */

	vp->base_addr = ioremap(vp->mem_start, vp->mem_end - vp->mem_start + 1);
	if (!vp->base_addr) {
		printk(KERN_ALERT "IMbram: Could not allocate iomem\n");
		rc = -EIO;
		goto error2;
	}

	printk("probing done");
error2:
	release_mem_region(vp->mem_start, vp->mem_end - vp->mem_start + 1);
error1:
	return rc;

}

static int IMbram_remove(struct platform_device *pdev)
{
	// Exit Device Module
	iounmap(vp->base_addr);
	//release_mem_region(vp->mem_start, vp->mem_end - vp->mem_start + 1);
	return 0;
}

//***************************************************
// IMPLEMENTATION OF FILE OPERATION FUNCTIONS

static int IMbram_open(struct inode *i, struct file *f)
{
	//printk("IMbram opened\n");
	return 0;
}
static int IMbram_close(struct inode *i, struct file *f)
{
	//printk("IMbram closed\n");
	return 0;
}

static int intToStr(int val, char *pBuf, int bufLen, int base) {
  static const char *pConv = "0123456789ABCDEF";
  int num = val;
  int len = 0;
  int pos = 0;

  while (num > 0) {
    len++;
    num /= base;
  }

  if (val == 0) {
    len = 1;
  }

  pos = len - 1;
  num = val;

  if (pos > bufLen - 1) {
    pos = bufLen - 1;
  }

  for (; pos >= 0; pos--) {
    pBuf[pos] = pConv[num % base];
    num /= base;
  }

  return len;
}

int endRead = 0;
int pos = 0;
static ssize_t IMbram_read(struct file *f, char __user *buf, size_t len, loff_t *off)
{
	int ret;
	char temp_array[100];
	int length;
	if (endRead) {
		endRead = 0;
		pos = 0;
		printk(KERN_INFO "Succesfully read from file\n");
		return 0;
	}
	length = intToStr(ioread32(vp->base_addr + (pos*4)), temp_array, 100, 10);
	temp_array[length] = ',';
	length++;
	ret=copy_to_user(buf, temp_array, length);
	pos ++;
	if (pos == MATRIX_HEIGHT * MATRIX_WIDTH * 2) {
		endRead = 1;
	}
	return length;
}

static ssize_t IMbram_write(struct file *f, const char __user *buf, size_t count, loff_t *off)
{
	int val_tmp = 0;
	int val_rd = 0;
	char buffer[count];

pos = 0;
	char *lp='\0';
	char *rp='\0';
	int i = 0;
  int ret = 0;
	unsigned int val=0;
	ret = copy_from_user(buffer, buf, count);
	buffer[count - 1] = '\0';


	//extract position on x axis
	lp = buffer;
  while(rp != (buffer + (count - 1))){
    rp = strchr(lp,',');
    if(!rp)
      {
        printk("I-nvalid input, expected format: xpos,ypos,rgb\n");
        return count;
      }
    *rp = '\0';
    rp++;

    val_tmp = strToInt(lp, strlen(lp), 10);

    iowrite32(val_tmp, vp->base_addr + (i*4));
    udelay(100);
    val_rd = ioread32(vp->base_addr + (i*4));
    printk("val_tmp %d \n", val_tmp);
    lp = rp;
    i++;

  }
	/* //extract position on y axis  */
	/* lp = rp; */
	/* rp = strchr(lp,','); */
	/* if(!rp) */
	/* { */
	/* 	printk("Invalid input, expected format: xpos,ypos,rgb\n"); */
	/* 	return count; */
	/* } */
	/* *rp = '\0'; */
	/* rp++; */

	/* if(lp[0]=='0' && lp[1]=='x') */
	/* { */
	/* 	lp=lp+2; */
	/* 	ypos = strToInt(lp, strlen(lp), 16); */
	/* } */
	/* else */
	/* 	ypos = strToInt(lp, strlen(lp), 10); */

	/* //extract rgb(red,green,blue) value of pixel  */
	/* lp = rp; */
	/* if(!lp) */
	/* { */
	/* 	printk("Invalid input, expected format: xpos,ypos,rgb\n"); */
	/* 	return count; */
	/* } */
	/* /\* if(lp[0]=='0' && lp[1]=='x') *\/ */
	/* /\* { *\/ */
	/* /\* 	lp=lp+2; *\/ */
	/* /\* 	rgb = strToInt(lp, strlen(lp), 16); *\/ */
	/* /\* } *\/ */
	/* /\* else *\/ */
	/* /\* 	rgb = strToInt(lp, strlen(lp), 10); *\/ */
  /* rgb = strToInt(lp, strlen(lp), 2); // everything is binarized */

	/* if (xpos>=MATRIX_WIDTH || ypos>=2*MATRIX_HEIGHT) */
	/* { */
	/* 	printk("position of pixel is out of bounds\n"); */
	/* 	return count; */
	/* } */

	//printk("X %d Y %d ADDR %d V %d \n",xpos,ypos,(256*ypos + xpos)*2,rgb);

	/* iowrite32((8*ypos + xpos)*4, vp->base_addr + 8); */
	/* iowrite32(rgb, vp->base_addr); */
	/* iowrite32(1, vp->base_addr); */
	/* iowrite32(2, vp->base_addr+4); */
	/* iowrite32(3, vp->base_addr+8); */
	/* iowrite32(4, vp->base_addr+12); */
	/* iowrite32(5, vp->base_addr+16); */
	/* iowrite32(6, vp->base_addr+20); */
	/* iowrite32(7, vp->base_addr+24); */
	/* iowrite32(8, vp->base_addr+28); */
	/* iowrite32(9, vp->base_addr+32); */

  /* udelay(1000); */

	/* val_tmp = ioread32(vp->base_addr); */
	/* printk("val_tmp %d \n", val_tmp); */
	/* val_tmp = ioread32(vp->base_addr+4); */
	/* printk("val_tmp %d \n", val_tmp); */
	/* val_tmp = ioread32(vp->base_addr+8); */
	/* printk("val_tmp %d \n", val_tmp); */
	/* val_tmp = ioread32(vp->base_addr+12); */
	/* printk("val_tmp %d \n", val_tmp); */
	/* val_tmp = ioread32(vp->base_addr+16); */
	/* printk("val_tmp %d \n", val_tmp); */
	/* val_tmp = ioread32(vp->base_addr+20); */
	/* printk("val_tmp %d \n", val_tmp); */
	/* val_tmp = ioread32(vp->base_addr+24); */
	/* printk("val_tmp %d \n", val_tmp); */
	/* val_tmp = ioread32(vp->base_addr+28); */
	/* printk("val_tmp %d \n", val_tmp); */
	/* val_tmp = ioread32(vp->base_addr+32); */
	/* printk("val_tmp %d \n", val_tmp); */


	//printk("Sucessfull write \n");
	return count;

}

//***************************************************
// HELPER FUNCTIONS (STRING TO INTEGER)


static char chToUpper(char ch)
{
	if((ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9'))
	{
		return ch;
	}
	else
	{
		return ch - ('a'-'A');
	}
}

static unsigned long strToInt(const char* pStr, int len, int base)
{
	//                      0,1,2,3,4,5,6,7,8,9,:,;,<,=,>,?,@,A ,B ,C ,D ,E ,F
	static const int v[] = {0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0,0,10,11,12,13,14,15};
	int i   = 0;
	unsigned long val = 0;
	int dec = 1;
	int idx = 0;

	for(i = len; i > 0; i--)
	{
		idx = chToUpper(pStr[i-1]) - '0';

		if(idx > sizeof(v)/sizeof(int))
		{
			printk("strToInt: illegal character %c\n", pStr[i-1]);
			continue;
		}

		val += (v[idx]) * dec;
		dec *= base;
	}

	return val;
}


//***************************************************
// INIT AND EXIT FUNCTIONS OF THE DRIVER

static int __init IMbram_init(void)
{
        
        int_cnt = 0;
        
        printk(KERN_INFO "IMbram_init: Initialize Module \"%s\"\n", DEVICE_NAME);
        
        if (alloc_chrdev_region(&first, 0, 1, "BRAMIM_region") < 0)
        {       
                printk(KERN_ALERT "<1>Failed CHRDEV!.\n");
                return -1;
        }
        printk(KERN_INFO "Succ CHRDEV!.\n");
        
        if ((cl = class_create(THIS_MODULE, "chardrv")) == NULL)
        {       
                printk(KERN_ALERT "<1>Failed class create!.\n");
                goto fail_0;
        }
        printk(KERN_INFO "Succ class chardev1 create!.\n");
        if (device_create(cl, NULL, MKDEV(MAJOR(first),0), NULL, "IMbram") == NULL)
        {       
                goto fail_1;
        }
        
        printk(KERN_INFO "Device created.\n");
        
        cdev_init(&c_dev, &IMbram_fops);
        if (cdev_add(&c_dev, first, 1) == -1)
        {       
                goto fail_2;
        }
        
        printk(KERN_INFO "Device init.\n");
        
        return platform_driver_register(&IMbram_driver);

fail_2: 
        device_destroy(cl, MKDEV(MAJOR(first),0));
fail_1: 
        class_destroy(cl);
fail_0: 
        unregister_chrdev_region(first, 1);
        return -1;
}

static void __exit IMbram_exit(void)
{

	platform_driver_unregister(&IMbram_driver);
	cdev_del(&c_dev);
	device_destroy(cl, MKDEV(MAJOR(first),0));
	unregister_chrdev_region(dev_id,1);
	cdev_del(my_cdev);
	class_destroy(cl);
	unregister_chrdev_region(first, 1);
	printk(KERN_INFO "IMbram_exit: Exit Device Module \"%s\".\n", DEVICE_NAME);
}

module_init(IMbram_init);
module_exit(IMbram_exit);

MODULE_AUTHOR ("FTN");
MODULE_DESCRIPTION("Test Driver for IMBRAM output.");
MODULE_LICENSE("GPL v2");
MODULE_ALIAS("custom:IMbram");
