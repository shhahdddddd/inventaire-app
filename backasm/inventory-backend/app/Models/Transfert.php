<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transfert extends Model
{
    use HasFactory;

    protected $table = 'transfert';

    protected $fillable = [
        'station_source_id',
        'station_destination_id',
        'date_transfert',
        'etat',
    ];

    public function transfertItems()
    {
        return $this->hasMany(TransfertItem::class);
    }

    public function stationSource()
    {
        return $this->belongsTo(StationSource::class, 'station_source_id');
    }

    public function stationDestination()
    {
        return $this->belongsTo(StationDestinataire::class, 'station_destination_id');
    }
}
