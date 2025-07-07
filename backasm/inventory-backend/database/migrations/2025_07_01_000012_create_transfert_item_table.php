<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTransfertItemTable extends Migration
{
    public function up(): void
    {
        Schema::create('transfert_item', function (Blueprint $table) {
            $table->id();
            $table->foreignId('transfert_id')->constrained('transfert')->onDelete('cascade');
            $table->foreignId('article_id')->constrained('article')->onDelete('cascade');
            $table->integer('quantite');
            $table->decimal('prix_ht', 10, 2)->nullable();
            $table->string('code_barre', 100)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transfert_item');
    }
} 