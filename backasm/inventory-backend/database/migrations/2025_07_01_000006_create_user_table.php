<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUserTable extends Migration
{
    public function up(): void
    {
        Schema::create('user', function (Blueprint $table) {
            $table->id();
            $table->string('username', 100)->unique();
            $table->string('mot_de_passe');
            $table->string('nom', 100)->nullable();
            $table->unsignedBigInteger('role_id');
            $table->unsignedBigInteger('station_id');
            $table->unsignedBigInteger('store_id');
            $table->timestamps();

            $table->foreign('role_id')->references('id')->on('role')->onDelete('cascade');
            $table->foreign('station_id')->references('id')->on('station_source')->onDelete('cascade');
            $table->foreign('store_id')->references('id')->on('store')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user');
    }
} 