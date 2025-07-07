<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAchatTable extends Migration
{
    public function up(): void
    {
        Schema::create('achat', function (Blueprint $table) {
            $table->id();
            $table->string('type_piece', 100)->nullable();
            $table->string('num_piece', 100)->nullable();
            $table->string('fournisseur_nom')->nullable();
            $table->unsignedBigInteger('station_id')->nullable();
            $table->date('date_achat')->nullable();
            $table->timestamps();

            $table->foreign('fournisseur_nom')->references('name')->on('fournisseur')->onDelete('set null');
            $table->foreign('station_id')->references('id')->on('station_source')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('achat');
    }
} 