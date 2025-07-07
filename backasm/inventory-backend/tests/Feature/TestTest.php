<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Route;
use Tests\TestCase;
use App\Http\Middleware\TestMiddleware;

class TestTest extends TestCase
{
    public function test_example(): void
    {
        $response = $this->get('/');
        $response->assertStatus(200);
    }

    public function test_middleware_route_works()
    {
        // ✅ Manually register the middleware alias
        app('router')->aliasMiddleware('test.middleware', TestMiddleware::class);

        // ✅ Define a route with the middleware
        Route::get('/api/middleware-test', function () {
            Log::info('Inside test route');
            return response()->json(['message' => 'OK']);
        })->middleware('test.middleware');

        // ✅ Clear the log file
        $logFile = storage_path('logs/laravel.log');
        if (File::exists($logFile)) {
            File::put($logFile, '');
        }

        // ✅ Hit the route
        $response = $this->get('/api/middleware-test');
        $response->assertStatus(200);

        // ✅ Confirm middleware log message was written
        $this->assertStringContainsString(
            'TestMiddleware was executed.',
            File::get($logFile)
        );
    }
}
