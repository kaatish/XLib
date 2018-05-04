#include <cstddef>
#include <omp.h>

namespace xlib {

namespace omp {

namespace kernel {

/*
Copyright (c) 2014, Haichuan Wang
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/* Code for the blog https://haichuanwang.wordpress.com/2014/05/26/a-faster-openmp-radix-sort-implementation/ */

#define BASE_BITS 8
#define BASE (1 << BASE_BITS)
#define MASK (BASE-1)
#define DIGITS(v, shift) (((v) >> shift) & MASK)

template <typename T>
void omp_lsd_radix_sort(size_t n,
        unsigned * key,
        T * val,
        unsigned * temp_key,
        T * temp_val) {
    int total_digits = sizeof(unsigned)*8;

    //Each thread use local_bucket to move key
    size_t i;
    for(int shift = 0; shift < total_digits; shift+=BASE_BITS) {
        size_t bucket[BASE] = {0};

        size_t local_bucket[BASE] = {0}; // size needed in each bucket/thread
        //1st pass, scan whole and check the count
        #pragma omp parallel firstprivate(local_bucket)
        {
            #pragma omp for schedule(static) nowait
            for(i = 0; i < n; i++){
                local_bucket[DIGITS(key[i], shift)]++;
            }
            #pragma omp critical
            for(i = 0; i < BASE; i++) {
                bucket[i] += local_bucket[i];
            }
            #pragma omp barrier
            #pragma omp single
            for (i = 1; i < BASE; i++) {
                bucket[i] += bucket[i - 1];
            }
            int nthreads = omp_get_num_threads();
            int tid = omp_get_thread_num();
            for(int cur_t = nthreads - 1; cur_t >= 0; cur_t--) {
                if(cur_t == tid) {
                    for(i = 0; i < BASE; i++) {
                        bucket[i] -= local_bucket[i];
                        local_bucket[i] = bucket[i];
                    }
                } else { //just do barrier
                    #pragma omp barrier
                }

            }
            #pragma omp for schedule(static)
            for(i = 0; i < n; i++) { //note here the end condition
                size_t index = local_bucket[DIGITS(key[i], shift)]++;
                temp_key[index] = key[i];
                temp_val[index] = val[i];
            }
        }
        //now move key
        {
            unsigned * tmp = key;
            key = temp_key;
            temp_key = tmp;
        }
        {
            T * tmp = val;
            val = temp_val;
            temp_val = tmp;
        }
    }
}

template <typename T>
void omp_lsd_radix_sort(size_t n,
        int * key,
        T * val,
        int * temp_key,
        T * temp_val) {
    size_t initial_shift = (((sizeof (int)) - 1) * 010);
    unsigned x = ((unsigned)0x80) << initial_shift;
    #pragma omp parallel for
    for (int i = 0; i < n; ++i) {
        key[i] ^= x;
    }
    omp_lsd_radix_sort(n, (unsigned *)key, val, (unsigned *)temp_key, temp_val);
    #pragma omp parallel for
    for (int i = 0; i < n; ++i) {
        key[i] ^= x;
    }
}

}//kernel

}//omp

}//xlib
