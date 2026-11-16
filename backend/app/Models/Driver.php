<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Driver extends Model
{
    protected $fillable = [
        'nome',
        'cpf',
        'cnh',
        'telefone',
    ];

    public function fuelings(): HasMany
    {
        return $this->hasMany(Fueling::class);
    }
}
