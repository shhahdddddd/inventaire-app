<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    use HasFactory;

    protected $table = 'role';

    protected $fillable = [
        'nom',
        'description',
        'store_id',
    ];

    public function users()
    {
        return $this->hasMany(User::class, 'role_id');
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }
}
