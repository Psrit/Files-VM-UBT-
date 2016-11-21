from __future__ import division
import numpy as np

def naive_convolve(input, kernel):
    """
    2D discrete convolution of an image with a filter kernel
    :param input: an image indexed by (in_row, in_col)
    :param kernel: a filter kernel.
        It needs odd dimensions.
    :return: the output image indexed by (out_row, out_col)

    """
    if kernel.shape[0] % 2 != 1 or kernel.shape[1] % 2 != 1:
        raise ValueError("Only odd dimensions on filter supported")

    in_row_max, in_col_max = input.shape
    ker_row_max, ker_col_max = kernel.shape
    ker_row_mid, ker_col_mid = kernel.shape[0] // 2, kernel.shape[1] // 2
    out_row_max, out_col_max = \
        in_row_max + 2 * ker_row_mid, in_col_max + 2 * ker_col_mid

    output = np.zeros([out_row_max, out_col_max], dtype=input.dtype)

    for out_row in range(out_row_max):
        for out_col in range(out_col_max):
            value = 0
            s_from = max(-ker_row_mid, ker_row_mid - out_row)
            s_to = min(ker_row_mid, (out_row_max - 1) - out_row - ker_row_mid) + 1
            t_from = max(-ker_col_mid, ker_col_mid - out_col)
            t_to = min(ker_col_mid, (out_col_max - 1) - out_col - ker_col_mid) + 1
            # (s, t) is the coordinate of point on the kernel,
            # where the s-axis points in the direction that index of rows increases
            # and the t-axis points in the direction that index of columns increases
            # the origin is at the center of the (reflected) kernel
            for s in range(s_from, s_to):
                for t in range(t_from, t_to):
                    in_row = out_row - ker_row_mid + s
                    in_col = out_col - ker_col_mid + t
                    value += input[in_row, in_col] \
                             * kernel[ker_row_mid - s, ker_col_mid - t]
            output[out_row, out_col] = value

    return output
