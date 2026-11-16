<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Vehicle extends Model
{
    protected $fillable = [
        'placa',
        'marca',
        'modelo',
        'ano',
    ];

    public function fuelings(): HasMany
    {
        return $this->hasMany(Fueling::class);
    }
}
