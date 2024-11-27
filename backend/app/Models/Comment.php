<?php

namespace App\Models;  // Thêm namespace

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;  // Import class Model

class Comment extends Model
{
    use HasFactory;  // Thêm trait HasFactory

    protected $fillable = [
        'name',
        'content',
        'url',
        'product_id',
        'email'
    ];

    // Thêm relationship với Product
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    // Nếu muốn tùy chỉnh timestamp
    // protected $timestamps = true;

    // Nếu muốn tùy chỉnh table name
    // protected $table = 'comments';

    // Cast các trường nếu cần
    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime'
    ];
}