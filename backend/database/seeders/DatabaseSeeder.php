<?php
// database/seeders/DatabaseSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Création d'un utilisateur admin par défaut
        $adminId = DB::table('users')->insertGetId([
            'name' => 'Admin RevTrack',
            'email' => 'admin@revtrack.com',
            'password' => Hash::make('Admin123!'),
            'role' => 'admin',
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Création d'une startup par défaut
        $startupId = DB::table('startups')->insertGetId([
            'name' => 'Ma Startup',
            'currency' => 'Ar',
            'user_id' => $adminId,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Liaison admin - startup
        DB::table('startup_user')->insert([
            'user_id' => $adminId,
            'startup_id' => $startupId,
            'role' => 'owner',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Catégories par défaut
        $defaultCategories = [
            ['name' => 'Développement web', 'color' => '#4F46E5', 'icon' => 'code', 'is_default' => true],
            ['name' => 'Développement mobile', 'color' => '#7C3AED', 'icon' => 'smartphone', 'is_default' => true],
            ['name' => 'Intelligence artificielle & automatisation', 'color' => '#06B6D4', 'icon' => 'cpu', 'is_default' => true],
            ['name' => 'Administration systèmes & VPS', 'color' => '#8B5CF6', 'icon' => 'server', 'is_default' => true],
            ['name' => 'Conseil en stratégie IT', 'color' => '#F59E0B', 'icon' => 'trending-up', 'is_default' => true],
            ['name' => 'Électronique & circuits', 'color' => '#10B981', 'icon' => 'zap', 'is_default' => true],
            ['name' => 'Systèmes embarqués', 'color' => '#3B82F6', 'icon' => 'cpu', 'is_default' => true],
            ['name' => 'Internet des objets (IoT)', 'color' => '#EC4899', 'icon' => 'wifi', 'is_default' => true],
            ['name' => 'Cybersécurité', 'color' => '#EF4444', 'icon' => 'shield', 'is_default' => true],
            ['name' => 'Formation professionnelle', 'color' => '#F97316', 'icon' => 'graduation-cap', 'is_default' => true],
        ];
        foreach ($defaultCategories as $category) {
            DB::table('categories')->insert([
                'name' => $category['name'],
                'color' => $category['color'],
                'icon' => $category['icon'],
                'startup_id' => $startupId,
                'is_default' => $category['is_default'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // Configuration de notifications par défaut
        DB::table('notifications_configs')->insert([
            'user_id' => $adminId,
            'daily_reminder_enabled' => true,
            'daily_reminder_time' => '18:00:00',
            'goal_alert_enabled' => true,
            'monthly_goal_amount' => 10000000,
            'weekly_report_enabled' => true,
            'weekly_report_day' => 'monday',
            'anomaly_alert_enabled' => true,
            'anomaly_threshold_percentage' => 50.00,
            'push_notifications_enabled' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}