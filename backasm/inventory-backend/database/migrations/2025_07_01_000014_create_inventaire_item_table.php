<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateInventaireItemTable extends Migration
{
    public function up(): void
    {
        Schema::create('inventaire_item', function (Blueprint $table) {
            $table->id();
            $table->foreignId('intervention_id')->constrained('inventaire')->onDelete('cascade');
            $table->foreignId('article_id')->constrained('article')->onDelete('cascade');
            $table->integer('quantite_relle')->nullable();
            $table->integer('qte_stock')->nullable();
            $table->integer('ecart')->nullable();
            $table->text('motif_ecart')->nullable();
            $table->decimal('prix_ttc', 10, 2)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventaire_item');
    }
} 