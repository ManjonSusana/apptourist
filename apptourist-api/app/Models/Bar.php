<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Bar extends Model
{
    protected $table = 'bares'; // importante: no es "bars"

    protected $fillable = [
        'nombre',
        'direccion',
        'categoria',
        'descripcion',
        'imagenAsset',
        'rating',
        'imagenes',
    ];

    protected $casts = [
        'rating'   => 'float',
        'imagenes' => 'array',
    ];

    /**
     * Obtener los favoritos de este bar
     */
    public function favoritos()
    {
        return $this->morphMany(Favorito::class, 'favoritable');
    }
}

