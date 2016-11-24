cdef class Particle:
    """Simple Particle extension type. """
    # Available in Python-space:
    cdef public double mass
    # Read-only in Python-space:
    cdef readonly double position
    # Attributes in cdef classes are by default private to
    # Python codes; only accessible from Cython (typed access):
    cdef double velocity

    cpdef double get_momentum(self):
        return self.mass * self.velocity
    cdef double get_momentum_c(self):  # a little bit faster
        return self.mass * self.velocity
    def get_momentum_py(self):
        return self.mass * self.velocity

    # Available in Python-space:
    property momentum:
        """The momentum Particle property. """
        def __get__(self):
            """momentum's getter"""
            return self.mass * self.velocity
        def __set__(self, m):
            """momentum's setter"""
            self.velocity = m / self.mass

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
