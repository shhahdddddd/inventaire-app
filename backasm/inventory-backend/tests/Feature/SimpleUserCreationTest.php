<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;

class SimpleUserCreationTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_user_with_factory()
    {
        $user = User::factory()->create();
        $this->assertNotNull($user);
        $this->assertDatabaseHas('user', ['id' => $user->id]);
        $this->assertDatabaseHas('role', ['id' => $user->role_id]);
    }
} 