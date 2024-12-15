# Data Movement in Modern Systems: From CPU Caches to the Cloud

## CPU Architecture and Memory Hierarchy

### Cache Line Example
```c
// Demonstrate cache line effects
#include <time.h>
#include <stdio.h>

#define ARRAY_SIZE 64*1024*1024
#define STRIDE 16  // Adjust to test different cache line sizes

void test_memory_access() {
    static int arr[ARRAY_SIZE];
    clock_t start = clock();
    
    // Access pattern that demonstrates cache line effects
    for (int i = 0; i < ARRAY_SIZE; i += STRIDE) {
        arr[i] *= 3;
    }
    
    double time_spent = (double)(clock() - start) / CLOCKS_PER_SEC;
    printf("Time spent: %f seconds\n", time_spent);
}
```

### Inter-CPU Communication
```c
#include <pthread.h>
#include <stdio.h>

// Cache line size padding to prevent false sharing
#define CACHE_LINE 64

// Aligned structure to prevent false sharing
typedef struct {
    long counter;
    char padding[CACHE_LINE - sizeof(long)];
} aligned_counter;

aligned_counter counters[2];
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void* increment_counter(void* arg) {
    int id = *(int*)arg;
    for(int i = 0; i < 10000000; i++) {
        counters[id].counter++;
    }
    return NULL;
}
```

## Tools and Techniques

### Named Pipes Example
```bash
#!/bin/bash
# Create named pipe
mkfifo /tmp/datapipe

# Producer
producer() {
    for i in {1..1000}; do
        echo "Data $i" > /tmp/datapipe
    done
}

# Consumer
consumer() {
    while read line; do
        echo "Received: $line"
    done < /tmp/datapipe
}

# Run in background
producer &
consumer
```

### GNU Parallel Example
```bash
#!/bin/bash
# Process large files in parallel
process_file() {
    local file=$1
    # Simulate CPU-intensive processing
    md5sum "$file" > "$file.processed"
}
export -f process_file

find . -type f -name "*.data" | \
    parallel -j $(nproc) process_file {}
```

### Basic pthreads Example
```c
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#define NUM_THREADS 4
#define ARRAY_SIZE 1000000

typedef struct {
    int* array;
    int start;
    int end;
    long sum;
} thread_data;

void* parallel_sum(void* arg) {
    thread_data* data = (thread_data*)arg;
    long local_sum = 0;
    
    for(int i = data->start; i < data->end; i++) {
        local_sum += data->array[i];
    }
    
    data->sum = local_sum;
    return NULL;
}

// Usage in main
int main() {
    int* array = malloc(ARRAY_SIZE * sizeof(int));
    pthread_t threads[NUM_THREADS];
    thread_data thread_args[NUM_THREADS];
    
    // Initialize array...
    
    int chunk_size = ARRAY_SIZE / NUM_THREADS;
    for(int i = 0; i < NUM_THREADS; i++) {
        thread_args[i].array = array;
        thread_args[i].start = i * chunk_size;
        thread_args[i].end = (i + 1) * chunk_size;
        pthread_create(&threads[i], NULL, parallel_sum, &thread_args[i]);
    }
    
    // Join threads and sum results...
}
```

### GPU Memory Pinning (PyTorch)
```python
import torch

def pin_memory_example():
    # Create tensor on CPU
    cpu_tensor = torch.randn(1000, 1000)
    
    # Pin memory for faster CPU->GPU transfer
    pinned_tensor = cpu_tensor.pin_memory()
    
    # Transfer to GPU
    gpu_tensor = pinned_tensor.cuda(non_blocking=True)
    
    return gpu_tensor

# Benchmark transfer speeds
def benchmark_transfer():
    import time
    
    # Regular transfer
    start = time.time()
    regular = torch.randn(1000, 1000)
    regular_gpu = regular.cuda()
    regular_time = time.time() - start
    
    # Pinned transfer
    start = time.time()
    pinned = torch.randn(1000, 1000).pin_memory()
    pinned_gpu = pinned.cuda(non_blocking=True)
    pinned_time = time.time() - start
    
    print(f"Regular transfer: {regular_time:.4f}s")
    print(f"Pinned transfer: {pinned_time:.4f}s")
```

### Rust S3 Large File Transfer
```rust
use tokio;
use aws_sdk_s3::{Client, Config};
use aws_sdk_s3::model::CompletedMultipartUpload;
use futures::stream::StreamExt;

const CHUNK_SIZE: usize = 8 * 1024 * 1024; // 8MB chunks

async fn upload_large_file(
    client: &Client,
    bucket: &str,
    key: &str,
    data: Vec<u8>
) -> Result<(), Box<dyn std::error::Error>> {
    // Initialize multipart upload
    let create_multipart_upload = client
        .create_multipart_upload()
        .bucket(bucket)
        .key(key)
        .send()
        .await?;
        
    let upload_id = create_multipart_upload
        .upload_id()
        .ok_or("Failed to get upload ID")?;

    // Split data into chunks and upload
    let mut completed_parts = Vec::new();
    for (i, chunk) in data.chunks(CHUNK_SIZE).enumerate() {
        let part_number = i as i32 + 1;
        
        let upload_part = client
            .upload_part()
            .bucket(bucket)
            .key(key)
            .upload_id(&upload_id)
            .part_number(part_number)
            .body(chunk.to_vec().into())
            .send()
            .await?;
            
        completed_parts.push(upload_part);
    }

    // Complete multipart upload
    client
        .complete_multipart_upload()
        .bucket(bucket)
        .key(key)
        .upload_id(upload_id)
        .multipart_upload(
            CompletedMultipartUpload::builder()
                .set_parts(Some(completed_parts))
                .build()
        )
        .send()
        .await?;

    Ok(())
}
```

### COZ Profiling Example
```c
#include <coz.h>

void process_data(int* data, size_t size) {
    COZ_BEGIN("data_processing");
    // Your processing code here
    for (size_t i = 0; i < size; i++) {
        data[i] = process_item(data[i]);
    }
    COZ_END("data_processing");
}

int main() {
    // Initialize data
    size_t size = 1000000;
    int* data = malloc(size * sizeof(int));
    
    // Process in chunks to measure performance
    size_t chunk_size = 1000;
    for (size_t i = 0; i < size; i += chunk_size) {
        COZ_PROGRESS_NAMED("data_chunks");
        process_data(&data[i], chunk_size);
    }
    
    free(data);
    return 0;
}
```

## Benchmark Methodology

### Buffer Size Testing
```c
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void benchmark_copy(size_t buffer_size) {
    char* src = malloc(buffer_size);
    char* dst = malloc(buffer_size);
    
    // Fill source buffer
    memset(src, 'A', buffer_size);
    
    clock_t start = clock();
    memcpy(dst, src, buffer_size);
    double time_spent = (double)(clock() - start) / CLOCKS_PER_SEC;
    
    printf("Buffer size: %zu bytes, Time: %f seconds\n", 
           buffer_size, time_spent);
    
    free(src);
    free(dst);
}

int main() {
    // Test different buffer sizes
    size_t sizes[] = {
        1024,        // 1KB
        1024*1024,   // 1MB
        10*1024*1024 // 10MB
    };
    
    for (int i = 0; i < sizeof(sizes)/sizeof(size_t); i++) {
        benchmark_copy(sizes[i]);
    }
}
```
