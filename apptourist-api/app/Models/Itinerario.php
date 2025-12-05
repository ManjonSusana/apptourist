<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Itinerario extends Model
{
    protected $fillable = [
        'user_id',
        'itinerario_data',
    ];

    protected $casts = [
        'itinerario_data' => 'array',
    ];

    /**
     * Obtener el usuario propietario del itinerario
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
