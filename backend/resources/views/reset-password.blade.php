@component('mail::message')
# Yêu cầu khôi phục mật khẩu

Xin chào,

Bạn đã yêu cầu khôi phục mật khẩu cho tài khoản của mình. Vui lòng click vào nút bên dưới để đặt lại mật khẩu:

@component('mail::button', ['url' => $resetUrl])
Đặt lại mật khẩu
@endcomponent

Link này sẽ hết hạn sau 60 phút.

Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.

Trân trọng,<br>
{{ config('app.name') }}
@endcomponent