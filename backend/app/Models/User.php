<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Support\Str;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'avatar',
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    // ============ RELATIONS ============
    
    public function startups()
    {
        return $this->belongsToMany(Startup::class, 'startup_user')
                    ->withPivot('role')
                    ->withTimestamps();
    }

    public function ownedStartups()
    {
        return $this->hasMany(Startup::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function notificationsConfig()
    {
        return $this->hasOne(NotificationsConfig::class);
    }

    public function auditLogs()
    {
        return $this->hasMany(AuditLog::class);
    }

    // ============ SCOPES ============
    
    public function scopeAdmins($query)
    {
        return $query->where('role', 'admin');
    }

    public function scopeManagers($query)
    {
        return $query->where('role', 'manager');
    }

    public function scopeViewers($query)
    {
        return $query->where('role', 'viewer');
    }

    // ============ MÉTHODES UTILITAIRES ============
    
    public function isAdmin()
    {
        return $this->role === 'admin';
    }

    public function isManager()
    {
        return $this->role === 'manager';
    }

    public function isViewer()
    {
        return $this->role === 'viewer';
    }

    public function hasRole($role)
    {
        return $this->role === $role;
    }

    public function hasStartup($startupId)
    {
        return $this->startups()->where('startup_id', $startupId)->exists();
    }

    public function getCurrentStartup()
    {
        return $this->startups()->first();
    }

    public function getAvatarUrlAttribute()
    {
        if ($this->avatar) {
            return asset('storage/avatars/' . $this->avatar);
        }
        return 'https://ui-avatars.com/api/?name=' . urlencode($this->name) . '&background=4F46E5&color=fff';
    }

    public function getInitialsAttribute()
    {
        $words = explode(' ', $this->name);
        $initials = '';
        foreach ($words as $word) {
            $initials .= strtoupper(substr($word, 0, 1));
        }
        return $initials;
    }
}