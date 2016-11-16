from PIL import Image
import os

infile = "./fig/pycharm.png"
pil_im = Image.open(infile)

# format convert
outfile_format_convert = os.path.splitext(infile)[0] + ".jpg"
if infile != outfile_format_convert:
    try:
        Image.open(infile).save(outfile_format_convert)
    except IOError:
        print("cannot convert" + infile)

# create thumbnail
outfile_thumbnail = pil_im.thumbnail((128, 128))

# crop and paste
box = pil_im.size() / 2
region = pil_im.crop(box)

region = region.transpose(Image.ROTATE_180)
outfile_crop_paste = pil_im.paste(region, box)

# resize and rotate
outfile_resize = pil_im.resize((128, 128))
outfile_rotate = pil_im.rotate(45)
