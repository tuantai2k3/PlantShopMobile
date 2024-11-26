<?php
namespace App\Http\Controllers\Api;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Password;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Mail;
use Illuminate\Auth\Events\PasswordReset;
use DB;

class AuthenticationController extends Controller
{
   // Validation messages
   private $messages = [
       'username.required' => 'Vui lòng nhập tên đăng nhập',
       'username.unique' => 'Tên đăng nhập đã được sử dụng',
       'phone.required' => 'Vui lòng nhập số điện thoại',
       'phone.unique' => 'Số điện thoại đã được đăng ký',
       'email.required' => 'Vui lòng nhập email',
       'email.email' => 'Email không đúng định dạng', 
       'email.unique' => 'Email đã được đăng ký',
       'password.required' => 'Vui lòng nhập mật khẩu',
       'password.min' => 'Mật khẩu phải có ít nhất 8 ký tự',
       'password.confirmed' => 'Xác nhận mật khẩu không khớp'
   ];

   /**
    * Register new user
    */
   public function register(Request $request)
   {
       try {
           // Validate input
           $validator = Validator::make($request->all(), [
               'username' => 'required|string|max:255|unique:users',
               'phone' => 'required|string|max:15|unique:users',
               'email' => 'required|string|email|max:255|unique:users',
               'password' => 'required|string|min:8|confirmed',
               'full_name' => 'nullable|string|max:255',
           ], $this->messages);

           if ($validator->fails()) {
               return response()->json([
                   'success' => false,
                   'message' => 'Vui lòng kiểm tra lại thông tin',
                   'errors' => $validator->errors()
               ], 422);
           }

           // Start transaction
           DB::beginTransaction();
           
           try {
               // Create user
               $user = User::create([
                   'username' => $request->username,
                   'phone' => $request->phone,
                   'email' => $request->email,
                   'password' => Hash::make($request->password),
                   'full_name' => $request->full_name ?? $request->username,
                   'status' => 'active',
                   'role' => 'user',
               ]);

               // Create token
               $tokenResult = $user->createToken('auth_token');
               
               DB::commit();

               // Return success response
               return response()->json([
                   'success' => true,
                   'message' => 'Đăng ký thành công',
                   'user' => $user,
                   'token' => [
                       'token' => $tokenResult->accessToken,
                       'type' => 'Bearer',
                   ]
               ], 201);

           } catch (\Exception $e) {
               DB::rollback();
               throw $e;
           }

       } catch (\Exception $e) {
           \Log::error('Register error: ' . $e->getMessage());
           return response()->json([
               'success' => false,
               'message' => 'Đăng ký thất bại',
               'error' => $e->getMessage()
           ], 500);
       }
   }

   /**
    * Login user
    */
   public function store(Request $request)
   {
       try {
           // Validate input
           $validator = Validator::make($request->all(), [
               'email' => 'required|email',
               'password' => 'required|string'
           ], [
               'email.required' => 'Vui lòng nhập email',
               'email.email' => 'Email không đúng định dạng',
               'password.required' => 'Vui lòng nhập mật khẩu'
           ]);

           if ($validator->fails()) {
               return response()->json([
                   'success' => false,
                   'message' => 'Vui lòng kiểm tra lại thông tin',
                   'errors' => $validator->errors()
               ], 422);
           }

           // Attempt login
           if (Auth::attempt($validator->validated())) {
               $user = Auth::user();
               
               // Check if account is active
               if ($user->status === 'inactive') {
                   return response()->json([
                       'success' => false,
                       'message' => 'Tài khoản đã bị vô hiệu hóa',
                   ], 401);
               }

               // Create new token
               $tokenResult = $user->createToken('auth_token');
               $token = $tokenResult->accessToken;

               // Save remember token
               $user->remember_token = $token;
               $user->save();

               return response()->json([
                   'success' => true,
                   'message' => 'Đăng nhập thành công',
                   'user' => $user,
                   'token' => [
                       'token' => $token,
                       'type' => 'Bearer'
                   ]
               ], 200);
           }

           // Login failed
           return response()->json([
               'success' => false,
               'message' => 'Email hoặc mật khẩu không chính xác',
           ], 401);

       } catch (\Exception $e) {
           \Log::error('Login error: ' . $e->getMessage());
           return response()->json([
               'success' => false,
               'message' => 'Đăng nhập thất bại',
               'error' => $e->getMessage()
           ], 500);
       }
   }

   /**
    * Logout user 
    */
   public function destroy(Request $request)
   {
       try {
           if (Auth::check()) {
               // Revoke token
               $request->user()->token()->revoke();
               
               return response()->json([
                   'success' => true,
                   'message' => 'Đăng xuất thành công',
               ], 200);
           }

           return response()->json([
               'success' => false,
               'message' => 'Người dùng chưa đăng nhập',
           ], 401);

       } catch (\Exception $e) {
           \Log::error('Logout error: ' . $e->getMessage());
           return response()->json([
               'success' => false,
               'message' => 'Đăng xuất thất bại',
               'error' => $e->getMessage()
           ], 500);
       }
   }

   /**
    * Send password reset link
    */
   public function forgotPassword(Request $request) 
   {
       try {
           $validator = Validator::make($request->all(), [
               'email' => 'required|email|exists:users,email'
           ], [
               'email.required' => 'Vui lòng nhập email',
               'email.email' => 'Email không đúng định dạng',
               'email.exists' => 'Email không tồn tại trong hệ thống'
           ]);

           if ($validator->fails()) {
               return response()->json([
                   'success' => false,
                   'message' => 'Vui lòng kiểm tra lại email',
                   'errors' => $validator->errors()
               ], 422);
           }

           // Generate reset token
           $token = Password::createToken(User::where('email', $request->email)->first());

           // Send reset link email
           $status = Password::sendResetLink($request->only('email'));

           if($status === Password::RESET_LINK_SENT) {
               return response()->json([
                   'success' => true,
                   'message' => 'Email khôi phục mật khẩu đã được gửi'
               ]);
           }

           return response()->json([
               'success' => false,
               'message' => 'Không thể gửi email khôi phục mật khẩu'
           ], 400);

       } catch (\Exception $e) {
           \Log::error('Forgot password error: ' . $e->getMessage());
           return response()->json([
               'success' => false,
               'message' => 'Có lỗi xảy ra, vui lòng thử lại sau',
               'error' => $e->getMessage()
           ], 500);
       }
   }

   /**
    * Reset password
    */
   public function resetPassword(Request $request)
   {
       try {
           $validator = Validator::make($request->all(), [
               'token' => 'required',
               'email' => 'required|email',
               'password' => 'required|min:8|confirmed',
           ]);

           if ($validator->fails()) {
               return response()->json([
                   'success' => false,
                   'message' => 'Vui lòng kiểm tra lại thông tin',
                   'errors' => $validator->errors()
               ], 422);
           }

           $status = Password::reset(
               $request->only('email', 'password', 'password_confirmation', 'token'),
               function ($user, $password) {
                   $user->forceFill([
                       'password' => Hash::make($password)
                   ])->setRememberToken(Str::random(60));

                   $user->save();

                   event(new PasswordReset($user));
               }
           );

           if ($status === Password::PASSWORD_RESET) {
               return response()->json([
                   'success' => true,
                   'message' => 'Mật khẩu đã được cập nhật'
               ]);
           }

           return response()->json([
               'success' => false,
               'message' => 'Không thể cập nhật mật khẩu'
           ], 400);

       } catch (\Exception $e) {
           \Log::error('Reset password error: ' . $e->getMessage());
           return response()->json([
               'success' => false,
               'message' => 'Có lỗi xảy ra, vui lòng thử lại sau', 
               'error' => $e->getMessage()
           ], 500);
       }
   }

   /**
    * Change password for logged in user
    */
   public function changePassword(Request $request)
   {
       try {
           $validator = Validator::make($request->all(), [
               'current_password' => 'required',
               'password' => 'required|string|min:8|confirmed|different:current_password'
           ], [
               'current_password.required' => 'Vui lòng nhập mật khẩu hiện tại',
               'password.required' => 'Vui lòng nhập mật khẩu mới',
               'password.min' => 'Mật khẩu mới phải có ít nhất 8 ký tự',
               'password.confirmed' => 'Xác nhận mật khẩu không khớp',
               'password.different' => 'Mật khẩu mới phải khác mật khẩu hiện tại'
           ]);

           if ($validator->fails()) {
               return response()->json([
                   'success' => false,
                   'message' => 'Vui lòng kiểm tra lại thông tin',
                   'errors' => $validator->errors()
               ], 422);
           }

           $user = Auth::user();

           // Verify current password
           if (!Hash::check($request->current_password, $user->password)) {
               return response()->json([
                   'success' => false,
                   'message' => 'Mật khẩu hiện tại không đúng'
               ], 400);
           }

           // Update password
           $user->password = Hash::make($request->password);
           $user->save();

           return response()->json([
               'success' => true,
               'message' => 'Đổi mật khẩu thành công'
           ]);

       } catch (\Exception $e) {
           \Log::error('Change password error: ' . $e->getMessage());
           return response()->json([
               'success' => false,
               'message' => 'Có lỗi xảy ra, vui lòng thử lại sau',
               'error' => $e->getMessage()
           ], 500);
       }
   }
}