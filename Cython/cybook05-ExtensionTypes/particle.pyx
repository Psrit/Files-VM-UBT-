cdef class Particle:
    """Simple Particle extension type. """
    cdef public double mass
    cdef readonly double position
    cdef double velocity  # private

    cpdef double get_momentum(self):
        return self.mass * self.velocity
    cdef double get_momentum_c(self):  # a little bit faster
        return self.mass * self.velocity

def add_momentums(particles):
    """Returns the sum of the particle momentums. """
    total_mmt = 0.0
    for particle in particles:
        # here the call to get_momentum is a fully general Python attribute
        # lookup and call
        total_mmt += particle.get_momentum()

def add_momentums_typed(list particles):
    """Returns the sum of the particle momentums. """
    cdef:
        double total_mmt = 0.0
        Particle particle  # crucial
    for particle in particles:
        total_mmt += particle.get_momentum()
    return total_mmt

def add_momentums_typed_c(list particles):
    """Returns the sum of the particle momentums. """
    cdef:
        double total_mmt = 0.0
        Particle particle
    for particle in particles:
        total_mmt += particle.get_momentum_c()  # a little bit faster
    return total_mmt
