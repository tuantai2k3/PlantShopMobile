@extends('backend.layouts.master')
@section('scriptop')
<meta name="csrf-token" content="{{ csrf_token() }}">
<style>
    #thumbnail {
        pointer-events: none;
    }
    #holder img {
        border-radius: 0.375rem;
        margin: 0.2rem;
    }
</style>
<script src="{{ asset('js/js/tom-select.complete.min.js') }}"></script>
<link rel="stylesheet" href="{{ asset('/js/css/tom-select.min.css') }}">
@endsection
@section('content')
<div class='content'>
    @include('backend.layouts.notification')
    <div class="intro-y flex items-center mt-8">
        <h2 class="text-lg font-medium mr-auto">Điều chỉnh sản phẩm</h2>
    </div>
    <div class="grid grid-cols-12 gap-12 mt-5">
        <div class="intro-y col-span-12 lg:col-span-12">
            <!-- BEGIN: Form Layout -->
            <form method="post" action="{{ route('product.update', $product->id) }}">
                @csrf
                @method('patch')
                <div class="intro-y box p-5">
                    <div>
                        <label for="title" class="form-label">Tiêu đề</label>
                        <input id="title" name="title" value="{{ $product->title }}" type="text" class="form-control" placeholder="Nhập tiêu đề">
                    </div>
                    <div class="mt-3">
                        <label for="photo" class="form-label">Photo</label>
                        <div>
                            <div class="px-4 pb-4 mt-5 flex items-center cursor-pointer relative">
                                <div id="dropzone-photo" class="dropzone grid grid-cols-10 gap-5 pl-4 pr-5 py-5" url="{{ route('upload.product') }}">
                                    <div class="fallback"><input name="file" type="file" /></div>
                                    <div class="dz-message" data-dz-message>
                                        <div class="font-medium">Kéo thả hoặc chọn nhiều ảnh.</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="grid grid-cols-10 gap-5 pl-4 pr-5 py-5">
                            @php
    // Kiểm tra nếu $product->photo là chuỗi
    $photos = is_string($product->photo) ? explode(',', $product->photo) : [];
@endphp

<div class="grid grid-cols-10 gap-5 pl-4 pr-5 py-5">
    <!-- Hiển thị các ảnh hiện có -->
    @foreach ($photos as $photo)
    <div data-photo="{{ $photo }}" class="product_photo col-span-5 md:col-span-2 h-28 relative image-fit cursor-pointer zoom-in">
        <img class="rounded-md" src="{{ $photo }}" alt="Product Photo">
        <div title="Xóa hình này?" class="tooltip w-5 h-5 flex items-center justify-center absolute rounded-full text-white bg-danger right-0 top-0 -mr-2 -mt-2">
            <i class="btn_remove w-4 h-4" data-lucide="x"></i>
        </div>
    </div>
    @endforeach

    <!-- Trường ẩn lưu ảnh cũ -->
    <input type="hidden" id="photo_old" name="photo_old" value="{{ implode(',', $photos) }}">
</div>
<!-- Trường ẩn lưu ảnh mới -->
<input type="hidden" id="photo_new" name="photo_new">

                            <input type="hidden" id="photo_old" name="photo_old" value="{{ implode(',', $photos) }}">
                        </div>
                        <input type="hidden" id="photo_new" name="photo_new">
                    </div>
                    <div class="mt-3">
                        <label for="summary" class="form-label">Mô tả ngắn</label>
                        <textarea class="form-control" id="editor1" name="summary">{{ $product->summary }}</textarea>
                    </div>
                    <div class="mt-3">
                        <label for="description" class="form-label">Mô tả</label>
                        <textarea class="editor" id="editor2" name="description">{{ $product->description }}</textarea>
                    </div>
                    <div class="mt-3">
                        <label for="price_out" class="form-label">Giá bán</label>
                        <input id="price_out" name="price" type="number" class="form-control" value="{{ $product->price }}">
                    </div>
                    <div class="mt-3">
                        <label for="cat_id" class="form-label">Danh mục</label>
                        <select name="cat_id" class="form-select">
                            @foreach($categories as $cat)
                            <option value="{{ $cat->id }}" {{ $cat->id == $product->cat_id ? 'selected' : '' }}>{{ $cat->title }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="mt-3">
                        <label for="brand_id" class="form-label">Nhà sản xuất</label>
                        <select name="brand_id" class="form-select">
                            <option value="">--chọn nhà sản xuất--</option>
                            @foreach($brands as $brand)
                            <option value="{{ $brand->id }}" {{ $brand->id == $product->brand_id ? 'selected' : '' }}>{{ $brand->title }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="mt-3">
                        <label for="size" class="form-label">Kích thước</label>
                        <input id="size" name="size" value="{{ $product->size }}" type="text" class="form-control">
                    </div>
                    <div class="mt-3">
                        <label for="weight" class="form-label">Cân nặng</label>
                        <input id="weight" name="weight" value="{{ $product->weight }}" type="text" class="form-control">
                    </div>
                    <div class="mt-3">
                        <label for="expired" class="form-label">Bảo hành</label>
                        <input id="expired" name="expired" value="{{ $product->expired }}" type="number" class="form-control">
                        <div class="form-help mt-3">* Tính theo tháng</div>
                    </div>
                    <div class="mt-3">
                        <label for="tags" class="form-label">Tags</label>
                        <select id="select-junk" name="tag_ids[]" multiple class="form-select">
                            @foreach ($tags as $tag)
                            <option value="{{ $tag->id }}" {{ in_array($tag->id, $tag_ids->pluck('tag_id')->toArray()) ? 'selected' : '' }}>
                                {{ $tag->title }}
                            </option>
                            @endforeach
                        </select>
                    </div>
                    <div class="mt-3">
                        <label for="status" class="form-label">Tình trạng</label>
                        <select name="status" class="form-select">
                            <option value="active" {{ $product->status == 'active' ? 'selected' : '' }}>Active</option>
                            <option value="inactive" {{ $product->status == 'inactive' ? 'selected' : '' }}>Inactive</option>
                        </select>
                    </div>
                    <div class="mt-3">
                        @if($errors->any())
                        <div class="alert alert-danger">
                            <ul>
                                @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                                @endforeach
                            </ul>
                        </div>
                        @endif
                    </div>
                    <div class="text-right mt-5">
                        <button type="submit" class="btn btn-primary w-24">Lưu</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
@section('scripts')
<script>
    $(document).ready(function() {
        var select = new TomSelect('#select-junk', {
            maxItems: 100,
            plugins: ['remove_button'],
            create: true
        });

        $(".btn_remove").click(function() {
            $(this).closest(".product_photo").remove();
            updatePhotoList();
        });

        function updatePhotoList() {
            let photos = [];
            $(".product_photo").each(function() {
                photos.push($(this).data("photo"));
            });
            $("#photo_old").val(photos.join(","));
        }

        let dropzone = new Dropzone("#dropzone-photo", {
            url: "{{ route('upload.product') }}",
            maxFilesize: 2,
            acceptedFiles: "image/*",
            addRemoveLinks: true,
            headers: {
                'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
            },
            success: function(file, response) {
                if (response.status) {
                    let newPhotos = $("#photo_new").val() ? $("#photo_new").val().split(",") : [];
                    newPhotos.push(response.link);
                    $("#photo_new").val(newPhotos.join(","));
                }
            },
            removedfile: function(file) {
                let newPhotos = $("#photo_new").val().split(",");
                newPhotos = newPhotos.filter(photo => photo !== file.name);
                $("#photo_new").val(newPhotos.join(","));
                file.previewElement.remove();
            }
        });
    });
</script>
@endsection
