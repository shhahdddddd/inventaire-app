<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InventaireItem extends Model
{
    use HasFactory;

    protected $table = 'inventaire_item';

    protected $fillable = [
        'intervention_id',
        'article_id',
        'quantite_relle',
        'qte_stock',
        'ecart',
        'motif_ecart',
        'prix_ttc',
    ];

    public function inventaire()
    {
        return $this->belongsTo(Inventaire::class, 'intervention_id');
    }

    public function article()
    {
        return $this->belongsTo(Article::class, 'article_id');
    }
}
