def primes(int kmax):
    """Print kmax prime numbers (kmax <= 1000)"""
    cdef int n, k, i
    cdef int p[1000]  # C array
    result = []  # Python list
    if kmax > 1000:
        kmax = 1000
    k = 0
    n = 2
    while k < kmax:
        # print k-th prime
        i = 0
        # two lines below are pure 'C' code
        # Because no Python objects are referred to,
        # the loop is translated entirely into C code,
        # and thus runs very fast.
        while i < k and n % p[i] != 0:
            i += 1
        if i == k:
            # n is a prime
            p[k] = n
            k += 1
            # the C parameter n is automatically converted to a Python object
            # before being passed to the append method
            result.append(n)
        n += 1
    return result
