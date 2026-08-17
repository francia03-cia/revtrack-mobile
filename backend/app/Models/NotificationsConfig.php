<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NotificationsConfig extends Model
{
    use HasFactory;

    protected $table = 'notifications_configs';

    protected $fillable = [
        'user_id',
        'daily_reminder_enabled',
        'daily_reminder_time',
        'goal_alert_enabled',
        'monthly_goal_amount',
        'weekly_report_enabled',
        'weekly_report_day',
        'anomaly_alert_enabled',
        'anomaly_threshold_percentage',
        'push_notifications_enabled',
    ];

    protected $casts = [
        'daily_reminder_enabled' => 'boolean',
        'goal_alert_enabled' => 'boolean',
        'weekly_report_enabled' => 'boolean',
        'anomaly_alert_enabled' => 'boolean',
        'push_notifications_enabled' => 'boolean',
        'daily_reminder_time' => 'datetime:H:i',
        'monthly_goal_amount' => 'decimal:2',
        'anomaly_threshold_percentage' => 'decimal:2',
    ];

    // ============ RELATIONS ============
    
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // ============ MÉTHODES UTILITAIRES ============
    
    public function isDailyReminderEnabled()
    {
        return $this->daily_reminder_enabled;
    }

    public function isGoalAlertEnabled()
    {
        return $this->goal_alert_enabled && $this->monthly_goal_amount > 0;
    }

    public function isAnomalyAlertEnabled()
    {
        return $this->anomaly_alert_enabled;
    }

    public function getWeeklyReportDayName()
    {
        $days = [
            'monday' => 'Lundi',
            'tuesday' => 'Mardi',
            'wednesday' => 'Mercredi',
            'thursday' => 'Jeudi',
            'friday' => 'Vendredi',
            'saturday' => 'Samedi',
            'sunday' => 'Dimanche',
        ];
        return $days[$this->weekly_report_day] ?? 'Lundi';
    }

    public function getDailyReminderTimeFormatted()
    {
        return $this->daily_reminder_time->format('H:i');
    }

    public function getMonthlyGoalProgress($startupId)
    {
        if (!$this->monthly_goal_amount || $this->monthly_goal_amount == 0) {
            return 0;
        }
        
        $currentRevenue = Transaction::forStartup($startupId)
                                     ->thisMonth()
                                     ->sum('amount');
        
        return round(($currentRevenue / $this->monthly_goal_amount) * 100, 2);
    }

    public function isGoalReached($startupId)
    {
        return $this->getMonthlyGoalProgress($startupId) >= 100;
    }
}