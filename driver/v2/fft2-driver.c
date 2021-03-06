#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/module.h>
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

MODULE_AUTHOR("Vladimir Vincan");
MODULE_LICENSE("Dual BSD/GPL");
MODULE_DESCRIPTION("FFT2 IP core driver");

#define DRIVER_NAME "FFT2"

// ------------------------------------------
// DECLARATIONS
// ------------------------------------------

static dev_t my_dev_id;
static struct class *my_class;
static struct cdev  *my_cdev;

static int fft2_probe     (struct platform_device *pdev);
static int fft2_remove    (struct platform_device *pdev);
static int fft2_open      (struct inode *pinode, struct file *pfile);
static int fft2_close     (struct inode *pinode, struct file *pfile);
static ssize_t fft2_read  (struct file *pfile, char __user *buffer, size_t length, loff_t *offset);
static ssize_t fft2_write (struct file *pfile, const char __user *buffer, size_t length, loff_t *offset);

static int  __init fft2_init(void);
static void __exit fft2_exit(void);

struct device_info
{
  unsigned long mem_start;
  unsigned long mem_end;
  void __iomem *base_addr;
};

static struct device_info *fft2    = NULL;
static struct device_info *bram_re = NULL;
static struct device_info *bram_im = NULL;

static struct of_device_id device_of_match[] = {
  { .compatible = "xlnx,fft2", },
  { .compatible = "xlnx,bram_re", },
  { .compatible = "xlnx,bram_im", },
  { /* end of list */ }
};

MODULE_DEVICE_TABLE(of, device_of_match);

static struct platform_driver my_driver = {
  .driver = {
    .name = DRIVER_NAME,
    .owner = THIS_MODULE,
    .of_match_table	= device_of_match,
  },
  .probe = fft2_probe,
  .remove	= fft2_remove,
};

struct file_operations my_fops =
{
	.owner   = THIS_MODULE,
	.open    = fft2_open,
	.read    = fft2_read,
	.write   = fft2_write,
	.release = fft2_close,
};

// ------------------------------------------
// PROBE & REMOVE
// ------------------------------------------

int device_fsm = 0;

static int fft2_probe(struct platform_device *pdev)
{
  struct resource *r_mem;
  int rc = 0;
  r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!r_mem) {
		printk(KERN_ALERT "invalid address\n");
		return -ENODEV;
	}
  printk(KERN_INFO "Starting probing.\n");

  switch (device_fsm)
    {
    case 0: // device fft2
      fft2 = (struct device_info *) kmalloc(sizeof(struct device_info), GFP_KERNEL);
      if (!fft2)
        {
          printk(KERN_ALERT "Cound not allocate fft2 device\n");
          return -ENOMEM;
        }
      fft2->mem_start = r_mem->start;
      fft2->mem_end   = r_mem->end;
      if(!request_mem_region(fft2->mem_start, fft2->mem_end - fft2->mem_start+1, DRIVER_NAME))
        {
          printk(KERN_ALERT "Couldn't lock memory region at %p\n",(void *)fft2->mem_start);
          rc = -EBUSY;
          goto error1;
        }
      fft2->base_addr = ioremap(fft2->mem_start, fft2->mem_end - fft2->mem_start + 1);
      if (!fft2->base_addr)
        {
          printk(KERN_ALERT "[PROBE]: Could not allocate fft2 iomem\n");
          rc = -EIO;
          goto error2;
        }
      ++device_fsm;
      printk(KERN_INFO "[PROBE]: Finished probing fft2.\n");
      return 0;
      error2:
        release_mem_region(fft2->mem_start, fft2->mem_end - fft2->mem_start + 1);
      error1:
        return rc;
      break;

    case 1: // device bram_re
      bram_re = (struct device_info *) kmalloc(sizeof(struct device_info), GFP_KERNEL);
      if (!bram_re)
        {
          printk(KERN_ALERT "Cound not allocate bram_re device\n");
          return -ENOMEM;
        }
      bram_re->mem_start = r_mem->start;
      bram_re->mem_end   = r_mem->end;
      if(!request_mem_region(bram_re->mem_start, bram_re->mem_end - bram_re->mem_start+1, DRIVER_NAME))
        {
          printk(KERN_ALERT "Couldn't lock memory region at %p\n",(void *)bram_re->mem_start);
          rc = -EBUSY;
          goto error3;
        }
      bram_re->base_addr = ioremap(bram_re->mem_start, bram_re->mem_end - bram_re->mem_start + 1);
      if (!bram_re->base_addr)
        {
          printk(KERN_ALERT "[PROBE]: Could not allocate bram_re iomem\n");
          rc = -EIO;
          goto error4;
        }
      ++device_fsm;
      printk(KERN_INFO "[PROBE]: Finished probing bram_re.\n");
      return 0;
      error4:
        release_mem_region(bram_re->mem_start, bram_re->mem_end - bram_re->mem_start + 1);
      error3:
        return rc;
      break;

    case 2: // device bram_im
      bram_im = (struct device_info *) kmalloc(sizeof(struct device_info), GFP_KERNEL);
      if (!bram_im)
        {
          printk(KERN_ALERT "Cound not allocate bram_im device\n");
          return -ENOMEM;
        }
      bram_im->mem_start = r_mem->start;
      bram_im->mem_end   = r_mem->end;
      if(!request_mem_region(bram_im->mem_start, bram_im->mem_end - bram_im->mem_start+1, DRIVER_NAME))
        {
          printk(KERN_ALERT "Couldn't lock memory region at %p\n",(void *)bram_im->mem_start);
          rc = -EBUSY;
          goto error5;
        }
      bram_im->base_addr = ioremap(bram_im->mem_start, bram_im->mem_end - bram_im->mem_start + 1);
      if (!bram_im->base_addr)
        {
          printk(KERN_ALERT "[PROBE]: Could not allocate bram_im iomem\n");
          rc = -EIO;
          goto error6;
        }
      printk(KERN_INFO "[PROBE]: Finished probing bram_im.\n");
      return 0;
      error6:
        release_mem_region(bram_im->mem_start, bram_im->mem_end - bram_im->mem_start + 1);
      error5:
        return rc;
      break;

    default:
      printk(KERN_INFO "[PROBE] Device FSM in illegal state. \n");
      return -1;
    }
  printk(KERN_INFO "Succesfully probed driver\n");
  return 0;
}

static int fft2_remove(struct platform_device *pdev)
{
  switch (device_fsm)
    {
    case 0: //device fft2
      printk(KERN_ALERT "fft2 device platform driver removed\n");
      iowrite32(0, fft2->base_addr);
      iounmap(fft2->base_addr);
      release_mem_region(fft2->mem_start, fft2->mem_end - fft2->mem_start + 1);
      kfree(fft2);
      break;

    case 1: //device bram_re
      printk(KERN_ALERT "bram_re platform driver removed\n");
      iowrite32(0, bram_re->base_addr);
      iounmap(bram_re->base_addr);
      release_mem_region(bram_re->mem_start, bram_re->mem_end - bram_re->mem_start + 1);
      kfree(bram_re);
      --device_fsm;
      break;

    case 2: //device bram_im
      printk(KERN_ALERT "bram_im platform driver removed\n");
      iowrite32(0, bram_im->base_addr);
      iounmap(bram_im->base_addr);
      release_mem_region(bram_im->mem_start, bram_im->mem_end - bram_im->mem_start + 1);
      kfree(bram_im);
      --device_fsm;
      break;

    default:
      printk(KERN_INFO "[REMOVE] Device FSM in illegal state. \n");
      return -1;
    }
  printk(KERN_INFO "Succesfully removed driver\n");
  return 0;
}

// ------------------------------------------
// OPEN & CLOSE
// ------------------------------------------

static int fft2_open(struct inode *pinode, struct file *pfile)
{
		printk(KERN_INFO "Succesfully opened file\n");
		return 0;
}

static int fft2_close(struct inode *pinode, struct file *pfile)
{
		printk(KERN_INFO "Succesfully closed file\n");
		return 0;
}

// ------------------------------------------
// READ & WRITE
// ------------------------------------------

unsigned int log2wa=0, wa=0, log2ha=0, ha=0;
unsigned int log2wb=0, wb=0, log2hb=0, hb=0;
/* unsigned int log2w=0, width=0, log2h=0, height=0; */
#define BUFF_SIZE 40
int i = 0;
int end_read = 0;

unsigned int _log2(unsigned int n)
{
  if (n == 2)
    return (unsigned int)0;
  if (n == 4)
    return (unsigned int)1;
  if (n == 8)
    return (unsigned int)2;
  if (n == 16)
    return (unsigned int)3;
  if (n == 32)
    return (unsigned int)4;

  printk(KERN_ERR "Wrong input size\n");
  return (unsigned int)5;
}

ssize_t fft2_read(struct file *pfile, char __user *buffer, size_t length, loff_t *offset)
{
  char buf[BUFF_SIZE];
  long int len=0;
  u32 val;
  int minor = MINOR(pfile->f_inode->i_rdev);

  /* printk(KERN_INFO "FFT2 READ entered \n"); */
  printk(KERN_INFO "i = %d, len = %ld, end_read = %d\n", i, len, end_read);
  if (end_read == 1)
    {
      end_read = 0;
      return 0;
    }

  switch (minor)
    {
    case 0: //device fft2
      /* printk(KERN_INFO "i = %d\n", i);
         */
      printk(KERN_INFO "[READ] Succesfully read from fft2 device.\n");
      len = scnprintf(buf, BUFF_SIZE, "[READ] wa = %d, ha = %d, wb = %d, hb = %d\n", wa, ha, wb, hb);
      if (copy_to_user(buffer, buf, len))
        return -EFAULT;
      end_read = 1;
      break;

    case 1: //device bram_re
      val = ioread32(bram_re->base_addr + i*4);
      if (i < 1024)
      {
        if ((i+1) % (wa+1) == 0)
          len = scnprintf(buf, BUFF_SIZE, "%d\n", val);
        else
          len = scnprintf(buf, BUFF_SIZE, "%d ", val);
      }
      else
        {
          if ((i+1 - 1024) % (wb+1) == 0)
            len = scnprintf(buf, BUFF_SIZE, "%d\n", val);
          else
            len = scnprintf(buf, BUFF_SIZE, "%d ", val);
        }
      *offset += len;
      /* printk(KERN_INFO "%s", buf); */
      /* printk(KERN_INFO "i = %d, len = %ld\n", i, len); */
      if (copy_to_user(buffer, buf, len))
        {
          printk(KERN_ERR "Copy to user does not work.\n");
          return -EFAULT;
        }
      ++i;
      if (i == (wa+1) * (ha+1))
        {
          if (!wb || !hb)
            {
              printk(KERN_INFO "[READ] Succesfully read from bram_re device [single]\n");
              end_read = 1;
              i = 0;
            }
          else
            i = 1024;
        }
      else if (i == (wb+1) * (hb+1) + 1024)
        {
          printk(KERN_INFO "[READ] Succesfully read from bram_re device [dual]\n");
          end_read = 1;
          i = 0;
        }
      break;

    case 2: //device bram_im
      val = ioread32(bram_im->base_addr + i*4);
      if (i < 1024)
        {
          if ((i+1) % (wa+1) == 0)
            len = scnprintf(buf, BUFF_SIZE, "%d\n", val);
          else
            len = scnprintf(buf, BUFF_SIZE, "%d ", val);
        }
      else
        {
          if ((i+1 - 1024) % (wb+1) == 0)
            len = scnprintf(buf, BUFF_SIZE, "%d\n", val);
          else
            len = scnprintf(buf, BUFF_SIZE, "%d ", val);
        }
      *offset += len;
      /* printk(KERN_INFO "%s", buf); */
      /* printk(KERN_INFO "i = %d, len = %ld\n", i, len); */
      if (copy_to_user(buffer, buf, len))
        {
          printk(KERN_ERR "Copy to user does not work.\n");
          return -EFAULT;
        }
      ++i;
      if (i == (wa+1) * (ha+1))
        {
          if (!wb || !hb)
            {
              printk(KERN_INFO "[READ] Succesfully read from bram_im device [single]\n");
              end_read = 1;
              i = 0;
            }
          else
            i = 1024;
        }
      else if (i == (wb+1) * (hb+1) + 1024)
        {
          printk(KERN_INFO "[READ] Succesfully read from bram_im device [dual]\n");
          end_read = 1;
          i = 0;
        }
      break;

    default:
      printk(KERN_ERR "[READ] Invalid minor. \n");
      end_read = 1;
    }

  return len;
}

ssize_t fft2_write(struct file *pfile, const char __user *buffer, size_t length, loff_t *offset)
{
  char buf[length+1];
  int minor = MINOR(pfile->f_inode->i_rdev);
  unsigned int pos=0, val=0, val2=0;
  if (copy_from_user(buf, buffer, length))
    return -EFAULT;
  buf[length]='\0';

  switch (minor)
    {
    case 0: //device fft2
      sscanf(buf, "%u, %u, %u, %u", &wa, &ha, &wb, &hb);
      printk(KERN_INFO "[WRITE] %u, %u, %u, %u\n", wa, ha, wb, hb);

      // ===================
      // FFT2 over A
      // ===================

      log2wa = _log2(wa);
      log2ha = _log2(ha);
      if ((log2wa > 4) || (log2ha > 4))
        return -EFAULT;
      wa  -= 1;
      ha -= 1;
      printk(KERN_INFO "[WRITE] %u, %u, %u, %u\n", log2wa, wa, log2ha, ha);
      iowrite32(log2wa, fft2->base_addr + 0);
      iowrite32(wa,     fft2->base_addr + 4);
      iowrite32(log2ha, fft2->base_addr + 8);
      iowrite32(ha,     fft2->base_addr + 12);

      iowrite32(1, fft2->base_addr + 16);
      udelay(1000);
      iowrite32(0, fft2->base_addr + 16);
      while (!ioread32(fft2->base_addr + 20))
        udelay(1000);

      printk(KERN_INFO "[WRITE] Succesfully wrote into fft2 device. %d, %d, %d, %d\n", log2wa, wa, log2ha, ha);

      // ===================
      // FFT2 over B (if exists)
      // ===================

      if (!wb || !hb)
        break;

      // swap A and B in bram
      for (i = 0; i < 1024; ++i)
        {
          val  = ioread32(bram_re->base_addr + i*4);
          val2 = ioread32(bram_re->base_addr + i*4 + 1024*4);
          iowrite32 (val, bram_re->base_addr + i*4 + 1024*4);
          iowrite32 (val2,bram_re->base_addr + i*4);

          val  = ioread32(bram_im->base_addr + i*4);
          val2 = ioread32(bram_im->base_addr + i*4 + 1024*4);
          iowrite32 (val, bram_im->base_addr + i*4 + 1024*4);
          iowrite32 (val2,bram_im->base_addr + i*4);
        }
      i = 0;

      log2wb = _log2(wb);
      log2hb = _log2(hb);
      if ((log2wb > 4) || (log2hb > 4))
        return -EFAULT;
      wb  -= 1;
      hb -= 1;
      printk(KERN_INFO "[WRITE] %u, %u, %u, %u\n", log2wb, wb, log2hb, hb);
      iowrite32(log2wb, fft2->base_addr + 0);
      iowrite32(wb,     fft2->base_addr + 4);
      iowrite32(log2hb, fft2->base_addr + 8);
      iowrite32(hb,     fft2->base_addr + 12);

      iowrite32(1, fft2->base_addr + 16);
      udelay(1000);
      iowrite32(0, fft2->base_addr + 16);
      while (!ioread32(fft2->base_addr + 20))
        udelay(1000);

      // swap A and B in bram
      for (i = 0; i < 1024; ++i)
        {
          val  = ioread32(bram_re->base_addr + i*4);
          val2 = ioread32(bram_re->base_addr + i*4 + 1024*4);
          iowrite32 (val, bram_re->base_addr + i*4 + 1024*4);
          iowrite32 (val2,bram_re->base_addr + i*4);

          val  = ioread32(bram_im->base_addr + i*4);
          val2 = ioread32(bram_im->base_addr + i*4 + 1024*4);
          iowrite32 (val, bram_im->base_addr + i*4 + 1024*4);
          iowrite32 (val2,bram_im->base_addr + i*4);
        }
      i = 0;

      printk(KERN_INFO "[WRITE] Succesfully wrote into fft2 device. %d, %d, %d, %d\n", log2wb, wb, log2hb, hb);
      break;

    case 1: //device bram_re
      sscanf(buf, "%d, %d", &pos, &val);
      iowrite32(val, bram_re->base_addr + (pos*4));
      printk(KERN_INFO "[WRITE] Succesfully wrote into bram_re device. pos = %d, val = %d\n", pos, val);
      break;

    case 2: //device bram_im
      sscanf(buf, "%d, %d", &pos, &val);
      iowrite32(val, bram_im->base_addr + (pos*4));
      printk(KERN_INFO "[WRITE] Succesfully wrote into bram_im device. pos = %d, val = %d\n", pos, val);
      break;

    default:
      printk(KERN_INFO "[WRITE] Invalid minor. \n");
  }

  return length;
}

// ------------------------------------------
// INIT & EXIT
// ------------------------------------------

static int __init fft2_init(void)
{
   printk(KERN_INFO "\n");
   printk(KERN_INFO "FFT2 driver starting insmod.\n");

   if (alloc_chrdev_region(&my_dev_id, 0, 3, "fft2_region") < 0){
      printk(KERN_ERR "failed to register char device\n");
      return -1;
   }
   printk(KERN_INFO "char device region allocated\n");

   my_class = class_create(THIS_MODULE, "fft2_class");
   if (my_class == NULL){
      printk(KERN_ERR "failed to create class\n");
      goto fail_0;
   }
   printk(KERN_INFO "class created\n");

   if (device_create(my_class, NULL, MKDEV(MAJOR(my_dev_id),0), NULL, "xlnx,fft2") == NULL) {
      printk(KERN_ERR "failed to create device fft2\n");
      goto fail_1;
   }
   printk(KERN_INFO "device created - fft2\n");

   if (device_create(my_class, NULL, MKDEV(MAJOR(my_dev_id),1), NULL, "xlnx,bram_re") == NULL) {
     printk(KERN_ERR "failed to create device bram_re\n");
     goto fail_2;
   }
   printk(KERN_INFO "device created - bram_re\n");

   if (device_create(my_class, NULL, MKDEV(MAJOR(my_dev_id),2), NULL, "xlnx,bram_im") == NULL) {
     printk(KERN_ERR "failed to create device bram_im\n");
     goto fail_3;
   }
   printk(KERN_INFO "device created - bram_im\n");

	my_cdev = cdev_alloc();
	my_cdev->ops = &my_fops;
	my_cdev->owner = THIS_MODULE;

	if (cdev_add(my_cdev, my_dev_id, 3) == -1)
	{
      printk(KERN_ERR "failed to add cdev\n");
      goto fail_4;
	}
   printk(KERN_INFO "cdev added\n");
   printk(KERN_INFO "FFT2 driver initialized.\n");

   return platform_driver_register(&my_driver);

    fail_4:
     device_destroy(my_class, MKDEV(MAJOR(my_dev_id),2));
    fail_3:
     device_destroy(my_class, MKDEV(MAJOR(my_dev_id),1));
	  fail_2:
     device_destroy(my_class, MKDEV(MAJOR(my_dev_id),0));
   fail_1:
      class_destroy(my_class);
   fail_0:
      unregister_chrdev_region(my_dev_id, 1);
   return -1;
}

static void __exit fft2_exit(void)
{
  printk(KERN_INFO "FFT2 driver starting rmmod.\n");
	platform_driver_unregister(&my_driver);
	cdev_del(my_cdev);
  device_destroy(my_class, MKDEV(MAJOR(my_dev_id),2));
  device_destroy(my_class, MKDEV(MAJOR(my_dev_id),1));
  device_destroy(my_class, MKDEV(MAJOR(my_dev_id),0));
  class_destroy(my_class);
  unregister_chrdev_region(my_dev_id,1);
  printk(KERN_INFO "FFT2 driver exited.\n");
}


module_init(fft2_init);
module_exit(fft2_exit);
