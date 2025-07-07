<?php

namespace Database\Seeders;

use App\Models\Famille;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class FamilleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $familles = [
            ['name' => 'Chocolat', 'designation' => 'Produits chocolatés', 'description' => 'Tous les produits à base de chocolat'],
            ['name' => 'Boissons', 'designation' => 'Boissons diverses', 'description' => 'Boissons gazeuses, jus, eaux'],
            ['name' => 'Snacks', 'designation' => 'Snacks et grignotages', 'description' => 'Chips, biscuits, bonbons'],
            ['name' => 'Produits laitiers', 'designation' => 'Lait et dérivés', 'description' => 'Lait, yaourt, fromage'],
            ['name' => 'Hygiène', 'designation' => 'Produits d\'hygiène', 'description' => 'Savon, shampoing, dentifrice'],
            ['name' => 'Électronique', 'designation' => 'Produits électroniques', 'description' => 'Téléphones, accessoires'],
            ['name' => 'Vêtements', 'designation' => 'Habillement', 'description' => 'Vêtements et accessoires'],
            ['name' => 'Maison', 'designation' => 'Articles de maison', 'description' => 'Décoration, ustensiles'],
        ];

        foreach ($familles as $famille) {
            Famille::firstOrCreate(
                ['name' => $famille['name']],
                $famille
            );
        }
    }
}
