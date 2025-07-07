<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\StationSource;

class RBACTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // Create roles
        Role::factory()->create(['nom' => 'admin']);
        Role::factory()->create(['nom' => 'inventory_manager']);
        Role::factory()->create(['nom' => 'purchasing_officer']);
        Role::factory()->create(['nom' => 'warehouse_staff']);
        Role::factory()->create(['nom' => 'employe_magasinier']);

        // Create a station
        StationSource::factory()->create();
    }

    public function test_admin_can_access_all_endpoints()
    {
        $adminRole = Role::where('nom', 'admin')->first();
        $user = User::factory()->create(['role_id' => $adminRole->id]);

        $this->actingAs($user, 'api');

        // Example endpoint that should be accessible to admin
        $response = $this->getJson('/api/articles');
        $response->assertStatus(200);
    }
} 