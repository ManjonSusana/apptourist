<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Restaurante extends Model
{
    protected $table = 'restaurantes';

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
     * Obtener los favoritos de este restaurante
     */
    public function favoritos()
    {
        return $this->morphMany(Favorito::class, 'favoritable');
    }
}
