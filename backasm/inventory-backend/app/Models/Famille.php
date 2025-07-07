<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Famille extends Model
{
    use HasFactory;

    protected $table = 'famille';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'designation',
        'description',
    ];

    /**
     * Get the articles for the family.
     */
    public function articles(): HasMany
    {
        return $this->hasMany(Article::class);
    }
}
