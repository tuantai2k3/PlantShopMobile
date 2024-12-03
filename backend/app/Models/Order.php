<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_name',
        'phone',
        'address', 
        'payment_method',
        'total_amount',
        'status',
        'coupon_code',
        'user_id'
    ];

    protected $casts = [
        'total_amount' => 'float',
        'created_at' => 'datetime',
        'updated_at' => 'datetime'
    ];

    // Quan hệ với bảng order_details
    public function orderDetails()
    {
        return $this->hasMany(OrderDetail::class, 'wo_id', 'id');
    }

    // Quan hệ với bảng users
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Các trạng thái đơn hàng
    public const STATUS_PENDING = 'pending';
    public const STATUS_PROCESSING = 'processing';
    public const STATUS_SHIPPING = 'shipping';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_CANCELLED = 'cancelled';

    public static function getAllStatuses()
    {
        return [
            self::STATUS_PENDING,
            self::STATUS_PROCESSING,
            self::STATUS_SHIPPING,
            self::STATUS_COMPLETED,
            self::STATUS_CANCELLED
        ];
    }

    // Scope để lọc theo trạng thái
    public function scopeStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    // Scope để lấy đơn hàng theo user
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    // Tính tổng tiền đơn hàng
    public function calculateTotal()
    {
        return $this->orderDetails->sum(function($detail) {
            return $detail->price * $detail->quantity;
        });
    }

    // Kiểm tra xem đơn hàng có thể hủy không
    public function canCancel()
    {
        return in_array($this->status, [self::STATUS_PENDING, self::STATUS_PROCESSING]);
    }
}