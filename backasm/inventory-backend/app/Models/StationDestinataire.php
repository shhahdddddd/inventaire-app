<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StationDestinataire extends Model
{
    use HasFactory;

    protected $table = 'station_destinataire';

    protected $fillable = [
        'nom',
        'address',
        'city',
        'governorate',
        'postal_code',
        'latitude',
        'longitude'
    ];
}
