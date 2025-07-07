<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateInventaireTable extends Migration
{
    public function up(): void
    {
        Schema::create('inventaire', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('user')->onDelete('set null');
            $table->foreignId('station_id')->nullable()->constrained('station_source')->onDelete('set null');
            $table->date('date_ouverture')->nullable();
            $table->date('date_cloture')->nullable();
            $table->text('ecart')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventaire');
    }
} 