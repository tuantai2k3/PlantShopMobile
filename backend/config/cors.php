<?php
// config/cors.php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie', 'storage/*'], // Đường dẫn áp dụng CORS
    'allowed_methods' => ['*'], // Cho phép tất cả các phương thức HTTP
    'allowed_origins' => ['*'], // Cho phép tất cả các nguồn (origin)
    'allowed_origins_patterns' => [], // Hoặc định nghĩa mẫu cụ thể nếu cần
    'allowed_headers' => ['*'], // Cho phép tất cả các headers
    'exposed_headers' => [], // Các headers được phép xuất hiện trong phản hồi
    'max_age' => 0, // Thời gian cache của preflight request (0 = không cache)
    'supports_credentials' => true, // True nếu yêu cầu gửi cookie/credentials
];
