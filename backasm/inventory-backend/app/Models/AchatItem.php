<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AchatItem extends Model
{
    use HasFactory;

    protected $table = 'achat_item';

    protected $fillable = [
        'achat_id',
        'article_id',
        'quantite',
        'prix_ht',
        'tva',
        'prix_ttc',
    ];

    public function achat()
    {
        return $this->belongsTo(Achat::class);
    }

    public function article()
    {
        return $this->belongsTo(Article::class);
    }
}
