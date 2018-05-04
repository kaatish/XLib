#pragma once

namespace xlib {

namespace omp {

//==============================================================================

template<typename T, typename R>
class SortPairs2 {
public:
    explicit SortPairs2() = default;

    explicit SortPairs2(int max_items, bool internal_allocation = true)
                           noexcept;

    ~SortPairs2() noexcept;

    void initialize(int max_items, bool internal_allocation = true) noexcept;

    void run(T* d_in1, R* d_in2, int num_items) noexcept;

    void run(T* d_in1, R* d_in2, int num_items,
             T* d_in1_tmp, R* d_in2_tmp) noexcept;
private:
    T*    _d_in1_tmp      { nullptr };
    R*    _d_in2_tmp      { nullptr };
    bool  _internal_alloc { true };
};

//==============================================================================

template<typename T, typename R>
class SortByKey {
public:
    explicit SortByKey() = default;

    explicit SortByKey(int max_items) noexcept;

    ~SortByKey() noexcept;

    void initialize(int max_items) noexcept;

    void run(T* d_key, R* d_val, int num_items) noexcept;

    void run(T* d_key, R* d_val, int num_items,
                     T* d_key_tmp, R* d_val_tmp) noexcept;
private:
    T*    _d_key_tmp      { nullptr };
    R*    _d_val_tmp      { nullptr };
    bool  _internal_alloc { true };
};

//==============================================================================

template<typename T>
class Copy {
    public:
    void run(T* src, T* dst, int num_items);
};

}

}
