<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Fournisseur extends Model
{
    use HasFactory;

    protected $table = 'fournisseur';
    protected $primaryKey = 'name';
    public $incrementing = false;
    protected $keyType = 'string';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'contact_nom',
        'phone',
        'email',
        'address',
    ];

    /**
     * Get the articles for the supplier.
     */
    public function articles(): HasMany
    {
        return $this->hasMany(Article::class);
    }
}
