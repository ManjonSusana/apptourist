<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Favorito extends Model
{
    /** @use HasFactory<\Database\Factories\FavoritoFactory> */
    use HasFactory;

    protected $fillable = [
        'user_id',
        'favoritable_type',
        'favoritable_id',
    ];

    /**
     * Obtener el usuario propietario del favorito
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Obtener el objeto favorito (Bar, Evento, etc)
     */
    public function favoritable()
    {
        return $this->morphTo();
    }
}

