<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FechaDestacada extends Model
{
    protected $table = 'fechas_destacadas';

    protected $fillable = [
        'titulo',
        'descripcion',
        'icono',
        'categoria',
        'fechaInicio',
        'fechaFin',
        'permanente',
        'imagenAsset',
    ];

    protected $casts = [
        'fechaInicio' => 'date',
        'fechaFin'    => 'date',
        'permanente'  => 'boolean',
    ];

    public function eventos()
    {
        return $this->hasMany(EventoRelacionado::class, 'hitoId');
    }
}
