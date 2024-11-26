<?php

namespace App\Http\Controllers\Frontend;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;
use Illuminate\Support\Facades\DB;

class ProductController extends Controller
{
    public function productView($slug)
    {
        $data['detail'] = \App\Models\SettingDetail::find(1);
        $data['categories'] = \App\Models\Category::where('status', 'active')->where('parent_id', null)->get();

        $product = \App\Models\Product::where('slug', $slug)->where('status', 'active')->first();

        if ($product) {
            // Breadcrumb info
            $cat = \App\Models\Category::where('id', $product->cat_id)->where('status', 'active')->first();
            $data['pagetitle'] = "Sản phẩm";
            $data['links'] = [];

            if ($cat) {
                $link = new \App\Models\Links();
                $link->title = $cat->title;
                $link->url = route('front.product.cat', $cat->slug);
                array_push($data['links'], $link);
            }

            $link = new \App\Models\Links();
            $link->title = $product->title;
            $link->url = '#';
            array_push($data['links'], $link);

            $data['product'] = $product;
            if (!$product) {
                return view($this->front_view . '.404', $data);
            }

            $data['page_up_title'] = $product->title;
            $product->hit = $product->hit + 1;
            $product->save();

            $sql_tag_blog = "SELECT c.* FROM (SELECT * FROM tag_products WHERE product_id = " . $data['product']->id . ") AS b LEFT JOIN tags AS c ON b.tag_id = c.id WHERE c.status = 'active'";
            $data['tags'] = DB::select($sql_tag_blog);

            $data['keyword'] = "";
            foreach ($data['tags'] as $tag) {
                $data['keyword'] .= $tag->title . ",";
            }

            $data['description'] = $product->summary;

            // Xử lý ảnh trong $product->photo
            if (is_string($product->photo)) {
                $photos = explode(',', $product->photo); // Nếu là chuỗi, dùng explode
            } elseif (is_array($product->photo)) {
                $photos = $product->photo; // Nếu là mảng, gán trực tiếp
            } else {
                $photos = []; // Trường hợp không hợp lệ, gán mảng rỗng
            }

            $data['ogimage'] = !empty($photos) && isset($photos[0]) ? $photos[0] : asset('path/to/default/image.jpg');

            $sql_new_blog = "SELECT * FROM products WHERE status = 'active' AND stock >= 0 ORDER BY id DESC LIMIT 6";
            $data['newpros'] = DB::select($sql_new_blog);

            $sql_pop_blog = "SELECT * FROM products WHERE status = 'active' AND stock >= 0 ORDER BY hit DESC LIMIT 6";
            $data['poppros'] = DB::select($sql_pop_blog);

            $sql_rand_pro = "SELECT * FROM products WHERE status = 'active' AND stock >= 0 AND cat_id = " . $product->cat_id . " ORDER BY RAND() LIMIT 6";
            $data['randpros'] = DB::select($sql_rand_pro);

            if (count($data['randpros']) < 6) {
                $sql_rand_pro = "SELECT * FROM products WHERE status = 'active' AND stock >= 0 ORDER BY RAND() LIMIT 6";
                $data['randpros'] = DB::select($sql_rand_pro);
            }

            return view($this->front_view . '.product.single', $data);
        } else {
            return view($this->front_view . '.404', $data);
        }
    }

    public function productSearch(Request $request)
    {
        if ($request->searchdata) {
            $searchdata = $request->datasearch;
            $sdatas = explode(" ", $searchdata);
            $searchdata = implode("%", $sdatas);

            $data['detail'] = \App\Models\SettingDetail::find(1);
            $data['categories'] = \App\Models\Category::where('status', 'active')->where('parent_id', null)->get();

            $data['pagetitle'] = "Kết quả tìm kiếm";
            $data['links'] = [];
            $link = new \App\Models\Links();
            $link->title = 'Kết quả tìm kiếm';
            $link->url = '#';
            array_push($data['links'], $link);

            $searchdata = $request->searchdata;
            $data['products'] = DB::table('products')->where(function ($query_sub) use ($searchdata) {
                $query_sub->where('title', 'LIKE', '%' . $searchdata . '%')
                    ->orWhere('description', 'LIKE', '%' . $searchdata . '%')
                    ->orWhere('summary', 'LIKE', '%' . $searchdata . '%');
            })->where('status', 'active')->paginate(20)->withQueryString();

            $sql_new_blog = "SELECT * FROM products WHERE status = 'active' AND stock >= 0 ORDER BY id DESC LIMIT 6";
            $data['newpros'] = DB::select($sql_new_blog);

            $sql_pop_blog = "SELECT * FROM products WHERE status = 'active' AND stock >= 0 ORDER BY hit DESC LIMIT 6";
            $data['poppros'] = DB::select($sql_pop_blog);

            $sql_rand_pro = "SELECT * FROM products WHERE status = 'active' AND stock >= 0 ORDER BY RAND() LIMIT 6";
            $data['randpros'] = DB::select($sql_rand_pro);

            return view($this->front_view . '.product.search', $data);
        } else {
            return back()->with('success', 'Không có thông tin tìm kiếm!');
        }
    }
}
    