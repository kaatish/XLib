/**
 * @author Federico Busato                                                  <br>
 *         Univerity of Verona, Dept. of Computer Science                   <br>
 *         federico.busato@univr.it
 * @date November, 2017
 * @version v2
 *
 * @copyright Copyright © 2017 XLib. All rights reserved.
 *
 * @license{<blockquote>
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 * </blockquote>}
 */
#include "Device/Primitives/GlobalSync.cuh" //xlib::globalSyncResetKernel
#include "Device/Util/DeviceProperties.cuh" //xlib::MAX_RESIDENT_BLOCKS
#include "Device/Util/SafeCudaAPI.cuh"      //CHECK_CUDA_ERROR
#include "Device/Util/SafeCudaAPIAsync.cuh" //cuMemset0x00Async

namespace xlib {

__device__ unsigned GlobalSyncArray[MAX_BLOCK_SIZE];

namespace {
    __global__ void globalSyncResetKernel() {
        if (threadIdx.x < MAX_BLOCK_SIZE)
            GlobalSyncArray[threadIdx.x] = 0;
    }
} // namespace

void globalSyncReset() {
    globalSyncResetKernel<<<1, MAX_BLOCK_SIZE>>>();
    //CHECK_CUDA_ERROR
}

//==============================================================================

__device__ unsigned global_sync_array[GPU_MAX_BLOCKS];

void global_sync_reset() {
    unsigned* ptr;
    //cuGetSymbolAddress(global_sync_array, ptr);
    //cuMemset0x00Async(ptr, GPU_MAX_BLOCKS);
}

} // namespace xlib