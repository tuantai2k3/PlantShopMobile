<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Password;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use App\Models\Product;
class ProductController extends Controller {

    public function __construct() 
    {
        
    }
    public function getAllProduct()
    {
        $products = Product::all();
       return response()->json([
        'success' =>true,
        'products' => $products,
       ],200);
       
    }
        public function show($id)
        {
            $product = Product::find($id);
    
            if (!$product) {
                return response()->json([
                    'message' => 'Product not found',
                ], 404);
            }
    
            return response()->json([
                'data' => $product,
            ]);
        }
    }

