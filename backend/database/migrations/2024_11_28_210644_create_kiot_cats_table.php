<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
{
    Schema::table('comments', function (Blueprint $table) {
        $table->unsignedBigInteger('product_id')->nullable(); // Thêm cột product_id
        $table->dropColumn('url'); // Xóa cột url nếu không còn sử dụng
    });
}

public function down()
{
    Schema::table('comments', function (Blueprint $table) {
        $table->dropColumn('product_id');
        $table->string('url')->nullable(); // Khôi phục cột url nếu cần
    });
}

};
