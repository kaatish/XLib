#include "Host/Primitives/OmpWrapper.cuh"
#include "Host/Primitives/impl/OmpRadixSortByKey.hpp"
#include "Host/Primitives/impl/OmpCopy.hpp"

namespace xlib {

namespace omp {

//==============================================================================
//==============================================================================
////////////////
// SortPairs2 //
////////////////

template<typename T, typename R>
SortPairs2<T, R>::SortPairs2(int max_items, bool internal_allocation) noexcept {
    initialize(max_items, internal_allocation);
}

template<typename T, typename R>
void SortPairs2<T, R>::initialize(int max_items, bool internal_allocation)
                                     noexcept {
    _internal_alloc = internal_allocation;
    if (internal_allocation) {
        _d_in1_tmp = new T[max_items];
        _d_in2_tmp = new R[max_items];
    }
}

template<typename T, typename R>
SortPairs2<T, R>::~SortPairs2() noexcept {
    if (_internal_alloc) {
        delete[] _d_in1_tmp;
        delete[] _d_in2_tmp;
    }
}

template<typename T, typename R>
void SortPairs2<T, R>::run(T* d_in1, R* d_in2, int num_items)
                              noexcept {

    kernel::omp_lsd_radix_sort(num_items, d_in2, d_in1, _d_in2_tmp, _d_in1_tmp);
    kernel::omp_lsd_radix_sort(num_items, d_in1, d_in2, _d_in1_tmp, _d_in2_tmp);
}

template<typename T, typename R>
void SortPairs2<T, R>::run(T* d_in1, R* d_in2, int num_items,
             T* d_in1_tmp, R* d_in2_tmp)
                              noexcept {

    kernel::omp_lsd_radix_sort(num_items, d_in2, d_in1, d_in2_tmp, d_in1_tmp);
    kernel::omp_lsd_radix_sort(num_items, d_in1, d_in2, d_in1_tmp, d_in2_tmp);
}

//==============================================================================
//==============================================================================
///////////////
// SortByKey //
///////////////

template<typename T, typename R>
SortByKey<T, R>::SortByKey(int max_items) noexcept {
    initialize(max_items);
}

template<typename T, typename R>
void SortByKey<T, R>::initialize(int max_items) noexcept {
    _d_key_tmp = new T[max_items];
    _d_val_tmp = new R[max_items];
}

template<typename T, typename R>
SortByKey<T, R>::~SortByKey() noexcept {
    delete[] _d_key_tmp;
    delete[] _d_val_tmp;
}

template<typename T, typename R>
void SortByKey<T, R>::run(T* d_key, R* d_val, int num_items)
                              noexcept {
    kernel::omp_lsd_radix_sort(num_items, d_key, d_val, _d_key_tmp, _d_val_tmp);
}

template<typename T, typename R>
void SortByKey<T, R>::run(T* d_key, R* d_val, int num_items,
        T * d_key_tmp, R * d_val_tmp)
                              noexcept {
    kernel::omp_lsd_radix_sort(num_items, d_key, d_val, d_key_tmp, d_val_tmp);
}

//==============================================================================
//==============================================================================
//////////
// Copy //
//////////

template<typename T>
void Copy<T>::run(T* src, T* dst, int num_items) {
    kernel::copy(src, dst, num_items);
}

template class SortPairs2<int, int>;
template class SortByKey<int, int>;
template class Copy<int>;

}

}
