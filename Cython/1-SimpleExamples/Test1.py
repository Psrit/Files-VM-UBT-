import fib
import primes
import time

fib.fib(2000)

t_start = time.time()
print primes.primes(100)
t_end = time.time()
print 'time cost:', t_end - t_start, "seconds"