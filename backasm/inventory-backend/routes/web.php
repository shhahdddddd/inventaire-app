<?php

use Illuminate\Support\Facades\DB;

Route::get('/test-db', function () {
    try {
        DB::connection()->getPdo();
        return "✅ Database connection is working!";
    } catch (\Exception $e) {
        return "❌ Could not connect to the database: " . $e->getMessage();
    }
});

Route::get('/', function () {
    return 'Welcome to the Inventory Backend API! Please use the API routes.';
});