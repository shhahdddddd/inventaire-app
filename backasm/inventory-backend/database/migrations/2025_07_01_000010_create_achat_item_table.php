<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAchatItemTable extends Migration
{
    public function up(): void
    {
        Schema::create('achat_item', function (Blueprint $table) {
            $table->id();
            $table->foreignId('achat_id')->constrained('achat')->onDelete('cascade');
            $table->foreignId('article_id')->constrained('article')->onDelete('cascade');
            $table->integer('quantite');
            $table->decimal('prix_ht', 10, 2)->nullable();
            $table->decimal('tva', 5, 2)->nullable();
            $table->decimal('prix_ttc', 10, 2)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('achat_item');
    }
} 