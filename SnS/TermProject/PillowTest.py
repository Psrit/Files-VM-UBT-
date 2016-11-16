from PIL import Image
import os

infile = "./fig/pycharm.png"
pil_im = Image.open(infile)

outfile = os.path.splitext(infile)[0] + ".jpg"
if infile != outfile:
    try:
        Image.open(infile).save(outfile)
    except IOError:
        print("cannot convert" + infile)