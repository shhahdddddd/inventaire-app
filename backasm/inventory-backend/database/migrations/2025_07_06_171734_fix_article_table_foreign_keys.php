<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('article', function (Blueprint $table) {
            // Drop existing foreign key constraints if they exist
            try {
                $table->dropForeign(['famille']);
            } catch (Exception $e) {
                // Foreign key doesn't exist, continue
            }
            
            try {
                $table->dropForeign(['marque']);
            } catch (Exception $e) {
                // Foreign key doesn't exist, continue
            }
            
            // Add proper foreign key constraints
            $table->foreign('famille')->references('name')->on('famille')->onDelete('set null');
            $table->foreign('marque')->references('name')->on('marque')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('article', function (Blueprint $table) {
            $table->dropForeign(['famille']);
            $table->dropForeign(['marque']);
        });
    }
};
