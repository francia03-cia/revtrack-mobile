<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Startup extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'logo',
        'currency',
        'email',
        'phone',
        'address',
        'user_id',
    ];

    // ============ RELATIONS ============
    
    public function owner()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function users()
    {
        return $this->belongsToMany(User::class, 'startup_user')
                    ->withPivot('role')
                    ->withTimestamps();
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function categories()
    {
        return $this->hasMany(Category::class);
    }

    // ============ SCOPES ============
    
    public function scopeActive($query)
    {
        return $query->whereHas('users', function ($q) {
            $q->where('user_id', auth()->id());
        });
    }

    // ============ MÉTHODES UTILITAIRES ============
    
    public function getTotalRevenue($startDate = null, $endDate = null)
    {
        $query = $this->transactions();
        if ($startDate && $endDate) {
            $query->whereBetween('date', [$startDate, $endDate]);
        }
        return $query->sum('amount');
    }

    public function getMonthlyRevenue($month = null, $year = null)
    {
        $month = $month ?? now()->month;
        $year = $year ?? now()->year;
        return $this->transactions()
                    ->whereMonth('date', $month)
                    ->whereYear('date', $year)
                    ->sum('amount');
    }

    public function getDailyRevenue($date = null)
    {
        $date = $date ?? now()->toDateString();
        return $this->transactions()
                    ->whereDate('date', $date)
                    ->sum('amount');
    }

    public function getLogoUrlAttribute()
    {
        if ($this->logo) {
            return asset('storage/startups/' . $this->logo);
        }
        return null;
    }

    public function getTransactionCountAttribute()
    {
        return $this->transactions()->count();
    }

    public function getCategoryCountAttribute()
    {
        return $this->categories()->count();
    }

    public function getUserCountAttribute()
    {
        return $this->users()->count();
    }

    public function addUser(User $user, $role = 'member')
    {
        return $this->users()->attach($user->id, ['role' => $role]);
    }

    public function removeUser(User $user)
    {
        return $this->users()->detach($user->id);
    }

    public function updateUserRole(User $user, $role)
    {
        return $this->users()->updateExistingPivot($user->id, ['role' => $role]);
    }
}