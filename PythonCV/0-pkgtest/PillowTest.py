from PIL import Image
import os

# import scipy.misc
# from pylab import *

infile = "../fig/pycharm.png"
pil_im = Image.open(infile)

# format convert
outfile_format_convert = os.path.splitext(infile)[0] + ".jpg"
if infile != outfile_format_convert:
    try:
        Image.open(infile).save(outfile_format_convert)
        # scipy.misc.imsave(outfile_format_convert, array(Image.open(infile)))
    except IOError:
        print("cannot convert" + infile)

# create thumbnail
img_thumbnail = pil_im.thumbnail((128, 128))

# crop and paste
box = (pil_im.size[0] / 4, pil_im.size[1] / 4, pil_im.size[0] * 3 / 4, pil_im.size[1] * 3 / 4)
region = pil_im.crop(box)

region = region.transpose(Image.ROTATE_180)
img_crop_paste = pil_im.paste(region, box)

# resize and rotate
img_resize = pil_im.resize((128, 128))
img_rotate = pil_im.rotate(45)
