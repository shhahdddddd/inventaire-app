<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ArticleController;
use App\Http\Controllers\FamilleController;
use App\Http\Controllers\MarqueController;
use App\Http\Controllers\FournisseurController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\StationSourceController;
use App\Http\Controllers\StationDestinataireController;
use App\Http\Controllers\TransfertController;
use App\Http\Controllers\TransfertItemController;
use App\Http\Controllers\InventaireController;
use App\Http\Controllers\InventaireItemController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\RoleController;
use App\Http\Controllers\StationController;
use App\Http\Controllers\StoreController;

// Minimal test route to verify API routing
Route::get('/test', function () {
    return response()->json(['status' => 'ok', 'message' => 'API is working']);
});

Route::post('/test-register', function (Request $request) {
    return response()->json([
        'status' => 'success',
        'message' => 'Test endpoint working',
        'data' => $request->all()
    ]);
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/activate', [AuthController::class, 'activate']);

Route::middleware(['auth:api', 'check.store'])->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/refresh', [AuthController::class, 'refresh']);
    
    Route::get('/protected-test', function () {
        return response()->json(['status' => 'ok', 'message' => 'Protected route is working']);
    });
    
    // Article management - Gestionnaire Stock and Admin
    Route::group(['middleware' => 'role:admin,gestionnaire de stock'], function () {
        Route::apiResource('articles', ArticleController::class);
        Route::apiResource('familles', FamilleController::class);
        Route::apiResource('marques', MarqueController::class);
    });
    
    // Fournisseur management - Agent Achat and Admin
    Route::group(['middleware' => 'role:admin,agent d\'achat'], function () {
        Route::apiResource('fournisseurs', FournisseurController::class);
    });
    
    // User management routes - Admin only
    Route::group(['prefix' => 'users', 'middleware' => 'role:admin'], function () {
        Route::get('/', [UserController::class, 'index']);
        Route::post('/', [UserController::class, 'store']);
        Route::get('/{id}', [UserController::class, 'show']);
        Route::put('/{id}', [UserController::class, 'update']);
        Route::delete('/{id}', [UserController::class, 'destroy']);
        Route::post('/invite', [UserController::class, 'invite']);
    });

    // Role management routes - Admin only
    Route::group(['prefix' => 'roles', 'middleware' => 'role:admin'], function () {
        Route::get('/', [RoleController::class, 'index']);
        Route::post('/', [RoleController::class, 'store']);
        Route::get('/{id}', [RoleController::class, 'show']);
        Route::put('/{id}', [RoleController::class, 'update']);
        Route::delete('/{id}', [RoleController::class, 'destroy']);
    });

    // Store management routes
    Route::group(['prefix' => 'stores'], function () {
        Route::get('/', [StoreController::class, 'index']);
        Route::get('/{id}', [StoreController::class, 'show']);
        Route::put('/{id}', [StoreController::class, 'update']);
        Route::get('/{id}/stats', [StoreController::class, 'stats']);
    });

    Route::group(['prefix' => 'stations'], function () {
        Route::get('/', [StationController::class, 'index']);
    });

    // Station Source Routes
    Route::group(['prefix' => 'station-sources'], function () {
        Route::get('/', [StationSourceController::class, 'index']);
        Route::post('/', [StationSourceController::class, 'store']);
        Route::get('/{id}', [StationSourceController::class, 'show']);
        Route::put('/{id}', [StationSourceController::class, 'update']);
        Route::delete('/{id}', [StationSourceController::class, 'destroy']);
    });

    // Station Destinataire Routes
    Route::group(['prefix' => 'station-destinataires'], function () {
        Route::get('/', [StationDestinataireController::class, 'index']);
        Route::post('/', [StationDestinataireController::class, 'store']);
        Route::get('/{id}', [StationDestinataireController::class, 'show']);
        Route::put('/{id}', [StationDestinataireController::class, 'update']);
        Route::delete('/{id}', [StationDestinataireController::class, 'destroy']);
    });

    // Transfert Routes - Gestionnaire Stock and Admin
    Route::group(['prefix' => 'transferts', 'middleware' => 'role:admin,gestionnaire de stock'], function () {
        Route::get('/', [TransfertController::class, 'index']);
        Route::post('/', [TransfertController::class, 'store']);
        Route::get('/{id}', [TransfertController::class, 'show']);
        Route::put('/{id}', [TransfertController::class, 'update']);
        Route::delete('/{id}', [TransfertController::class, 'destroy']);

        // Transfert Items Routes
        Route::group(['prefix' => '{transfert_id}/items'], function () {
            Route::get('/', [TransfertItemController::class, 'index']);
            Route::post('/', [TransfertItemController::class, 'store']);
            Route::get('/{id}', [TransfertItemController::class, 'show']);
            Route::put('/{id}', [TransfertItemController::class, 'update']);
            Route::delete('/{id}', [TransfertItemController::class, 'destroy']);
        });
    });

    // Inventaire Routes - Gestionnaire Stock and Admin
    Route::group(['prefix' => 'inventaires', 'middleware' => 'role:admin,gestionnaire de stock'], function () {
        Route::get('/', [InventaireController::class, 'index']);
        Route::post('/', [InventaireController::class, 'store']);
        Route::get('/{id}', [InventaireController::class, 'show']);
        Route::put('/{id}', [InventaireController::class, 'update']);
        Route::delete('/{id}', [InventaireController::class, 'destroy']);

        // Inventaire Items Routes
        Route::group(['prefix' => '{inventaire_id}/items'], function () {
            Route::get('/', [InventaireItemController::class, 'index']);
            Route::post('/', [InventaireItemController::class, 'store']);
            Route::get('/{id}', [InventaireItemController::class, 'show']);
            Route::put('/{id}', [InventaireItemController::class, 'update']);
            Route::delete('/{id}', [InventaireItemController::class, 'destroy']);
        });
    });
    
    // Protected routes with role-based middleware
    Route::middleware(['store.role.status'])->group(function () {
        require __DIR__.'/achat_routes.php';
    });
});

Route::get('/middleware-test', function (Request $request) {
    return response()->json([
        'status' => 'success',
        'message' => 'Middleware test passed',
    ]);
})->middleware(['test.middleware', 'log.achat']);
