<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Inventaire extends Model
{
    use HasFactory;

    protected $table = 'inventaire';

    protected $fillable = [
        'user_id',
        'station_id',
        'date_ouverture',
        'date_cloture',
        'ecart',
        'store_id',
    ];

    public function inventaireItems()
    {
        return $this->hasMany(InventaireItem::class, 'intervention_id');
    }

    public function stationSource()
    {
        return $this->belongsTo(StationSource::class, 'station_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
