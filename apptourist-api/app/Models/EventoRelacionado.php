<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EventoRelacionado extends Model
{
    protected $table = 'eventos_relacionados';

    protected $fillable = [
        'hitoId',
        'titulo',
        'descripcion',
        'ubicacion',
        'fechaHoraInicio',
    ];

    protected $casts = [
        'fechaHoraInicio' => 'datetime',
    ];

    public function hito()
    {
        return $this->belongsTo(FechaDestacada::class, 'hitoId');
    }
}
