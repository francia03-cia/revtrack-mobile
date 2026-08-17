<?php
// database/migrations/2025_01_01_000005_create_notifications_configs_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications_configs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->boolean('daily_reminder_enabled')->default(true);
            $table->time('daily_reminder_time')->default('18:00:00');
            $table->boolean('goal_alert_enabled')->default(true);
            $table->decimal('monthly_goal_amount', 15, 2)->nullable();
            $table->boolean('weekly_report_enabled')->default(true);
            $table->string('weekly_report_day')->default('monday');
            $table->boolean('anomaly_alert_enabled')->default(true);
            $table->decimal('anomaly_threshold_percentage')->default(50.00);
            $table->boolean('push_notifications_enabled')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications_configs');
    }
};