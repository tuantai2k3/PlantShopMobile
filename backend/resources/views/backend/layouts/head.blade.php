<?php
    $detail = \App\Models\SettingDetail::find(1);
?>

<meta charset="utf-8">
@if ($detail)
    <link href="{{$detail->icon}}" rel="shortcut icon">
    <meta name="GENERATOR" content="{{$detail->short_name}}" />
    <meta name="keywords" content="{{ isset($keyword) ? $keyword : $detail->keyword }}" />
    <meta name="description" content="{{ isset($description) ? strip_tags($description) : $detail->memory }}" />
    <meta name="author" content="{{$detail->short_name}}">
    <title>{{$detail->company_name}}</title>
@else
    <!-- Default values if $detail is null -->
    <link href="default-icon.png" rel="shortcut icon"> <!-- Change to a default icon -->
    <meta name="GENERATOR" content="Default Generator" />
    <meta name="keywords" content="default, keywords" />
    <meta name="description" content="Default description" />
    <meta name="author" content="Default Author">
    <title>Default Company Name</title>
@endif

<!-- BEGIN: CSS Assets-->
<link rel="stylesheet" href="{{ asset('backend/assets/dist/css/app.css') }}" />
<link rel="stylesheet" href="{{ asset('backend/assets/vendor/css/bootstrap-switch-button.min.css') }}" />
<!-- END: CSS Assets-->
<!-- <script src="{{ asset('backend/assets/vendor/libs/jquery/jquery.js') }}"></script> -->

@yield('css')
@yield('scriptop')
