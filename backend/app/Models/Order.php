<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'phone', 'shipping_address', 'payment_method', 'total_amount', 'status'];

    public function products()
    {
        return $this->belongsToMany(OrderProduct::class, 'order_product')
            ->withPivot('quantity', 'price')
            ->withTimestamps();
    }
}
