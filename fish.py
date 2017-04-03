import pyopencl as CL
from pyopencl import array
import numpy

CL.tools.clear_first_arg_caches()

c = CL.Context([CL.get_platforms()[0].get_devices()[0]])

with open("kernel.cl", "r") as k_src:
    k = CL.Program(c, k_src.read()).build("-I./src/cl")
q = CL.CommandQueue(c)

flags = CL.mem_flags

# 290 = i i
# 1323270 = (k i) k
# 659718 = (k* i) k
# 72218 = Ω

#λ. 1
#(λ. 1) 0
#λ. ((λ. 1) 0)
#0 (λ. 1)
#[(),(),(),()]
#*Main> map (\t -> encode_b $ reverse $ encode_t t) [a,b,c,d]
#[12,178,712,198]

#*Main> map (\t -> encode_b $ reverse $ encode_t (substitute 0 k t)) [a,b,c,d]
#[192,99074,712,98498]

#*Main> map (\t -> encode_b $ reverse $ encode_t t) [a,b,c,d]
#[274,557834,90466,1090]
#*Main> map (\t -> encode_b $ reverse $ encode_t (step t)) [a,b,c,d]
#[4,4354,90466,4]


b_in = numpy.zeros((1, 1), CL.array.vec.ulong4)
b_in[0, 0] = (274, 557834, 90466, 1090)
b_out = numpy.zeros(4, numpy.uint64)

mem_in = CL.Buffer(c, flags.READ_ONLY | flags.COPY_HOST_PTR, hostbuf = b_in)
mem_out = CL.Buffer(c, flags.WRITE_ONLY, b_out.nbytes)

k.test(q, b_out.shape, None, mem_in, mem_out)
q.finish()
q.flush()

CL.enqueue_copy(q, b_out, mem_out)


print(b_out)