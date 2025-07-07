<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTransfertTable extends Migration
{
    public function up(): void
    {
        Schema::create('transfert', function (Blueprint $table) {
            $table->id();
            $table->foreignId('station_source_id')->constrained('station_source')->onDelete('cascade');
            $table->foreignId('station_destination_id')->constrained('station_destinataire')->onDelete('cascade');
            $table->date('date_transfert')->nullable();
            $table->string('etat', 20)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transfert');
    }
} 