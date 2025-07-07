<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;
use App\Models\Role;
use App\Models\StationSource;
use App\Models\Store;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $table = 'user';

    protected $fillable = [
        'username',
        'mot_de_passe',
        'nom',
        'role_id',
        'station_id',
        'store_id',
        'status',
        // add other columns as needed
    ];

    protected $hidden = [
        'mot_de_passe',
    ];

    // Remove the appends and casts that conflict with password handling
    // protected $appends = ['status'];

    // Remove the casts method as it conflicts with manual password hashing
    // protected function casts(): array
    // {
    //     return [
    //         'mot_de_passe' => 'hashed',
    //     ];
    // }

    // Use username for authentication instead of email
    public function getAuthIdentifierName()
    {
        return 'username';
    }

    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [];
    }
    
    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    public function station()
    {
        return $this->belongsTo(StationSource::class);
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }
    
    public function getAuthPassword()
    {
        return $this->mot_de_passe;
    }

    public function hasRole($roleName)
    {
        return $this->role && strtolower($this->role->nom) === strtolower($roleName);
    }

    public function hasAnyRole($roles)
    {
        if (is_string($roles)) {
            $roles = explode(',', $roles);
        }
        
        foreach ($roles as $role) {
            if ($this->hasRole(trim($role))) {
                return true;
            }
        }
        
        return false;
    }

    public function isAdmin()
    {
        return $this->hasRole('admin');
    }

    public function isAgentAchat()
    {
        return $this->hasRole('agent d\'achat');
    }

    public function isGestionnaireStock()
    {
        return $this->hasRole('gestionnaire de stock');
    }

    public function isCashier()
    {
        return $this->hasRole('caissier');
    }

    public function getStatusAttribute()
    {
        // Check if status column exists in database, otherwise return default
        return $this->attributes['status'] ?? 'active';
    }

    public function setStatusAttribute($value)
    {
        $this->attributes['status'] = $value;
    }
}
