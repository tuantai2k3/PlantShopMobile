<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderDetail extends Model
{
    use HasFactory;

    protected $fillable = [
        'wo_id',
        'product_id',
        'quantity',
        'price'
    ];

    protected $casts = [
        'quantity' => 'integer',
        'price' => 'float'
    ];

    // Quan hệ với bảng orders
    public function order()
    {
        return $this->belongsTo(Order::class, 'wo_id', 'id');
    }

    // Quan hệ với bảng products
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    // Tính thành tiền của từng item
    public function getSubtotalAttribute()
    {
        return $this->quantity * $this->price;
    }

    // Scope để lấy chi tiết đơn hàng theo sản phẩm
    public function scopeForProduct($query, $productId)
    {
        return $query->where('product_id', $productId);
    }

    // Scope để lấy chi tiết đơn hàng theo đơn hàng
    public function scopeForOrder($query, $orderId)
    {
        return $query->where('wo_id', $orderId);
    }

    // Boot method để thêm các events
    protected static function boot()
    {
        parent::boot();

        // Trước khi lưu, tự động lấy giá sản phẩm nếu không được set
        static::saving(function ($orderDetail) {
            if (empty($orderDetail->price)) {
                $product = Product::find($orderDetail->product_id);
                if ($product) {
                    $orderDetail->price = $product->price;
                }
            }
        });
    }
}