<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Product;
use App\Models\Order;
use App\Models\OrderDetail;
use App\Models\UGroup;
use App\Models\User;
use Illuminate\Support\Facades\Validator;

class OrderController extends Controller
{
    protected $pagesize;
    
    public function __construct()
    {
        $this->pagesize = env('NUMBER_PER_PAGE', '20');
        $this->middleware('auth:api')->only(['store']); // Use auth:api for API routes
        $this->middleware('auth')->except(['store']); // Use regular auth for web routes
    }

    // API endpoint để tạo đơn hàng từ Flutter app
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'customerName' => 'required|string',
                'phone' => 'required|string',
                'address' => 'required|string',
                'paymentMethod' => 'required|string',
                'items' => 'required|array',
                'items.*.product_id' => 'required|exists:products,id',
                'items.*.quantity' => 'required|integer|min:1',
                'totalAmount' => 'required|numeric'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            DB::beginTransaction();

            // Tạo đơn hàng mới
            $order = new Order();
            $order->customer_name = $request->customerName;
            $order->phone = $request->phone;
            $order->address = $request->address;
            $order->payment_method = $request->paymentMethod;
            $order->total_amount = $request->totalAmount;
            $order->status = 'pending';
            $order->coupon_code = $request->couponCode;
            $order->save();

            // Tạo chi tiết đơn hàng
            foreach ($request->items as $item) {
                $product = Product::find($item['product_id']);
                if (!$product) {
                    DB::rollBack();
                    return response()->json([
                        'status' => false,
                        'message' => 'Product not found: ' . $item['product_id']
                    ], 404);
                }

                // Kiểm tra tồn kho
                if ($product->quantity < $item['quantity']) {
                    DB::rollBack();
                    return response()->json([
                        'status' => false,
                        'message' => 'Insufficient stock for product: ' . $product->title
                    ], 400);
                }

                // Tạo chi tiết đơn hàng
                $orderDetail = new OrderDetail();
                $orderDetail->wo_id = $order->id;
                $orderDetail->product_id = $item['product_id'];
                $orderDetail->quantity = $item['quantity'];
                $orderDetail->price = $product->price;
                $orderDetail->save();

                // Cập nhật số lượng tồn kho
                $product->quantity -= $item['quantity'];
                $product->save();
            }

            DB::commit();

            return response()->json([
                'status' => true,
                'message' => 'Order created successfully',
                'data' => [
                    'order_id' => $order->id,
                    'total_amount' => $order->total_amount,
                    'status' => $order->status
                ]
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => false,
                'message' => 'Error creating order',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Hiển thị danh sách đơn hàng trong admin panel
    public function index()
    {
        $func = "order_list";
        if(!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        $active_menu = "or_list";
        $breadcrumb = '
        <li class="breadcrumb-item"><a href="#">/</a></li>
        <li class="breadcrumb-item active" aria-current="page">Danh sách đặt hàng</li>';
        
        $orders = Order::with(['orderDetails.product'])
                      ->orderBy('created_at', 'DESC')
                      ->paginate($this->pagesize);
                      
        return view('backend.orders.index', compact('orders', 'breadcrumb', 'active_menu'));
    }

    // Xem chi tiết đơn hàng
    public function show(string $id)
    {
        $func = "order_list";
        if(!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        $order = Order::with(['orderDetails.product'])->find($id);
        
        if(!$order) {
            return back()->with('error', 'Không tìm thấy đơn hàng');
        }

        $active_menu = "or_list";
        $breadcrumb = '
        <li class="breadcrumb-item"><a href="#">/</a></li>
        <li class="breadcrumb-item"><a href="'.route('order.index').'">DS đặt hàng</a></li>
        <li class="breadcrumb-item active" aria-current="page">Xem chi tiết</li>';

        return view('backend.orders.show', compact('order', 'breadcrumb', 'active_menu'));
    }

    // API endpoint để cập nhật trạng thái đơn hàng
    public function updateStatus(Request $request, string $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'status' => 'required|in:pending,processing,shipping,completed,cancelled'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Invalid status',
                    'errors' => $validator->errors()
                ], 422);
            }

            $order = Order::find($id);
            if (!$order) {
                return response()->json([
                    'status' => false,
                    'message' => 'Order not found'
                ], 404);
            }

            $order->status = $request->status;
            $order->save();

            return response()->json([
                'status' => true,
                'message' => 'Order status updated successfully',
                'data' => $order
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Error updating order status',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Xóa đơn hàng
    public function destroy(string $id)
    {
        $func = "order_delete";
        if(!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        try {
            DB::beginTransaction();

            $order = Order::with('orderDetails')->find($id);
            if (!$order) {
                return response()->json([
                    'status' => false,
                    'message' => 'Không tìm thấy đơn hàng!'
                ], 404);
            }

            // Hoàn lại số lượng tồn kho
            foreach ($order->orderDetails as $detail) {
                $product = Product::find($detail->product_id);
                if ($product) {
                    $product->quantity += $detail->quantity;
                    $product->save();
                }
            }

            // Xóa chi tiết đơn hàng
            OrderDetail::where('wo_id', $id)->delete();
            
            // Xóa đơn hàng
            $order->delete();

            DB::commit();
            return redirect()->route('order.index')->with('success', 'Xóa đơn hàng thành công!');

        } catch (\Exception $e) {
            DB::rollBack();
            return back()->with('error', 'Lỗi khi xóa đơn hàng: ' . $e->getMessage());
        }
    }
}