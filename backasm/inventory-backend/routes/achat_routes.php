<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AchatController;
use App\Http\Controllers\AchatItemController;

Route::group(['middleware' => 'auth:api'], function() {
    Route::apiResource('achats', AchatController::class);
    Route::apiResource('achat_items', AchatItemController::class);
});
