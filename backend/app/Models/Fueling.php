<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Fueling extends Model
{
    protected $fillable = [
        'vehicle_id',
        'driver_id',
        'data',
        'litros',
        'valor_total',
        'quilometragem',
        'posto',
    ];

    protected $casts = [
        'data' => 'date:Y-m-d',
        'litros' => 'decimal:2',
        'valor_total' => 'decimal:2',
    ];

    public function vehicle(): BelongsTo
    {
        return $this->belongsTo(Vehicle::class);
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(Driver::class);
    }
}
