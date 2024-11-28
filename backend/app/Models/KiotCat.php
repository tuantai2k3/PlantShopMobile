<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KiotCat extends Model
{
    use HasFactory;

    protected $table = 'kiot_cats'; // Xác định bảng tương ứng

    // Định nghĩa quan hệ với bảng Category
    public function category()
    {
        return $this->belongsTo(Category::class, 'categoryId');
    }
}
