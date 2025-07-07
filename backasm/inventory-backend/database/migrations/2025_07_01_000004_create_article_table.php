<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateArticleTable extends Migration
{
    public function up(): void
    {
        Schema::create('article', function (Blueprint $table) {
            $table->id();
            $table->string('designation')->nullable();
            $table->string('reference', 100)->unique();
            $table->decimal('prix_achat', 10, 2)->nullable();
            $table->decimal('prix_vente', 10, 2)->nullable();
            $table->integer('quantite_stock')->nullable();
            $table->decimal('prix_ttc', 5, 2)->nullable();
            $table->string('famille', 100)->nullable();
            $table->string('marque', 100)->nullable();
            $table->string('type_prix', 50)->nullable();
            $table->decimal('tva', 5, 2)->nullable();
            $table->unsignedBigInteger('store_id');
            $table->timestamps();

            $table->foreign('famille')->references('name')->on('famille')->onDelete('set null');
            $table->foreign('marque')->references('name')->on('marque')->onDelete('set null');
            $table->foreign('store_id')->references('id')->on('store')->onDelete('cascade');
            $table->index('famille');
            $table->index('marque');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('article');
    }
} 