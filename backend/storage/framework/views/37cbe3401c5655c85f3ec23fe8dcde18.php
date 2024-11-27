
<?php $__env->startSection('scriptop'); ?>

<meta name="csrf-token" content="<?php echo e(csrf_token()); ?>">
<link rel="stylesheet" href="<?php echo e(asset('vendor/file-manager/css/file-manager.css')); ?>">
<script src="<?php echo e(asset('vendor/file-manager/js/file-manager.js')); ?>"></script>

<link href="<?php echo e(asset('/js/css/tom-select.min.css')); ?>" rel="stylesheet">
<script src="<?php echo e(asset('/js/js/tom-select.complete.min.js')); ?>"></script>
<?php $__env->stopSection(); ?>
<?php $__env->startSection('content'); ?>

<div class = 'content'>
    <div class="intro-y flex items-center mt-8">
        <h2 class="text-lg font-medium mr-auto">
            Thêm bình luận
        </h2>
    </div>
    <div class="grid grid-cols-12 gap-12 mt-5">
        <div class="intro-y col-span-12 lg:col-span-12">
            <!-- BEGIN: Form Layout -->
            <form method="post" action="<?php echo e(route('comment.update',$comment->id)); ?>">
                <?php echo csrf_field(); ?>
                <?php echo method_field('patch'); ?>
                <div class="intro-y box p-5">
                    <div>
                        <label for="regular-form-1" class="form-label">URL</label>
                        <input id="url" value ="<?php echo e($comment->url); ?>" name="url" type="text" class="form-control" placeholder="url bình luận" required>
                    </div>
                     
                    <div class="mt-3">
                        <label for="regular-form-1" class="form-label">Tên</label>
                        <input id="name" value ="<?php echo e($comment->name); ?>" name="name" type="text" class="form-control" placeholder="tên người đăng" required>
                    </div>
                    <div class="mt-3">
                        <label for="regular-form-1" class="form-label">Email</label>
                        <input id="email" value ="<?php echo e($comment->email); ?>" name="email" type="text" class="form-control" placeholder="email" required>
                    </div>
                    <div class="mt-3">
                        
                        <label for="" class="form-label">Nội dung</label>
                       
                        <textarea class="form-control"   id="editor1" name="content" ><?php echo e($comment->content); ?></textarea>
                    </div>
                    
                    <div class="text-right mt-5">
                        <button type="submit" class="btn btn-primary w-24">Lưu</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
<?php $__env->stopSection(); ?>

<?php $__env->startSection('scripts'); ?>

 
<?php $__env->stopSection(); ?>



<?php echo $__env->make('backend.layouts.master', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\Users\BOOTWINDOW10\Desktop\Laptrinhdidong\Plant-shop\backend\resources\views/backend/comment/edit.blade.php ENDPATH**/ ?>