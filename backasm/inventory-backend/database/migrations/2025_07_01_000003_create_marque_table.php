<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateMarqueTable extends Migration
{
    public function up(): void
    {
        Schema::create('marque', function (Blueprint $table) {
            $table->string('name', 100)->primary();
            $table->string('designation', 100)->nullable();
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('marque');
    }
} 