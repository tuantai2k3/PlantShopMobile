<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;

class CartController extends Controller
{
    // Lấy danh sách giỏ hàng
    public function index(Request $request)
    {
        $cart = session()->get('cart', []); // Lấy giỏ hàng từ session
        $products = [];

        foreach ($cart as $productId => $quantity) {
            $product = Product::find($productId);
            if ($product) {
                $product->quantity = $quantity;
                $products[] = $product;
            }
        }

        return response()->json(['success' => true, 'products' => $products]);
    }

    // Thêm sản phẩm vào giỏ hàng
    public function add(Request $request)
    {
        $productId = $request->input('product_id');
        if (!$productId) {
            return response()->json(['success' => false, 'message' => 'Product ID is required'], 400);
        }

        $product = Product::find($productId);
        if (!$product) {
            return response()->json(['success' => false, 'message' => 'Product not found'], 404);
        }

        $cart = session()->get('cart', []);
        $cart[$productId] = ($cart[$productId] ?? 0) + 1;
        session()->put('cart', $cart);

        return response()->json(['success' => true, 'message' => 'Product added to cart']);
    }

    // Cập nhật số lượng sản phẩm trong giỏ hàng
    public function update(Request $request, $id)
    {
        $quantity = $request->input('quantity');
        if (!$quantity || $quantity < 1) {
            return response()->json(['success' => false, 'message' => 'Quantity must be at least 1'], 400);
        }

        $cart = session()->get('cart', []);
        if (!isset($cart[$id])) {
            return response()->json(['success' => false, 'message' => 'Product not in cart'], 404);
        }

        $cart[$id] = $quantity;
        session()->put('cart', $cart);

        return response()->json(['success' => true, 'message' => 'Cart updated']);
    }

    // Xóa sản phẩm khỏi giỏ hàng
    public function remove($id)
    {
        $cart = session()->get('cart', []);

        if (isset($cart[$id])) {
            unset($cart[$id]);
            session()->put('cart', $cart);
        }

        return response()->json(['success' => true, 'message' => 'Product removed from cart']);
    }

    // Xóa toàn bộ giỏ hàng
    public function clear()
    {
        session()->forget('cart'); // Xóa giỏ hàng khỏi session
        return response()->json(['success' => true, 'message' => 'Cart cleared']);
    }
    
        public function checkout(Request $request)
        {
            // Validate request
            $validated = $request->validate([
                'items' => 'required|array',
                'items.*.product_id' => 'required|integer|exists:products,id',
                'items.*.quantity' => 'required|integer|min:1',
            ]);
    
            // Process the order logic here
            // Example: Calculate total price, deduct stock, save order in DB
    
            $orderTotal = 0;
            foreach ($validated['items'] as $item) {
                $product = Product::findOrFail($item['product_id']);
                $orderTotal += $product->price * $item['quantity'];
            }
    
            // Return success response
            return response()->json([
                'success' => true,
                'message' => 'Thanh toán thành công!',
                'total' => $orderTotal,
            ], 200);
        }
    
}
