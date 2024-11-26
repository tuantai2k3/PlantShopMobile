<?php

use Illuminate\Support\Facades\Route;

use Illuminate\Http\Request;
/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/
// symlink('/home/banme/domains/banme.com/laravel/storage/app/public', '/home/banme/domains/banme.com/public_html/storage');
// Route::get('/', function () {
//     return view('frontend.index');
// });
////front end section
 
Route::post('theme_update',[\App\Http\Controllers\Frontend\IndexController::class,'themeUpdate'])->name('front.theme.update');

Route::post('comment_save',[\App\Http\Controllers\Frontend\BlogController::class,'blogSaveComment'])->name('front.comment.save');
Route::get('/', [App\Http\Controllers\Frontend\IndexController::class, 'home'])->name('home');
Route::get('/home2', [App\Http\Controllers\Frontend\IndexController::class, 'home2'])->name('home2');
/////product
Route::get('product/search',[\App\Http\Controllers\Frontend\ProductController::class,'productSearch'])->name('front.product.search');
Route::get('product/hot',[\App\Http\Controllers\Frontend\ProductController::class,'productHot'])->name('front.product.hot');
Route::get('product/view/{id}',[\App\Http\Controllers\Frontend\ProductController::class,'productView'])->name('front.product.view');
Route::get('product/category/{slug}',[\App\Http\Controllers\Frontend\ProductController::class,'categoryView'])->name('front.product.cat');
/////blog
Route::post('page_search',[\App\Http\Controllers\Frontend\BlogController::class,'pageSearch'])->name('front.page.search');
Route::get('category/{slug}',[\App\Http\Controllers\Frontend\BlogController::class,'categoryView'])->name('front.category.view');
Route::get('page/{slug}',[\App\Http\Controllers\Frontend\BlogController::class,'pageView'])->name('front.page.view');
Route::get('chinhsach/{slug}',[\App\Http\Controllers\Frontend\BlogController::class,'chinhsachView'])->name('front.chinhsach.view');
Route::get('categories',[\App\Http\Controllers\Frontend\BlogController::class,'allCategoryView'])->name('front.categories.view');
Route::get('tags/{slug}',[\App\Http\Controllers\Frontend\BlogController::class,'tagView'])->name('front.tag.view');
///auth
Route::get('front/login', [App\Http\Controllers\Frontend\IndexController::class, 'viewLogin'])->name('front.login');    
Route::post('front/login', [App\Http\Controllers\Frontend\IndexController::class, 'login'])->name('front.login.submit');    
Route::get('front/register', [App\Http\Controllers\Frontend\IndexController::class, 'viewRegister'])->name('front.register'); 
Route::post('front/register', [App\Http\Controllers\Frontend\IndexController::class, 'saveUser'])->name('front.register.submit'); 
//////profile
Route::get('front/profile', [App\Http\Controllers\Frontend\ProfileController::class, 'viewDasboard'])->name('front.profile'); 
Route::post('front/profile/changepassword', [App\Http\Controllers\Frontend\ProfileController::class, 'changePassword'])->name('front.profile.changepass'); 
Route::get('front/profile/edit', [App\Http\Controllers\Frontend\ProfileController::class, 'createEdit'])->name('front.profile.edit.view'); // Đổi tên
Route::post('front/profile/edit', [App\Http\Controllers\Frontend\ProfileController::class, 'updateProfile'])->name('front.profile.edit.submit'); // Đổi tên
Route::post('front/profile/addinvoiceadd', [App\Http\Controllers\Frontend\ProfileController::class, 'addInvoice'])->name('front.profile.addinvoiceadd'); 
Route::post('front/profile/addshipadd', [App\Http\Controllers\Frontend\ProfileController::class, 'addShip'])->name('front.profile.addshipadd'); 
Route::post('front/profile/updatetax', [App\Http\Controllers\Frontend\ProfileController::class, 'updateTax'])->name('front.profile.updatetax'); 
Route::post('front/profile/updatedescription', [App\Http\Controllers\Frontend\ProfileController::class, 'updateDescription'])->name('front.profile.updatedescription'); 
Route::post('front/profile/updatename', [App\Http\Controllers\Frontend\ProfileController::class, 'updateName'])->name('front.profile.updatename'); 
Route::get('front/profile/order', [App\Http\Controllers\Frontend\ProfileController::class, 'viewOrder'])->name('front.profile.order'); 
Route::get('front/profile/addressbook', [App\Http\Controllers\Frontend\ProfileController::class, 'addressbook'])->name('front.profile.addressbook'); 
Route::post('front/profile/update', [App\Http\Controllers\Frontend\ProfileController::class, 'updateProfile'])->name('front.profile.update'); 
///
Route::get('front/address/delete/{id}', [App\Http\Controllers\Frontend\ProfileController::class, 'deleteAddress'])->name('front.address.delete'); 
Route::get('front/address/setinvoice', [App\Http\Controllers\Frontend\ProfileController::class, 'setDefaultInvoice'])->name('front.address.setinvoice'); 
Route::get('front/address/setship', [App\Http\Controllers\Frontend\ProfileController::class, 'setDefaultShip'])->name('front.address.setship'); 

/////wishlist
Route::post('front/wishlist/add', [App\Http\Controllers\Frontend\WishListController::class, 'add'])->name('front.wishlist.add'); 
Route::get('front/wishlist/remove/{id}', [App\Http\Controllers\Frontend\WishListController::class, 'remove'])->name('front.wishlist.remove'); 
Route::get('front/wishlist/view', [App\Http\Controllers\Frontend\ProfileController::class, 'viewWishlist'])->name('front.wishlist.view'); 

/////shopping cart
Route::post('front/shopingcart/add', [App\Http\Controllers\Frontend\ShopingCartController::class, 'add'])->name('front.shopingcart.add'); 
Route::get('front/shopingcart/view', [App\Http\Controllers\Frontend\ShopingCartController::class, 'viewCart'])->name('front.shopingcart.view'); 
Route::get('front/shopingcart/getlist', [App\Http\Controllers\Frontend\ShopingCartController::class, 'getList'])->name('front.shopingcart.getlist'); 
Route::post('front/shopingcart/update', [App\Http\Controllers\Frontend\ShopingCartController::class, 'update'])->name('front.shopingcart.update'); 
Route::get('front/shopingcart/checkout', [App\Http\Controllers\Frontend\ShopingCartController::class, 'checkout'])->name('front.shopingcart.checkout'); 
Route::post('front/shopingcart/order', [App\Http\Controllers\Frontend\ShopingCartController::class, 'order'])->name('front.shopingcart.order'); //contact
Route::get('front/contact', [App\Http\Controllers\Frontend\IndexController::class, 'contact'])->name('front.contact'); 
Route::post('front/contact/send', [App\Http\Controllers\Frontend\IndexController::class, 'savecontact'])->name('front.contact.save'); 



// viewDasboard
/////
// Route::get('/', [App\Http\Controllers\HomeController::class, 'index'])->name('home');

Auth::routes(['register'=>false]);

Route::get('/admin', [App\Http\Controllers\HomeController::class, 'index'])->name('admin');

//Admin dashboard

Route::group( ['prefix'=>'admin/','middleware'=>'auth' ],function(){
    Route::get('/',[ \App\Http\Controllers\AdminController::class,'admin'])->name('admin');
    
    Route::middleware(['manager'])->group(function () {
    ///Banner section
    Route::resource('banner', \App\Http\Controllers\BannerController::class);
    Route::post('banner_status',[\App\Http\Controllers\BannerController::class,'bannerStatus'])->name('banner.status');
    Route::get('banner_search',[\App\Http\Controllers\BannerController::class,'bannerSearch'])->name('banner.search');
    ///tag section
    Route::resource('tag', \App\Http\Controllers\TagController::class);
    Route::post('tag_status',[\App\Http\Controllers\TagController::class,'tagStatus'])->name('tag.status');
    Route::get('tag_search',[\App\Http\Controllers\TagController::class,'tagSearch'])->name('tag.search');
    ///Role section
    Route::resource('role', \App\Http\Controllers\RoleController::class);
    Route::post('role_status',[\App\Http\Controllers\RoleController::class,'roleStatus'])->name('role.status');
    Route::get('role_search',[\App\Http\Controllers\RoleController::class,'roleSearch'])->name('role.search');
    Route::get('role_function\{id}',[\App\Http\Controllers\RoleController::class,'roleFunction'])->name('role.function');
    Route::get('role_selectall\{id}',[\App\Http\Controllers\RoleController::class,'roleSelectall'])->name('role.selectall');
    
    Route::post('functionstatus',[\App\Http\Controllers\RoleController::class,'roleFucntionStatus'])->name('role.functionstatus');
    
    
    ///cfunction section
    Route::resource('cmdfunction', \App\Http\Controllers\CFunctionController::class);
    Route::post('cmdfunction_status',[\App\Http\Controllers\CFunctionController::class,'cmdfunctionStatus'])->name('cmdfunction.status');
    Route::get('cmdfunction_search',[\App\Http\Controllers\CFunctionController::class,'cmdfunctionSearch'])->name('cmdfunction.search');

    ///Category section
    Route::resource('category', \App\Http\Controllers\CategoryController::class);
    Route::post('category_status',[\App\Http\Controllers\CategoryController::class,'categoryStatus'])->name('category.status');
    Route::get('category_search',[\App\Http\Controllers\CategoryController::class,'categorySearch'])->name('category.search');
    ///BlogCategory section
    Route::resource('blogcategory', \App\Http\Controllers\BlogCategoryController::class);
    Route::post('blogcategory_status',[\App\Http\Controllers\BlogCategoryController::class,'blogcatStatus'])->name('blogcategory.status');
    Route::get('blogcategory_search',[\App\Http\Controllers\BlogCategoryController::class,'blogcatSearch'])->name('blogcategory.search');
    ///Blog section
    Route::resource('blog', \App\Http\Controllers\BlogController::class);
    Route::post('blog_status',[\App\Http\Controllers\BlogController::class,'blogStatus'])->name('blog.status');
    Route::get('blog_search',[\App\Http\Controllers\BlogController::class,'blogSearch'])->name('blog.search');

    ///Brand section
    Route::resource('brand', \App\Http\Controllers\BrandController::class);
    Route::post('brand_status',[\App\Http\Controllers\BrandController::class,'brandStatus'])->name('brand.status');
    Route::get('brand_search',[\App\Http\Controllers\BrandController::class,'brandSearch'])->name('brand.search');
   
    

    ///Product section
    Route::resource('product', \App\Http\Controllers\ProductController::class);
    Route::post('product_status',[\App\Http\Controllers\ProductController::class,'productStatus'])->name('product.status');
    Route::get('product_search',[\App\Http\Controllers\ProductController::class,'productSearch'])->name('product.search');
    Route::get('product_sort',[\App\Http\Controllers\ProductController::class,'productSort'])->name('product.sort');
    Route::get('product_jsearch',[\App\Http\Controllers\ProductController::class,'productJsearch'])->name('product.jsearch');
    Route::get('product_stock_quantity',[\App\Http\Controllers\ProductController::class,'productStock_quantity'])->name('product.stock_quantity');
    Route::get('product_jsearchwi',[\App\Http\Controllers\ProductController::class,'productJsearchwi'])->name('product.jsearchwi');
    Route::get('product_groupprice',[\App\Http\Controllers\ProductController::class,'productGPriceSearch'])->name('product.groupprice');
    Route::get('product_jsearchwo',[\App\Http\Controllers\ProductController::class,'productJsearchwo'])->name('product.jsearchwo');
    Route::post('product_add',[\App\Http\Controllers\ProductController::class,'productAdd'])->name('product.add');
    Route::get('product_jsearchwf',[\App\Http\Controllers\ProductController::class,'productJsearchwf'])->name('product.jsearchwf');
    Route::get('product_jsearchic',[\App\Http\Controllers\ProductController::class,'productJsearchic'])->name('product.jsearchic');
    Route::get('product_tsearch',[\App\Http\Controllers\ProductController::class,'productTsearch'])->name('product.tsearch');
    Route::get('product_msearch',[\App\Http\Controllers\ProductController::class,'productMsearch'])->name('product.msearch');
    Route::post('product_addm',[\App\Http\Controllers\ProductController::class,'productAddm'])->name('product.addm');
    Route::get('product_jsearchms',[\App\Http\Controllers\ProductController::class,'productJsearchms'])->name('product.jsearchms');
    Route::get('product_jsearchmtw',[\App\Http\Controllers\ProductController::class,'productJsearchmtw'])->name('product.jsearchmtw');
    Route::get('product_jsearchptw',[\App\Http\Controllers\ProductController::class,'productJsearchptw'])->name('product.jsearchptw');
    Route::get('product_price/{id}',[\App\Http\Controllers\ProductController::class,'productPriceView'])->name('product.priceview');
    Route::post('product_price',[\App\Http\Controllers\ProductController::class,'productPriceUpdate'])->name('product.priceupdate');
    Route::get('product_print',[\App\Http\Controllers\ProductController::class,'productPrint'])->name('product.print');
   
   
    
    //User section
    Route::resource('user', \App\Http\Controllers\UserController::class);
    Route::post('user_status',[\App\Http\Controllers\UserController::class,'userStatus'])->name('user.status');
    Route::get('user_search',[\App\Http\Controllers\UserController::class,'userSearch'])->name('user.search');
    Route::get('user_sort',[\App\Http\Controllers\UserController::class,'userSort'])->name('user.sort');
    Route::post('user_detail',[\App\Http\Controllers\UserController::class,'userDetail'])->name('user.detail');
    Route::post('user_profile',[\App\Http\Controllers\UserController::class,'userUpdateProfile'])->name('user.profileupdate');
    Route::get('user_profile',[\App\Http\Controllers\UserController::class,'userViewProfile'])->name('user.profileview');
    
    ///UGroup section
    Route::resource('ugroup', \App\Http\Controllers\UGroupController::class);
    Route::post('ugroup_status',[\App\Http\Controllers\UGroupController::class,'ugroupStatus'])->name('ugroup.status');
    Route::get('ugroup_search',[\App\Http\Controllers\UGroupController::class,'ugroupSearch'])->name('ugroup.search');

   
    ///Log section
    Route::resource('log', \App\Http\Controllers\LogController::class);

      
    /// Setting  section
    Route::resource('setting', \App\Http\Controllers\SettingController::class);
       
    
    
    /// order section
    Route::resource('order', \App\Http\Controllers\OrderController::class);
    Route::get('order_search',[\App\Http\Controllers\OrderController::class,'orderSearch'])->name('order.search');
    Route::get('order_getProductList',[\App\Http\Controllers\OrderController::class,'getProductList'])->name('order.getProductList');
    Route::get('order_out/{id}',[\App\Http\Controllers\OrderController::class,'orderOut'])->name('order.out');
    Route::post('order_outupdate',[\App\Http\Controllers\OrderController::class,'orderOutUpdate'])->name('order.outupdate');
  
  
  
  Route::resource('comment',\App\Http\Controllers\CommentController::class);
  Route::post('comment_status',[\App\Http\Controllers\CommentController::class,'commentStatus'])->name('comment.status');
  Route::get('comment_search',[\App\Http\Controllers\CommentController::class,'commentSearch'])->name('comment.search');
  
       /////file upload/////////
 
    Route::post('avatar-upload', [\App\Http\Controllers\FilesController::class, 'avartarUpload' ])->name('upload.avatar');
    
    Route::post('product-upload', [\App\Http\Controllers\FilesController::class, 'productUpload' ])->name('upload.product');
    Route::post('upload-ckeditor', [\App\Http\Controllers\FilesController::class, 'ckeditorUpload' ])->name('upload.ckeditor');

    
});

});

////end//////////////

Route::get('unauthorized',[\App\Http\Controllers\Controller::class,'unauthorized'])->name('unauthorized');
