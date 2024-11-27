<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('comments', function (Blueprint $table) {
            // Kiểm tra xem cột đã tồn tại chưa
            if (!Schema::hasColumn('comments', 'product_id')) {
                $table->foreignId('product_id')
                    ->constrained('products')
                    ->onDelete('cascade');
            }
        });
    }

    public function down()
    {
        Schema::table('comments', function (Blueprint $table) {
            $table->dropForeign(['product_id']);
            $table->dropColumn('product_id');
        });
    }
};