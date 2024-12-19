# Data Movement in Modern Systems: From CPU Caches to the Cloud

```bash
# Do not try this on a DEC Alpha.
yes "Don't you hate dialup?" | write $USERNAME&
```

Pipes date back to [Doug McIlroy](https://thenewstack.io/pipe-how-the-system-call-that-ties-unix-together-came-about/) at Bell Labs.

[McIlroy Power Series lecture at LambdaConf](https://www.youtube.com/watch?v=jaHoYy2rnUc)


[McIlroy and Kernigan](https://www.youtube.com/watch?v=Xe5ffO6Ouwg)


[McIlroy Power Serious papers](https://www.cs.dartmouth.edu/~doug/powser.html)

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


Named pipes write to file system. [fifo man page](https://man7.org/linux/man-pages/man7/fifo.7.html)

"A FIFO special file (a named pipe) is similar to a pipe, except
       that it is accessed as part of the filesystem.  It can be opened
       by multiple processes for reading or writing.  When processes are
       exchanging data via the FIFO, the kernel passes all data
       internally without writing it to the filesystem.  Thus, the FIFO
       special file has no contents on the filesystem; the filesystem
       entry merely serves as a reference point so that processes can
       access the pipe using a name in the filesystem."


```c
#include <sys/stat.h>
int mkfifo (const char *filename, mode_t mode)
// Use mkfifoat() if you want a relative path instead of an absolute path
```

"mkfifo() makes a FIFO special file with name pathname.  mode
       specifies the FIFO's permissions.  It is modified by the
       process's umask in the usual way: the permissions of the created
       file are (mode & ~umask)."


"F_SETPIPE_SZ (int; since Linux 2.6.35)
              Change the capacity of the pipe referred to by fd to be at
              least arg bytes.  An unprivileged process can adjust the
              pipe capacity to any value between the system page size
              and the limit defined in /proc/sys/fs/pipe-max-size"

              

```bash
# Create a named pipe
mkfifo my_pipe

# Write to pipe in one terminal
echo "Hello" > my_pipe

# Read from pipe in another terminal
cat < my_pipe
```

```bash
# Set output buffer size to 1MB
stdbuf -o1048576 command | next_command
```
```bash
# Chunk to 1MB then pass to next process, might be good for not SPAMing a bus/network with small transfers
command | dd bs=1M | next_command
```



[tee man page](https://www.man7.org/linux/man-pages/man1/tee.1.html)
"tee - read from standard input and write to standard output and
       files"

```c
#include <fcntl.h>
ssize_t tee(int fd_in, int fd_out, size_t len, unsigned int flags);
```


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



* additions for named pipes and GNU parallel


## Advanced IPC and Parallel Processing Examples

### Named Pipes (FIFOs) Deep Dive

```bash
#!/bin/bash
# Demonstrating different named pipe patterns

# 1. Basic producer-consumer with backpressure
setup_basic_pipe() {
    mkfifo /tmp/dataflow
    # Cleanup on exit
    trap "rm -f /tmp/dataflow" EXIT
}

# Producer with rate limiting
producer() {
    local rate=$1  # Messages per second
    local sleep_time=$(bc <<< "scale=4; 1/$rate")
    
    for i in {1..100}; do
        echo "Message $i"
        sleep "$sleep_time"
    done > /tmp/dataflow
}

# Consumer with processing time
consumer() {
    local process_time=$1
    while read line; do
        echo "[$(date +%T.%N)] Received: $line"
        sleep "$process_time"
    done < /tmp/dataflow
}

# 2. Multiple consumers (round-robin)
setup_multi_consumer() {
    mkfifo /tmp/pipe1 /tmp/pipe2
    trap "rm -f /tmp/pipe1 /tmp/pipe2" EXIT
}

multi_producer() {
    for i in {1..100}; do
        echo "Data $i" > /tmp/pipe1
        echo "Data $i" > /tmp/pipe2
    done
}

consumer_with_id() {
    local id=$1
    local pipe="/tmp/pipe$id"
    while read line; do
        echo "Consumer $id: $line"
        sleep 0.1  # Simulate processing
    done < "$pipe"
}

# 3. Bidirectional communication
setup_bidirectional() {
    mkfifo /tmp/request /tmp/response
    trap "rm -f /tmp/request /tmp/response" EXIT
}

server() {
    while true; do
        read request < /tmp/request
        echo "Processing: $request"
        echo "Response to: $request" > /tmp/response
    done
}

client() {
    for i in {1..5}; do
        echo "Request $i" > /tmp/request
        read response < /tmp/response
        echo "Got: $response"
    done
}

# Example usage:
# setup_basic_pipe
# producer 2 & consumer 0.1
```

### GNU Parallel Advanced Patterns

```bash
#!/bin/bash

# 1. Processing files with custom output handling
process_large_file() {
    local input=$1
    local chunk_size=1000  # lines per chunk
    
    # Split input into chunks while maintaining line integrity
    split -l "$chunk_size" "$input" /tmp/chunk_
    
    # Process chunks in parallel
    ls /tmp/chunk_* | parallel -j$(nproc) --progress \
        'cat {} | while read line; do
            echo "Processing $line" >&2
            echo "$line" | md5sum
        done > {}.processed'
    
    # Combine results
    cat /tmp/chunk_*.processed > "${input}.processed"
    rm /tmp/chunk_* /tmp/chunk_*.processed
}

# 2. Parallel data transformation with SQL-like operations
parallel_transform() {
    local input=$1
    
    # Generate work units
    seq 1 100 | \
    parallel -j$(nproc) --pipe --block 1M \
        "awk '{
            sum += \$1;
            count++;
        }
        END {
            if (count > 0) 
                print sum/count
        }'" > results.txt
}

# 3. Network bandwidth testing with parallel connections
parallel_network_test() {
    local target=$1
    local num_connections=${2:-10}
    
    seq "$num_connections" | \
    parallel -j"$num_connections" \
        "curl -s -w '%{speed_download}\n' -o /dev/null $target"
}

# 4. Directory tree processing with custom control
parallel_tree_process() {
    local dir=$1
    
    # Find all files and process based on type
    find "$dir" -type f -print0 | \
    parallel -0 -j$(nproc) --bar \
        'file={};
         ext="${file##*.}";
         case "$ext" in
            "jpg"|"png")
                convert "$file" -resize "50%" "${file%.}.thumb.$ext"
                ;;
            "txt"|"log")
                gzip -9 "$file"
                ;;
            *)
                echo "Skipping $file" >&2
                ;;
         esac'
}

# 5. Memory-aware parallel processing
parallel_memory_aware() {
    local input_dir=$1
    local mem_per_job="1G"  # Memory per job
    
    # Calculate jobs based on available memory
    local total_mem=$(free -g | awk '/^Mem:/{print $2}')
    local max_jobs=$((total_mem * 1024 * 1024 * 1024 / (1024 * 1024 * 1024)))  # Convert GB to jobs
    
    find "$input_dir" -type f | \
    parallel --memfree "$mem_per_job" \
             --jobs "$max_jobs" \
             --progress \
        'process_file {}'
}

# Example usage functions
demonstrate_pipes() {
    echo "Setting up named pipes..."
    setup_basic_pipe
    producer 2 & consumer 0.1
    wait
}

demonstrate_parallel() {
    echo "Running parallel processing examples..."
    # Create test data
    seq 1000 > testdata.txt
    parallel_transform testdata.txt
    rm testdata.txt results.txt
}

# Run demonstrations
# demonstrate_pipes
# demonstrate_parallel
```

This code adds:

1. Advanced named pipe patterns:
   - Basic producer-consumer with rate limiting
   - Multiple consumer setup
   - Bidirectional communication

2. GNU Parallel patterns:
   - Custom file chunk processing
   - Memory-aware parallel execution
   - Network testing
   - Directory tree processing
   - Data transformation pipelines

Would you like me to:
1. Add more specific use cases for any of these patterns?
2. Include performance measurement code?
3. Add error handling and recovery examples?
4. Include more complex data processing patterns?

