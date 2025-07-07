<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TransfertItem extends Model
{
    use HasFactory;

    protected $table = 'transfert_item';

    protected $fillable = [
        'transfert_id',
        'article_id',
        'quantite',
        'prix_ht',
        'code_barre',
    ];

    public function transfert()
    {
        return $this->belongsTo(Transfert::class);
    }

    public function article()
    {
        return $this->belongsTo(Article::class);
    }
}
