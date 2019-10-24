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
MODULE_DESCRIPTION("Driver for DRIVERIP");
#define DEVICE_NAME "driver_ip"
#define DRIVER_NAME "driver_ip_driver"

#define MATRIX_HEIGHT 8
#define MATRIX_WIDTH 8

//*************************************************************************
static int driver_ip_probe(struct platform_device *pdev);
static int driver_ip_open(struct inode *i, struct file *f);
static int driver_ip_close(struct inode *i, struct file *f);
static ssize_t driver_ip_write(struct file *f, const char __user *buf, size_t count, loff_t *off);
static int __init driver_ip_init(void);
static void __exit driver_ip_exit(void);
static int driver_ip_remove(struct platform_device *pdev);

static int intToStr(int val, char *pBuf, int bufLen, int base);
static char chToUpper(char ch);
static unsigned long strToInt(const char* pStr, int len, int base);

//*********************GLOBAL VARIABLES*************************************
static struct file_operations driver_ip_fops =
{
	.owner = THIS_MODULE,
	.open = driver_ip_open,
	.release = driver_ip_close,
	.write = driver_ip_write
};
static struct of_device_id driver_ip_of_match[] = {
	{ .compatible = "xlnx,axil-bram-fft2-3.1", },     // TODO
	{ /* end of list */ },
};

static struct platform_driver driver_ip_driver = {
	.driver = {
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.of_match_table	= driver_ip_of_match,
	},
	.probe		= driver_ip_probe,
	.remove	= driver_ip_remove,
};

struct driver_ip_info {
	unsigned long mem_start;
	unsigned long mem_end;
	void __iomem *base_addr;
};

static struct driver_ip_info *vp = NULL;

MODULE_DEVICE_TABLE(of, driver_ip_of_match);

static struct cdev c_dev;
static dev_t first;
static struct class *cl;
static int int_cnt;

//***************************************************
// PROBE AND REMOVE

static int driver_ip_probe(struct platform_device *pdev)
{
	struct resource *r_mem;
	int rc = 0;

	printk(KERN_INFO "Probing\n");

	r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!r_mem) {
		printk(KERN_ALERT "invalid address\n");
		return -ENODEV;
	}
	vp = (struct driver_ip_info *) kmalloc(sizeof(struct driver_ip_info), GFP_KERNEL);
	if (!vp) {
		printk(KERN_ALERT "Cound not allocate driver_ip device\n");
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
		printk(KERN_INFO "driver_ip_init: Successfully allocated memory region for driver_ip\n");
	}
	/*
	 * Map Physical address to Virtual address
	 */

	vp->base_addr = ioremap(vp->mem_start, vp->mem_end - vp->mem_start + 1);
	if (!vp->base_addr) {
		printk(KERN_ALERT "driver_ip: Could not allocate iomem\n");
		rc = -EIO;
		goto error2;
	}

	printk("probing done");
error2:
	release_mem_region(vp->mem_start, vp->mem_end - vp->mem_start + 1);
error1:
	return rc;

}

static int driver_ip_remove(struct platform_device *pdev)
{
	// Exit Device Module
	iounmap(vp->base_addr);
	//release_mem_region(vp->mem_start, vp->mem_end - vp->mem_start + 1);
	return 0;
}

//***************************************************
// IMPLEMENTATION OF FILE OPERATION FUNCTIONS

static int driver_ip_open(struct inode *i, struct file *f)
{
	//printk("driver_ip opened\n");
	return 0;
}
static int driver_ip_close(struct inode *i, struct file *f)
{
	//printk("driver_ip closed\n");
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

static ssize_t driver_ip_write(struct file *f, const char __user *buf, size_t count, loff_t *off)
{
/*  
   int ret;
   char *lp='\0';
   char *rp='\0';
   int position;
   int value;
   char buffer[count];

	ret = copy_from_user(buffer, buf, count);
   buffer[count - 1] = '\0';
   printk("%s\n",buffer);
   lp = buffer;
   rp = strchr(buffer,',');

   position = strToInt(lp, strlen(lp), 10);
   value = strToInt(rp+1, strlen(rp+1), 10);

   iowrite32(value, vp->base_addr + position);
   udelay(1000);
 
   iowrite32(1, vp->base_addr + 0); 
   iowrite32(3, vp->base_addr + 4); 
   iowrite32(1, vp->base_addr + 8); 
   iowrite32(3, vp->base_addr + 12); 
   iowrite32(1, vp->base_addr + 16); 
   udelay(1000); 
   iowrite32(0, vp->base_addr + 16);
*/ 

  char buffer[count];
  char *lp='\0';
  char *rp='\0';
  int i = 0;
  unsigned int log2w=0,width=0,log2h=0,height=0;
  i = copy_from_user(buffer, buf, count);
  buffer[count - 1] = '\0';

  printk(KERN_ALERT "STARTING IP\n");
  printk(KERN_ALERT "buffer = %s\n", buffer);
// extract position on log2w 
	lp = buffer;
	rp = strchr(lp,',');
	if(!rp)
	{
		printk("Invalid input, expected format: log2w,width,log2h,height\n");
		return count;
	}
	*rp = '\0';
	rp++;
        log2w = strToInt(lp, strlen(lp), 10);

//extract position on width 
	lp = rp;
	rp = strchr(lp,',');
	if(!rp)
	{
		printk("Invalid input, expected format: log2w,width,log2h,height\n");
		return count;
	}
	*rp = '\0';
	rp++;
        width = strToInt(lp, strlen(lp), 10);

//extract position on log2h 
	lp = rp;
	rp = strchr(lp,',');
	if(!rp)
	{
		printk("Invalid input, expected format: log2w,width,log2h,height\n");
		return count;
	}
	*rp = '\0';
	rp++;
        log2h = strToInt(lp, strlen(lp), 10);

//extract position on height 
	lp = rp;
	if(!rp)
	{
		printk("Invalid input, expected format: log2w,width,log2h,height\n");
		return count;
	}
	*rp = '\0';
	rp++;
        height = strToInt(lp, strlen(lp), 10);

 iowrite32(log2w, vp->base_addr + 0); 
 iowrite32(width, vp->base_addr + 4); 
 iowrite32(log2h, vp->base_addr + 8); 
 iowrite32(height, vp->base_addr + 12); 

  iowrite32(1, vp->base_addr + 16); 
  udelay(1000); 
  iowrite32(0, vp->base_addr + 16); 

  printk(KERN_ALERT "finished: %d %d %d %d\n", log2w, width, log2h, height);
  printk("Writing to IP addr\n");
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

static int __init driver_ip_init(void)
{
        
        int_cnt = 0;
        
        printk(KERN_INFO "driver_ip_init: Initialize Module \"%s\"\n", DEVICE_NAME);
        
        if (alloc_chrdev_region(&first, 0, 1, "DRIVERIP_region") < 0)
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
        if (device_create(cl, NULL, MKDEV(MAJOR(first),0), NULL, "driver_ip") == NULL)
        {       
                goto fail_1;
        }
        
        printk(KERN_INFO "Device created.\n");
        
        cdev_init(&c_dev, &driver_ip_fops);
        if (cdev_add(&c_dev, first, 1) == -1)
        {       
                goto fail_2;
        }
        
        printk(KERN_INFO "Device init.\n");
        
        return platform_driver_register(&driver_ip_driver);

fail_2: 
        device_destroy(cl, MKDEV(MAJOR(first),0));
fail_1: 
        class_destroy(cl);
fail_0: 
        unregister_chrdev_region(first, 1);
        return -1;
}


static void __exit driver_ip_exit(void)
{

	platform_driver_unregister(&driver_ip_driver);
	cdev_del(&c_dev);
	device_destroy(cl, MKDEV(MAJOR(first),0));
	class_destroy(cl);
	unregister_chrdev_region(first, 1);
	printk(KERN_INFO "driver_ip_exit: Exit Device Module \"%s\".\n", DEVICE_NAME);
}

module_init(driver_ip_init);
module_exit(driver_ip_exit);

MODULE_AUTHOR ("FTN");
MODULE_DESCRIPTION("Test Driver for DRIVERIP output.");
MODULE_LICENSE("GPL v2");
MODULE_ALIAS("custom:driver_ip");
