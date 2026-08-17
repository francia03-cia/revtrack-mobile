<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'color',
        'icon',
        'parent_id',
        'startup_id',
        'is_default',
    ];

    protected $casts = [
        'is_default' => 'boolean',
    ];

    // ============ RELATIONS ============
    
    public function parent()
    {
        return $this->belongsTo(Category::class, 'parent_id');
    }

    public function children()
    {
        return $this->hasMany(Category::class, 'parent_id');
    }

    public function startup()
    {
        return $this->belongsTo(Startup::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    // ============ SCOPES ============
    
    public function scopeRoot($query)
    {
        return $query->whereNull('parent_id');
    }

    public function scopeForStartup($query, $startupId)
    {
        return $query->where('startup_id', $startupId);
    }

    public function scopeDefault($query)
    {
        return $query->where('is_default', true);
    }

    // ============ MÉTHODES UTILITAIRES ============
    
    public static function getDefaultCategories()
    {
        return [
            ['name' => 'Ventes produits', 'color' => '#10B981', 'icon' => 'package'],
            ['name' => 'Services', 'color' => '#3B82F6', 'icon' => 'briefcase'],
            ['name' => 'Abonnements', 'color' => '#8B5CF6', 'icon' => 'repeat'],
            ['name' => 'Subventions', 'color' => '#F59E0B', 'icon' => 'gift'],
            ['name' => 'Autres', 'color' => '#6B7280', 'icon' => 'more-horizontal'],
        ];
    }

    public function isParent()
    {
        return $this->children()->exists();
    }

    public function getTotalTransactionsAttribute()
    {
        return $this->transactions()->count();
    }

    public function getTotalAmountAttribute()
    {
        return $this->transactions()->sum('amount');
    }

    public function getChildrenTree()
    {
        $children = $this->children()->get();
        $result = [];
        foreach ($children as $child) {
            $result[] = [
                'id' => $child->id,
                'name' => $child->name,
                'color' => $child->color,
                'icon' => $child->icon,
                'children' => $child->getChildrenTree(),
            ];
        }
        return $result;
    }

    public function getFullPathAttribute()
    {
        $path = [$this->name];
        $parent = $this->parent;
        while ($parent) {
            array_unshift($path, $parent->name);
            $parent = $parent->parent;
        }
        return implode(' / ', $path);
    }
}