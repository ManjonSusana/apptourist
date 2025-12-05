<?php

return [

    /*
    |--------------------------------------------------------------------------
    | JWT Secret
    |--------------------------------------------------------------------------
    |
    | Ésta es la llave secreta utilizada para firmar los JWT tokens.
    | Asegúrate de configurar una llave segura en tu archivo .env
    |
    */
    'secret' => env('JWT_SECRET'),

    /*
    |--------------------------------------------------------------------------
    | JWT Time to Live
    |--------------------------------------------------------------------------
    |
    | Especifica cuántos minutos vivirá el JWT.
    | Por defecto es 1 hora (60 minutos).
    |
    */
    'ttl' => env('JWT_TTL', 60),

    /*
    |--------------------------------------------------------------------------
    | Refresh Time to Live
    |--------------------------------------------------------------------------
    |
    | Especifica cuántos minutos puede ser refrescado el JWT
    | antes de que expire completamente.
    |
    */
    'refresh_ttl' => env('JWT_REFRESH_TTL', 20160),

    /*
    |--------------------------------------------------------------------------
    | JWT Algorithm
    |--------------------------------------------------------------------------
    |
    | El algoritmo utilizado para firmar el token.
    | Soporta: HS256, HS384, HS512, RS256, ES256
    |
    */
    'algorithm' => env('JWT_ALGORITHM', 'HS256'),

];
