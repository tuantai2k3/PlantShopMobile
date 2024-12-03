<?php
    $detail = \App\Models\SettingDetail::find(1);
?>

<meta charset="utf-8">
<?php if($detail): ?>
    <link href="<?php echo e($detail->icon); ?>" rel="shortcut icon">
    <meta name="GENERATOR" content="<?php echo e($detail->short_name); ?>" />
    <meta name="keywords" content="<?php echo e(isset($keyword) ? $keyword : $detail->keyword); ?>" />
    <meta name="description" content="<?php echo e(isset($description) ? strip_tags($description) : $detail->memory); ?>" />
    <meta name="author" content="<?php echo e($detail->short_name); ?>">
    <title><?php echo e($detail->company_name); ?></title>
<?php else: ?>
    <!-- Default values if $detail is null -->
    <link href="default-icon.png" rel="shortcut icon"> <!-- Change to a default icon -->
    <meta name="GENERATOR" content="Default Generator" />
    <meta name="keywords" content="default, keywords" />
    <meta name="description" content="Default description" />
    <meta name="author" content="Default Author">
    <title>Default Company Name</title>
<?php endif; ?>

<!-- BEGIN: CSS Assets-->
<link rel="stylesheet" href="<?php echo e(asset('backend/assets/dist/css/app.css')); ?>" />
<link rel="stylesheet" href="<?php echo e(asset('backend/assets/vendor/css/bootstrap-switch-button.min.css')); ?>" />
<!-- END: CSS Assets-->
<!-- <script src="<?php echo e(asset('backend/assets/vendor/libs/jquery/jquery.js')); ?>"></script> -->

<?php echo $__env->yieldContent('css'); ?>
<?php echo $__env->yieldContent('scriptop'); ?>
<?php /**PATH D:\CODE_VS\Plant-shop\backend\resources\views/backend/layouts/head.blade.php ENDPATH**/ ?>