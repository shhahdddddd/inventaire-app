<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Article extends Model
{
    use HasFactory;

    protected $table = 'article';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'designation',
        'reference',
        'prix_achat',
        'prix_vente',
        'quantite_stock',
        'prix_ttc',
        'famille',
        'marque',
        'type_prix',
        'tva',
        'store_id',
    ];

    /**
     * Get the family that owns the article.
     */
    public function famille(): BelongsTo
    {
        return $this->belongsTo(Famille::class, 'famille', 'name');
    }

    /**
     * Get the brand that owns the article.
     */
    public function marque(): BelongsTo
    {
        return $this->belongsTo(Marque::class, 'marque', 'name');
    }

    /**
     * Get the supplier that owns the article.
     */
    public function fournisseur(): BelongsTo
    {
        return $this->belongsTo(Fournisseur::class);
    }

    /**
     * Get the store that owns the article.
     */
    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }
}
