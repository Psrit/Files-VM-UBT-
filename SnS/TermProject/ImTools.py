import os

def get_imlist(path):
    """
    :param path:
    :return: the list of names of all JPG files in path
    """
    return [os.path.join(path, filename) for filename in os.listdir(path) if filename.endswith(".jpg")]
    #[expression for item in iterable if condition]