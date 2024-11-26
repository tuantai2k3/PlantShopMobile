<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Passport\HasApiTokens;
use App\Notifications\ResetPasswordNotification; // Thêm import cho reset password

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'code',
        'global_id',
        'full_name',
        'username',
        'email',
        'password',
        'email_verified_at',
        'photo',
        'phone',
        'address',
        'description',
        'ship_id',
        'ugroup_id',
        'role',
        'budget',
        'totalpoint',
        'totalrevenue',
        'taxcode',
        'taxname', 
        'taxaddress',
        'status',
        'remember_token', // Thêm remember_token vào fillable
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    /**
     * Gửi thông báo reset password
     * Method mới thêm vào để hỗ trợ reset password
     */
    public function sendPasswordResetNotification($token)
    {
        $this->notify(new ResetPasswordNotification($token, $this->email));
    }

    /**
     * Xóa hoặc vô hiệu hóa user dựa vào role
     */
    public static function deleteUser($user_id){
        $user = User::find($user_id);
        if(auth()->user()->role == 'admin')
        {
            $user->delete();
            return 1;
        }
        else{
            $user->status = "inactive";
            $user->save();
            return 0;
        }
    }

    /**
     * Tạo mới user với mã tự động
     */
    public static function c_create($data)
    {
        try {
            \DB::beginTransaction(); // Thêm transaction để đảm bảo tính toàn vẹn dữ liệu

            $pro = User::create($data);
            $pro->code = "CUS" . sprintf('%09d',$pro->id);
            $pro->save();

            \DB::commit();
            return $pro;

        } catch(\Exception $e) {
            \DB::rollback();
            \Log::error('Error creating user: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Kiểm tra user có active không
     * Method mới thêm vào
     */
    public function isActive()
    {
        return $this->status === 'active';
    }

    /**
     * Kiểm tra user có phải admin không
     * Method mới thêm vào
     */
    public function isAdmin()
    {
        return $this->role === 'admin';
    }

    /**
     * Format phone number
     * Method mới thêm vào
     */
    public function getFormattedPhoneAttribute()
    {
        if(!$this->phone) return null;
        // Format phone number theo định dạng mong muốn
        return preg_replace('/(\d{4})(\d{3})(\d{3})/', '$1 $2 $3', $this->phone);
    }

    /**
     * Get user's full address
     * Method mới thêm vào
     */
    public function getFullAddressAttribute()
    {
        $parts = array_filter([$this->address, $this->taxaddress]);
        return implode(', ', $parts);
    }

    /**
     * Scope query để lấy users active
     * Method mới thêm vào
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    /**
     * Scope query để tìm user theo role
     * Method mới thêm vào
     */
    public function scopeByRole($query, $role)
    {
        return $query->where('role', $role);
    }

    /**
     * Update status của user
     * Method mới thêm vào
     */
    public function updateStatus($status)
    {
        if (!in_array($status, ['active', 'inactive'])) {
            throw new \InvalidArgumentException('Invalid status value');
        }
        $this->status = $status;
        return $this->save();
    }

    /**
     * Update password của user
     * Method mới thêm vào
     */
    public function updatePassword($newPassword)
    {
        $this->password = bcrypt($newPassword);
        return $this->save();
    }
}