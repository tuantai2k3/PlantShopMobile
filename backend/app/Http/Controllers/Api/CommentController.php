<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Comment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CommentController extends Controller
{
    // Hiển thị tất cả bình luận
    public function index(Request $request)
    {
        // Thêm filter theo product_id nếu có
        $query = Comment::orderBy('id', 'DESC');
        
        if ($request->has('product_id')) {
            $query->where('product_id', $request->product_id);
        }

        $comments = $query->paginate(10);
        return response()->json($comments);
    }

    // Thêm bình luận mới
    public function store(Request $request)
    {
        // Validate dữ liệu với product_id bắt buộc
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'content' => 'required|string',
            'url' => 'required|string|max:255',
            'product_id' => 'required|exists:products,id', // Thêm validation cho product_id
            'email' => 'nullable|string|email|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Tạo bình luận mới với product_id
            $comment = Comment::create([
                'name' => $request->name,
                'content' => $request->content,
                'url' => $request->url,
                'product_id' => $request->product_id,
                'email' => $request->email,
            ]);

            return response()->json([
                'message' => 'Bình luận đã được thêm thành công',
                'data' => $comment
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Có lỗi xảy ra khi thêm bình luận',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Cập nhật bình luận
    public function update(Request $request, $id)
    {
        $comment = Comment::find($id);
        if (!$comment) {
            return response()->json(['message' => 'Bình luận không tồn tại'], 404);
        }

        // Validate với product_id là tùy chọn khi update
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'content' => 'sometimes|required|string',
            'url' => 'sometimes|required|string|max:255',
            'product_id' => 'sometimes|required|exists:products,id',
            'email' => 'nullable|string|email|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Cập nhật dữ liệu bình luận
            $comment->update($request->only([
                'name',
                'content',
                'url',
                'product_id',
                'email'
            ]));

            return response()->json([
                'message' => 'Bình luận đã được cập nhật thành công',
                'data' => $comment
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Có lỗi xảy ra khi cập nhật bình luận',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Xóa bình luận
    public function destroy($id)
    {
        try {
            $comment = Comment::find($id);
            if (!$comment) {
                return response()->json(['message' => 'Bình luận không tồn tại'], 404);
            }

            $comment->delete();

            return response()->json([
                'message' => 'Bình luận đã được xóa thành công'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Có lỗi xảy ra khi xóa bình luận',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Lấy bình luận theo product_id
    public function getByProduct($productId)
    {
        try {
            $comments = Comment::where('product_id', $productId)
                ->orderBy('created_at', 'DESC')
                ->paginate(10);

            return response()->json($comments);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Có lỗi xảy ra khi lấy bình luận',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}