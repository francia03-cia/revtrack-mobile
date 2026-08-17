<?php
// database/migrations/2025_01_01_000007_create_user_startup_table.php (table pivot)

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Table pivot pour la gestion multi-startups (un utilisateur peut avoir plusieurs startups)
        Schema::create('startup_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('startup_id')->constrained()->onDelete('cascade');
            $table->enum('role', ['owner', 'admin', 'member'])->default('member');
            $table->timestamps();

            $table->unique(['user_id', 'startup_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('startup_user');
    }
};