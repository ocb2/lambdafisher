import pyopencl as CL
from pyopencl import array
import numpy

CL.tools.clear_first_arg_caches()

c = CL.Context([CL.get_platforms()[0].get_devices()[0]])

k = CL.Program(c, """
    #include \"lambda.cl\"

    kernel void test(global const ulong *in,
                     global       ulong *out) {
        uint i = get_global_id(0);
        out[i] = lex(in[i], 0);
    }""").build("-I./src/cl")
q = CL.CommandQueue(c)

flags = CL.mem_flags

# 290 = i i
# 1323270 = (k i) k
# 659718 = (k* i) k
# 72218 = Ω
b_in = numpy.zeros((1, 1), CL.array.vec.ulong8)
#b_in[0, 0] = (290, 1323270, 659718, 72218)
b_in[0, 0] = (4, 48, 16, 88, 90466, 0, 0, 0)
b_out = numpy.zeros(5, numpy.uint64)

mem_in = CL.Buffer(c, flags.READ_ONLY | flags.COPY_HOST_PTR, hostbuf = b_in)
mem_out = CL.Buffer(c, flags.WRITE_ONLY, b_out.nbytes)

k.test(q, b_out.shape, None, mem_in, mem_out)
q.finish()
q.flush()

CL.enqueue_copy(q, b_out, mem_out)

if numpy.array_equal(b_out,[4, 7, 6, 8, 18]):
    print("Test success: lex")
else:
    print("Test failure: lex")