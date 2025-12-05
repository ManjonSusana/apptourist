<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Tymon\JwtAuth\Exceptions\JwtException;
use Tymon\JwtAuth\Exceptions\TokenExpiredException;
use Tymon\JwtAuth\Exceptions\TokenInvalidException;
use Tymon\JwtAuth\Facades\JWTAuth;

class JwtMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        try {
            if (!JwtAuth::parseToken()->authenticate()) {
                return response()->json([
                    'message' => 'Usuario no encontrado'
                ], 404);
            }
        } catch (TokenExpiredException $e) {
            return response()->json([
                'message' => 'Token expirado'
            ], 401);
        } catch (TokenInvalidException $e) {
            return response()->json([
                'message' => 'Token inválido'
            ], 401);
        } catch (JwtException $e) {
            return response()->json([
                'message' => 'Error en el token JWT'
            ], 401);
        }

        return $next($request);
    }
}
