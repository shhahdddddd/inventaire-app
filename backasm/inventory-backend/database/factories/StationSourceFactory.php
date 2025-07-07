<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\StationSource;

class StationSourceFactory extends Factory
{
    protected $model = StationSource::class;

    public function definition()
    {
        return [
            'nom' => $this->faker->unique()->company,
            'address' => $this->faker->address,
            'city' => $this->faker->city,
            'governorate' => $this->faker->state,
            'postal_code' => $this->faker->postcode,
            'latitude' => $this->faker->latitude,
            'longitude' => $this->faker->longitude,
        ];
    }
} 