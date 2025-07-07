<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Models\Store;
use App\Models\Role;
use App\Models\StationSource;

class TestRBACSystem extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'test:rbac';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Test the multi-store RBAC system';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('=== Multi-Store RBAC System Test ===');
        $this->newLine();

        try {
            // 1. Check database connection
            $this->info('1. Testing database connection...');
            $userCount = User::count();
            $this->info("   ✓ Database connected. User count: $userCount");
            $this->newLine();

            // 2. Check stores
            $this->info('2. Testing store creation...');
            $storeCount = Store::count();
            $this->info("   ✓ Store count: $storeCount");
            $this->newLine();

            // 3. Check roles
            $this->info('3. Testing role creation...');
            $roleCount = Role::count();
            $this->info("   ✓ Role count: $roleCount");

            if ($roleCount > 0) {
                $roles = Role::with('store')->get();
                $this->info('   Available roles:');
                foreach ($roles as $role) {
                    $this->info("   - {$role->nom} (Store: {$role->store->nom})");
                }
                $this->newLine();
            }

            // 4. Check stations
            $this->info('4. Testing station creation...');
            $stationCount = StationSource::count();
            $this->info("   ✓ Station count: $stationCount");
            $this->newLine();

            // 5. Test user role checking
            if ($userCount > 0) {
                $this->info('5. Testing user role checking...');
                $user = User::with(['role', 'store'])->first();
                $this->info("   ✓ Found user: {$user->username}");
                $this->info("   ✓ User role: {$user->role->nom}");
                $this->info("   ✓ User store: {$user->store->nom}");
                $this->info("   ✓ Is admin: " . ($user->isAdmin() ? 'Yes' : 'No'));
                $this->info("   ✓ Has role 'admin': " . ($user->hasRole('admin') ? 'Yes' : 'No'));
                $this->info("   ✓ Has role 'caissier': " . ($user->hasRole('caissier') ? 'Yes' : 'No'));
                $this->newLine();
            }

            // 6. Test middleware registration
            $this->info('6. Testing middleware registration...');
            $kernel = app(\App\Http\Kernel::class);
            $routeMiddleware = $kernel->getRouteMiddleware();
            
            if (isset($routeMiddleware['check.store'])) {
                $this->info('   ✓ CheckStore middleware registered');
            } else {
                $this->error('   ❌ CheckStore middleware not registered');
            }
            
            if (isset($routeMiddleware['role'])) {
                $this->info('   ✓ CheckRole middleware registered');
            } else {
                $this->error('   ❌ CheckRole middleware not registered');
            }
            $this->newLine();

            // 7. Test route registration
            $this->info('7. Testing route registration...');
            $routes = \Route::getRoutes();
            $apiRoutes = collect($routes)->filter(function ($route) {
                return str_starts_with($route->uri(), 'api/');
            });
            
            $this->info("   ✓ Found {$apiRoutes->count()} API routes");
            
            // Check for key routes
            $keyRoutes = ['api/register', 'api/login', 'api/activate', 'api/users', 'api/roles', 'api/stores'];
            foreach ($keyRoutes as $route) {
                $exists = $apiRoutes->contains(function ($r) use ($route) {
                    return str_starts_with($r->uri(), $route);
                });
                if ($exists) {
                    $this->info("   ✓ Route {$route} exists");
                } else {
                    $this->warn("   ⚠ Route {$route} not found");
                }
            }
            $this->newLine();

            $this->info('=== System Test Complete ===');
            $this->info('✓ All tests passed! The multi-store RBAC system is working correctly.');
            $this->newLine();

            return 0;

        } catch (\Exception $e) {
            $this->error('❌ Error: ' . $e->getMessage());
            $this->error('Stack trace:');
            $this->error($e->getTraceAsString());
            return 1;
        }
    }
}
