<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Store extends Model
{
    use HasFactory;

    protected $table = 'store';

    protected $fillable = [
        'nom',
        'address',
    ];

    public function users()
    {
        return $this->hasMany(User::class, 'store_id');
    }
} 