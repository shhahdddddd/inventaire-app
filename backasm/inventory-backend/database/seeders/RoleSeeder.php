<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Role;
use App\Models\Store;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get or create the default store
        $store = Store::firstOrCreate(
            ['nom' => 'Store Principal'],
            [
                'nom' => 'Store Principal',
                'address' => '123 Main Street, City',
            ]
        );

        $roles = [
            [
                'nom' => 'admin',
                'description' => 'Administrator with full access to all features within the store'
            ],
            [
                'nom' => 'caissier',
                'description' => 'Gère les transactions avec les clients'
            ],
            [
                'nom' => "agent d'achat",
                'description' => 'Responsable des achats et approvisionnements'
            ],
            [
                'nom' => 'gestionnaire de stock',
                'description' => 'Gère les stocks et les niveaux d\'inventaire'
            ]
        ];

        foreach ($roles as $role) {
            Role::firstOrCreate(
                [
                    'nom' => $role['nom'],
                    'store_id' => $store->id
                ],
                [
                    'nom' => $role['nom'],
                    'description' => $role['description'],
                    'store_id' => $store->id,
                ]
            );
        }
    }
} 