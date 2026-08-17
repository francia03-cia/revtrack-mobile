<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AuditLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'action',
        'entity',
        'entity_id',
        'old_values',
        'new_values',
        'ip_address',
        'user_agent',
    ];

    protected $casts = [
        'old_values' => 'array',
        'new_values' => 'array',
    ];

    // ============ RELATIONS ============
    
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // ============ SCOPES ============
    
    public function scopeForEntity($query, $entity, $entityId)
    {
        return $query->where('entity', $entity)
                     ->where('entity_id', $entityId);
    }

    public function scopeForAction($query, $action)
    {
        return $query->where('action', $action);
    }

    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeToday($query)
    {
        return $query->whereDate('created_at', today());
    }

    public function scopeThisWeek($query)
    {
        return $query->whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()]);
    }

    // ============ MÉTHODES UTILITAIRES ============
    
    public static function log($action, $entity, $entityId = null, $oldValues = null, $newValues = null)
    {
        return static::create([
            'user_id' => auth()->id(),
            'action' => $action,
            'entity' => $entity,
            'entity_id' => $entityId,
            'old_values' => $oldValues,
            'new_values' => $newValues,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }

    public function getActionLabelAttribute()
    {
        $labels = [
            'create' => 'Création',
            'update' => 'Modification',
            'delete' => 'Suppression',
            'login' => 'Connexion',
            'logout' => 'Déconnexion',
            'export' => 'Export',
            'import' => 'Import',
            'view' => 'Consultation',
            'share' => 'Partage',
        ];
        return $labels[$this->action] ?? $this->action;
    }

    public function getEntityLabelAttribute()
    {
        $labels = [
            'transaction' => 'Transaction',
            'category' => 'Catégorie',
            'startup' => 'Startup',
            'user' => 'Utilisateur',
            'report' => 'Rapport',
            'export' => 'Export',
        ];
        return $labels[$this->entity] ?? $this->entity;
    }

    public function getActionColorAttribute()
    {
        $colors = [
            'create' => 'success',
            'update' => 'warning',
            'delete' => 'danger',
            'login' => 'info',
            'logout' => 'info',
            'export' => 'primary',
        ];
        return $colors[$this->action] ?? 'secondary';
    }

    public function getUserNameAttribute()
    {
        return $this->user ? $this->user->name : 'Système';
    }

    public function getTimeAgoAttribute()
    {
        return $this->created_at->diffForHumans();
    }

    public function getFormattedDateAttribute()
    {
        return $this->created_at->format('d/m/Y H:i');
    }

    public function getSummaryAttribute()
    {
        $entityLabel = $this->entity_label;
        $actionLabel = $this->action_label;
        $userName = $this->user_name;
        
        return "{$userName} a effectué une {$actionLabel} sur {$entityLabel} #{$this->entity_id}";
    }
}