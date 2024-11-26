<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Rating;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class RatingController extends Controller
{
    public function index()
    {
        $ratings = Rating::with(['user', 'product'])
            ->where('status', 'active')
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'status' => true,
            'message' => 'Ratings retrieved successfully',
            'data' => $ratings
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|integer|exists:products,id',
            'rating' => 'required|integer|min:1|max:5',
            'review' => 'nullable|string|max:1000'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Kiểm tra xem user đã đánh giá sản phẩm này chưa
        $existingRating = Rating::where('user_id', Auth::id())
            ->where('product_id', $request->product_id)
            ->first();

        if ($existingRating) {
            return response()->json([
                'status' => false,
                'message' => 'You have already rated this product'
            ], 400);
        }

        $rating = Rating::create([
            'user_id' => Auth::id(),
            'product_id' => $request->product_id,
            'rating' => $request->rating,
            'review' => $request->review,
            'status' => 'active'
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Rating created successfully',
            'data' => $rating->load(['user', 'product'])
        ], 201);
    }

    public function getProductRatings($product_id)
    {
        $ratings = Rating::with('user')
            ->where('product_id', $product_id)
            ->where('status', 'active')
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        $avgRating = Rating::where('product_id', $product_id)
            ->where('status', 'active')
            ->avg('rating');

        return response()->json([
            'status' => true,
            'message' => 'Product ratings retrieved successfully',
            'data' => [
                'ratings' => $ratings,
                'average_rating' => round($avgRating, 1),
                'total_ratings' => $ratings->total()
            ]
        ]);
    }

    public function getUserRatings($user_id)
    {
        // Kiểm tra quyền truy cập
        if (Auth::id() != $user_id && !Auth::user()->isAdmin()) {
            return response()->json([
                'status' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $ratings = Rating::with('product')
            ->where('user_id', $user_id)
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'status' => true,
            'message' => 'User ratings retrieved successfully',
            'data' => $ratings
        ]);
    }

    public function update(Request $request, $id)
    {
        $rating = Rating::find($id);

        if (!$rating) {
            return response()->json([
                'status' => false,
                'message' => 'Rating not found'
            ], 404);
        }

        // Kiểm tra quyền
        if ($rating->user_id !== Auth::id() && !Auth::user()->isAdmin()) {
            return response()->json([
                'status' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|min:1|max:5',
            'review' => 'nullable|string|max:1000'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $rating->update([
            'rating' => $request->rating,
            'review' => $request->review
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Rating updated successfully',
            'data' => $rating->load(['user', 'product'])
        ]);
    }

    public function destroy($id)
    {
        $rating = Rating::find($id);

        if (!$rating) {
            return response()->json([
                'status' => false,
                'message' => 'Rating not found'
            ], 404);
        }

        // Kiểm tra quyền
        if ($rating->user_id !== Auth::id() && !Auth::user()->isAdmin()) {
            return response()->json([
                'status' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $rating->delete();

        return response()->json([
            'status' => true,
            'message' => 'Rating deleted successfully'
        ]);
    }
}