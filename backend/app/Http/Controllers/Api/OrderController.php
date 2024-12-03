<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Order;

class OrderController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'name'           => 'required',
            'phone'          => 'required',
            'address'        => 'required',
            'total'          => 'required|numeric',
            'payment_method' => 'required',
            'items'          => 'required|array', // danh sách sản phẩm
        ]);

        $order = Order::create([
            'user_id'        => $request->user()->id,
            'name'           => $request->name,
            'phone'          => $request->phone,
            'address'        => $request->address,
            'total'          => $request->total,
            'payment_method' => $request->payment_method,
        ]);

        foreach ($request->items as $item)
        {
            $order->orderItems()->create([
                'product_id' => $item['product_id'],
                'quantity'   => $item['quantity'],
                'price'      => $item['price'],
            ]);
        }

        return response()->json(['message' => 'Order created successfully'], 201);
    }

}