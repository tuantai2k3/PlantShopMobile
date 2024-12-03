<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use App\Models\User;
use App\Models\Order;
use App\Models\Wishlist;
use App\Models\AddressBook;
use App\Models\UserSetting;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Response;

class ProfileController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }

    public function getProfile(Request $request)
    {
        try {
            $user = $request->user();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], Response::HTTP_UNAUTHORIZED);
            }

            // Lấy thêm thông tin cần thiết
            $userData = [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'address' => $user->address,
                'phone' => $user->phone,
                // Thêm các trường khác nếu cần
            ];

            return response()->json([
                'success' => true,
                'data' => $userData
            ], Response::HTTP_OK);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching profile',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function updateProfile(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'full_name' => 'string|required|max:255',
                'address' => 'string|required|max:255',
                'photo' => 'image|mimes:jpeg,png,jpg,gif|max:2048',
                'description' => 'string|nullable|max:1000',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'errors' => $validator->errors()
                ], Response::HTTP_UNPROCESSABLE_ENTITY);
            }

            $user = $request->user();
            $data = $request->only(['full_name', 'address', 'description']);

            // Xử lý upload ảnh
            if ($request->hasFile('photo')) {
                // Xóa ảnh cũ nếu có
                if ($user->photo) {
                    Storage::disk('public')->delete($user->photo);
                }
                
                $photoPath = $request->file('photo')->store('photos/users', 'public');
                $data['photo'] = $photoPath;
            }

            $user->update($data);

            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully',
                'data' => $user
            ], Response::HTTP_OK);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error updating profile',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function changePassword(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'current_password' => 'required|string',
                'new_password' => 'required|string|min:8|confirmed',
                'new_password_confirmation' => 'required'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'errors' => $validator->errors()
                ], Response::HTTP_UNPROCESSABLE_ENTITY);
            }

            $user = $request->user();

            if (!Hash::check($request->current_password, $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Current password is incorrect'
                ], Response::HTTP_UNPROCESSABLE_ENTITY);
            }

            if ($request->current_password === $request->new_password) {
                return response()->json([
                    'success' => false,
                    'message' => 'New password must be different from current password'
                ], Response::HTTP_UNPROCESSABLE_ENTITY);
            }

            $user->update([
                'password' => Hash::make($request->new_password)
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Password changed successfully'
            ], Response::HTTP_OK);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error changing password',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    public function addAddress(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'full_name' => 'required|string|max:255',
                'phone' => 'required|string|max:20',
                'address' => 'required|string|max:255',
                'type' => 'required|in:shipping,invoice',
                'is_default' => 'boolean'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'errors' => $validator->errors()
                ], Response::HTTP_UNPROCESSABLE_ENTITY);
            }

            $user = $request->user();
            $data = $request->all();
            $data['user_id'] = $user->id;

            $address = AddressBook::create($data);

            // Xử lý địa chỉ mặc định
            if ($request->is_default) {
                $userSetting = UserSetting::firstOrCreate(
                    ['user_id' => $user->id],
                    []
                );

                $field = $request->type === 'shipping' ? 'ship_id' : 'invoice_id';
                $userSetting->$field = $address->id;
                $userSetting->save();
            }

            return response()->json([
                'success' => true,
                'message' => 'Address added successfully',
                'data' => $address
            ], Response::HTTP_CREATED);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error adding address',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function deleteAddress($id, Request $request)
    {
        try {
            $user = $request->user();
            $address = AddressBook::where('id', $id)
                ->where('user_id', $user->id)
                ->first();

            if (!$address) {
                return response()->json([
                    'success' => false,
                    'message' => 'Address not found'
                ], Response::HTTP_NOT_FOUND);
            }

            // Xóa reference trong user settings nếu là địa chỉ mặc định
            $userSetting = UserSetting::where('user_id', $user->id)->first();
            if ($userSetting) {
                if ($userSetting->ship_id == $id) {
                    $userSetting->ship_id = null;
                }
                if ($userSetting->invoice_id == $id) {
                    $userSetting->invoice_id = null;
                }
                $userSetting->save();
            }

            $address->delete();

            return response()->json([
                'success' => true,
                'message' => 'Address deleted successfully'
            ], Response::HTTP_OK);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error deleting address',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function getOrders(Request $request)
    {
        try {
            $user = $request->user();
            
            $orders = Order::where('customer_id', $user->id)
                ->with(['orderDetails.product'])
                ->orderBy('created_at', 'desc')
                ->paginate(10);

            return response()->json([
                'success' => true,
                'data' => $orders
            ], Response::HTTP_OK);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching orders',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function getWishlist(Request $request)
    {
        try {
            $user = $request->user();
            
            $wishlist = Wishlist::where('user_id', $user->id)
                ->whereHas('product', function ($query) {
                    $query->where('status', 'active');
                })
                ->with('product')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $wishlist
            ], Response::HTTP_OK);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching wishlist',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
}