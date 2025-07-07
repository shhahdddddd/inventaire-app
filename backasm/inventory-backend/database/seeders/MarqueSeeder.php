<?php

namespace Database\Seeders;

use App\Models\Marque;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class MarqueSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $marques = [
            ['name' => 'Nutella', 'designation' => 'Nutella', 'description' => 'Marque de pâte à tartiner'],
            ['name' => 'Coca-Cola', 'designation' => 'Coca-Cola', 'description' => 'Boissons gazeuses'],
            ['name' => 'Pepsi', 'designation' => 'Pepsi', 'description' => 'Boissons gazeuses'],
            ['name' => 'Lay\'s', 'designation' => 'Lay\'s', 'description' => 'Chips et snacks'],
            ['name' => 'Doritos', 'designation' => 'Doritos', 'description' => 'Chips tortilla'],
            ['name' => 'Nestlé', 'designation' => 'Nestlé', 'description' => 'Produits alimentaires'],
            ['name' => 'Danone', 'designation' => 'Danone', 'description' => 'Produits laitiers'],
            ['name' => 'Apple', 'designation' => 'Apple', 'description' => 'Produits électroniques'],
            ['name' => 'Samsung', 'designation' => 'Samsung', 'description' => 'Produits électroniques'],
            ['name' => 'Nike', 'designation' => 'Nike', 'description' => 'Vêtements et chaussures'],
            ['name' => 'Adidas', 'designation' => 'Adidas', 'description' => 'Vêtements et chaussures'],
            ['name' => 'IKEA', 'designation' => 'IKEA', 'description' => 'Meubles et articles de maison'],
        ];

        foreach ($marques as $marque) {
            Marque::firstOrCreate(
                ['name' => $marque['name']],
                $marque
            );
        }
    }
}
