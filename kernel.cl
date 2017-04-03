#include "lambda.cl"

/*
tuvp
*/
//*Main Control.Exception> map (\t -> encode_b $ reverse $ encode_t t) [i, k, k_star
//, omega, bigomega]
//[4,48,16,88,90466]
    //out[i] = substitute(in[i], 0, 48, 0, 0);

#define I 4
#define K 48
#define KSTAR 16
#define ω 88
#define Ω 90466

kernel void test(global const ulong *in,
                 global       ulong *out) {
    uint i = get_global_id(0);

    out[i] = reduce(in[i], 4);
}