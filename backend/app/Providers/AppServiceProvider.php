<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Services\RevenueService;
use App\Services\ExportService;
use App\Services\NotificationService;
use App\Services\ForecastService;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Enregistrer les services dans le container
        $this->app->singleton(RevenueService::class, function ($app) {
            return new RevenueService();
        });

        $this->app->singleton(ExportService::class, function ($app) {
            return new ExportService();
        });

        $this->app->singleton(NotificationService::class, function ($app) {
            return new NotificationService();
        });

        $this->app->singleton(ForecastService::class, function ($app) {
            return new ForecastService();
        });
    }

    public function boot(): void
    {
        //
    }
}