<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\RatingController; // Thêm dòng này

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::group(['namespace' => 'Api', 'prefix' => 'v1'], function () {
    // Authentication routes
    Route::post('login', [\App\Http\Controllers\Api\AuthenticationController::class, 'store']);
    Route::post('logout', [\App\Http\Controllers\Api\AuthenticationController::class, 'destroy'])->middleware('auth:api');
    Route::post('register', [\App\Http\Controllers\Api\AuthenticationController::class, 'register']);
    Route::post('updateprofile', [\App\Http\Controllers\Api\ProfileController::class, 'updateProfile'])->middleware('auth:api');
    Route::post('forgot-password', [\App\Http\Controllers\Api\AuthenticationController::class, 'forgotPassword']);
    Route::post('reset-password', [\App\Http\Controllers\Api\AuthenticationController::class, 'resetPassword']);

    // Product routes
    Route::get('products', [\App\Http\Controllers\Api\ProductController::class, 'getAllProduct']);
    Route::get('products/{id}', [\App\Http\Controllers\Api\ProductController::class, 'show']);

    // Cart routes
    Route::get('cart', [\App\Http\Controllers\Api\CartController::class, 'index']);
    Route::post('cart/add', [\App\Http\Controllers\Api\CartController::class, 'add']);
    Route::put('cart/update/{id}', [\App\Http\Controllers\Api\CartController::class, 'update']);
    Route::delete('cart/{id}', [\App\Http\Controllers\Api\CartController::class, 'remove']);
    Route::delete('cart/clear', [\App\Http\Controllers\Api\CartController::class, 'clear']);
    Route::post('cart/checkout', [\App\Http\Controllers\Api\CartController::class, 'checkout']);

    // Rating routes - Thêm những routes này
    Route::group(['prefix' => 'ratings'], function () {
        Route::get('/', [\App\Http\Controllers\Api\RatingController::class, 'index']); // Lấy tất cả đánh giá
        Route::post('/', [\App\Http\Controllers\Api\RatingController::class, 'store'])->middleware('auth:api'); // Tạo đánh giá mới
        Route::get('product/{product_id}', [\App\Http\Controllers\Api\RatingController::class, 'getProductRatings']); // Lấy đánh giá theo sản phẩm
        Route::get('user/{user_id}', [\App\Http\Controllers\Api\RatingController::class, 'getUserRatings'])->middleware('auth:api'); // Lấy đánh giá của user
        Route::put('/{id}', [\App\Http\Controllers\Api\RatingController::class, 'update'])->middleware('auth:api'); // Cập nhật đánh giá
        Route::delete('/{id}', [\App\Http\Controllers\Api\RatingController::class, 'destroy'])->middleware('auth:api'); // Xóa đánh giá
    });
});