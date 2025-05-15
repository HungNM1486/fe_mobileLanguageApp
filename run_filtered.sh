#!/bin/bash

# Script để chạy Flutter mà không hiển thị thông báo gralloc4
# Cách sử dụng: ./run_filtered.sh [tham số flutter run]

# Chạy ứng dụng Flutter và lọc các log không mong muốn
flutter run "$@" 2>&1 | grep -v "gralloc4\|SMPTE 2094-40\|E/Buffer\|E/mali_winsys" 