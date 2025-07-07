<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class StationSource extends Model
{
    use HasFactory;

    protected $table = 'station_source';

    protected $fillable = [
        'nom',
        'address',
        'city',
        'governorate',
        'postal_code',
        'latitude',
        'longitude'
    ];

    public function users()
    {
        return $this->hasMany(User::class, 'station_id');
    }
}
