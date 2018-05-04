#include <omp.h>

namespace xlib {

namespace omp {

namespace kernel {

template<typename T>
void copy(T* src, T* dst, int num_items) {
    #pragma omp paralel for
    for (int i = 0; i < num_items; ++i) {
        dst[i] = src[i];
    }
}

}//kernel

}//omp

}//xlib
