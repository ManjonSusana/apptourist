<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lugar extends Model
{
    protected $table = 'lugares';

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
        'imagenes' => 'array', // se guarda como JSON en DB
    ];

    /**
     * Obtener los favoritos de este lugar
     */
    public function favoritos()
    {
        return $this->morphMany(Favorito::class, 'favoritable');
    }
}
