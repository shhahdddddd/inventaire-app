<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Store;
use App\Models\Role;
use App\Models\StationSource;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            RoleSeeder::class,
            FamilleSeeder::class,
            MarqueSeeder::class,
        ]);
        
        // Create a default store
        $store = Store::firstOrCreate(
            ['nom' => 'Store Principal'],
            [
                'nom' => 'Store Principal',
                'address' => '123 Main Street, City',
            ]
        );

        // Create a default station
        $station = StationSource::firstOrCreate(
            ['nom' => 'Station Principale'],
            [
                'nom' => 'Station Principale',
                'description' => 'Station principale du magasin',
            ]
        );

        // Create default admin user
        User::firstOrCreate(
            ['username' => 'admin'],
            [
                'username' => 'admin',
                'mot_de_passe' => Hash::make('admin123'),
                'nom' => 'Administrateur Principal',
                'role_id' => Role::where('nom', 'admin')->first()->id,
                'store_id' => $store->id,
                'station_id' => $station->id,
            ]
        );
    }
}
