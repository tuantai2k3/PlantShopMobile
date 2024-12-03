<?php

use App\Http\Controllers\Api\AuthenticationController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CommentController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\ProfileController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::group(['prefix' => 'v1'], function () {
    // Public routes
    Route::controller(AuthenticationController::class)->group(function () {
        Route::post('login', 'store');
        Route::post('register', 'register');
        Route::post('forgot-password', 'forgotPassword');
        Route::post('reset-password', 'resetPassword');
    });

    // Product routes (public)
    Route::controller(ProductController::class)->group(function () {
        Route::get('products', 'getAllProduct');
        Route::get('products/{id}', 'show');
    });

    // Public comment routes
    Route::controller(CommentController::class)->prefix('comments')->group(function () {
        Route::get('/', 'index');
        Route::get('product/{productId}', 'getByProduct');
    });

    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {
        // User/Profile routes
        Route::controller(ProfileController::class)->group(function () {
            Route::get('profile', 'getProfile');
            Route::post('profile/update', 'updateProfile');
        });

        // Cart routes
        Route::controller(CartController::class)->prefix('cart')->group(function () {
            Route::get('/', 'index');
            Route::post('add', 'add');
            Route::put('update/{id}', 'update');
            Route::delete('{id}', 'remove');
            Route::delete('clear', 'clear');
            Route::post('checkout', 'checkout');
        });

        // Protected comment routes
        Route::controller(CommentController::class)->prefix('comments')->group(function () {
            Route::post('/', 'store');
            Route::put('{id}', 'update');
            Route::delete('{id}', 'destroy');
        });

        // Order routes
        Route::controller(OrderController::class)->prefix('orders')->group(function () {
            Route::get('/', 'index');
            Route::post('/', 'store');
            Route::get('{id}', 'show');
            Route::put('{id}/status', 'updateStatus');
            Route::delete('{id}', 'destroy');
            Route::get('user/orders', 'getUserOrders');
        });

        // Auth logout route
        Route::post('logout', [AuthenticationController::class, 'destroy']);
    });
});