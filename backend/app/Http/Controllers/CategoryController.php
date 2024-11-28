<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\KiotCat;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class CategoryController extends Controller
{
    protected $pagesize;

    public function __construct()
    {
        $this->pagesize = env('NUMBER_PER_PAGE', '20');
        $this->middleware('auth');
    }

    public function index()
    {
        $func = "pcat_list";
        if (!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        $active_menu = "cat_list";
        $breadcrumb = '
        <li class="breadcrumb-item"><a href="#">/</a></li>
        <li class="breadcrumb-item active" aria-current="page">Danh mục</li>';
        
        $categories = Category::orderBy('id', 'DESC')->paginate($this->pagesize);
        return view('backend.categories.index', compact('categories', 'breadcrumb', 'active_menu'));
    }

    public function categorySearch(Request $request)
    {
        $func = "pcat_list";
        if (!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        if ($request->datasearch) {
            $active_menu = "cat_list";
            $searchdata = $request->datasearch;
            $categories = DB::table('categories')
                ->where('title', 'LIKE', '%' . $request->datasearch . '%')
                ->paginate($this->pagesize)
                ->withQueryString();
            
            $breadcrumb = '
            <li class="breadcrumb-item"><a href="#">/</a></li>
            <li class="breadcrumb-item"><a href="' . route('category.index') . '">Danh mục</a></li>
            <li class="breadcrumb-item active" aria-current="page"> tìm kiếm </li>';
            
            return view('backend.categories.search', compact('categories', 'breadcrumb', 'searchdata', 'active_menu'));
        } else {
            return redirect()->route('category.index')->with('success', 'Không có thông tin tìm kiếm!');
        }
    }

    public function categoryStatus(Request $request)
    {
        $func = "pcat_edit";
        if (!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        $status = $request->mode == 'true' ? 'active' : 'inactive';
        DB::table('categories')->where('id', $request->id)->update(['status' => $status]);

        return response()->json(['msg' => "Cập nhật thành công", 'status' => true]);
    }

    public function create()
    {
        $func = "pcat_add";
        if (!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        $active_menu = "cat_add";
        $breadcrumb = '
        <li class="breadcrumb-item"><a href="#">/</a></li>
        <li class="breadcrumb-item"><a href="' . route('category.index') . '">Danh mục</a></li>
        <li class="breadcrumb-item active" aria-current="page"> tạo danh mục </li>';
        
        $parent_cats = Category::where('is_parent', 1)->orderBy('title', 'ASC')->get();
        return view('backend.categories.create', compact('breadcrumb', 'active_menu', 'parent_cats'));
    }

    public function store(Request $request)
    {
        $func = "pcat_add";
        if (!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        $this->validate($request, [
            'title' => 'string|required',
            'summary' => 'string|nullable',
            'is_parent' => 'sometimes|in:1',
            'parent_id' => 'nullable',
            'status' => 'nullable|in:active,inactive',
        ]);

        $data = $request->all();
        if ($request->is_parent == null) $data['is_parent'] = 0;
        if ($data['is_parent'] == 1) $data['parent_id'] = null;

        $slug = Str::slug($request->input('title'));
        $slug_count = Category::where('slug', $slug)->count();
        if ($slug_count > 0) $slug .= time() . '-' . $slug;
        $data['slug'] = $slug;
        if ($request->photo == null) $data['photo'] = asset('backend/assets/dist/images/profile-6.jpg');

        $cat = Category::where('title', $data['title'])->first();
        if ($cat != null) return back()->with('error', 'Danh mục đã có');

        $status = Category::create($data);

        if ($status && env('KIOT_SYNC') == 1) {
            $kiotController = new KiotController();
            $kiotController->kiotAddCategory($data['title'], $status->id, $data['parent_id']);
        }

        return redirect()->route('category.index')->with('success', 'Tạo danh mục thành công!');
    }

    public function edit(string $id)
    {
        $func = "pcat_edit";
        if (!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        $category = Category::find($id);
        if (!$category) return back()->with('error', 'Không tìm thấy dữ liệu');

        $active_menu = "cat_list";
        $breadcrumb = '
        <li class="breadcrumb-item"><a href="#">/</a></li>
        <li class="breadcrumb-item"><a href="' . route('category.index') . '">Danh mục</a></li>
        <li class="breadcrumb-item active" aria-current="page"> điều chỉnh danh mục </li>';
        
        $parent_cats = Category::where('is_parent', 1)->orderBy('title', 'ASC')->get();
        return view('backend.categories.edit', compact('breadcrumb', 'category', 'active_menu', 'parent_cats'));
    }

    public function update(Request $request, string $id)
    {
        $func = "pcat_edit";
        if (!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        $category = Category::find($id);
        if (!$category) return back()->with('error', 'Không tìm thấy dữ liệu');

        $this->validate($request, [
            'title' => 'string|required',
            'summary' => 'string|nullable',
            'is_parent' => 'sometimes|in:1',
            'parent_id' => 'nullable',
            'status' => 'nullable|in:active,inactive',
        ]);

        $data = $request->all();
        if ($request->photo_old == null) {
            $data['photo_old'] = $category->photo;
        }

        if ($data['photo'] == null || $data['photo'] == "") $data['photo'] = $data['photo_old'];
        if ($data['photo'] == null || $data['photo'] == "") $data['photo'] = asset('backend/assets/dist/images/profile-6.jpg');

        if ($request->is_parent == null) $data['is_parent'] = 0;
        if ($data['is_parent'] == 1) $data['parent_id'] = null;

        $cat = Category::where('title', $data['title'])->where('id', '<>', $category->id)->first();
        if ($cat != null) return back()->with('error', 'Danh mục đã có');

        $status = $category->fill($data)->save();

        if ($status && env('KIOT_SYNC') == 1) {
            $kiotController = new KiotController();
            $kiotController->kiotUpdateCategory($data['title'], $category->id, $data['parent_id']);
        }

        return redirect()->route('category.index')->with('success', 'Cập nhật thành công');
    }

    public function destroy(string $id)
    {
        $func = "pcat_delete";
        if (!$this->check_function($func)) {
            return redirect()->route('unauthorized');
        }

        $category = Category::find($id);
        if (!$category) return back()->with('error', 'Không tìm thấy dữ liệu');

        // $kiot_cat = KiotCat::where('categoryId', $category->id)->first();
        // if ($kiot_cat) {
        //     $kiot_cat->delete();
        // }

        $status = $category->delete();

        if ($status) {
            $child_cat_ids = Category::where('parent_id', $id)->pluck('id');
            if (count($child_cat_ids) > 0) {
                Category::shiftChild($child_cat_ids);
            }
            return redirect()->route('category.index')->with('success', 'Xóa danh mục thành công!');
        } else {
            return back()->with('error', 'Có lỗi xảy ra!');
        }
    }
}
