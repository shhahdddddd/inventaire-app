<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Achat extends Model
{
    use HasFactory;

    protected $table = 'achat';

    protected $fillable = [
        'type_piece',
        'num_piece',
        'date_achat',
        'fournisseur_nom',
        'station_id',
    ];

    public function achatItems()
    {
        return $this->hasMany(AchatItem::class);
    }

    public function fournisseur()
    {
        return $this->belongsTo(Fournisseur::class, 'fournisseur_nom', 'name');
    }

    public function station()
    {
        return $this->belongsTo(StationSource::class, 'station_id');
    }
}
