<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Tymon\JwtAuth\Facades\JWTAuth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Login endpoint - verifica credenciales y devuelve JWT
     */
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        // Find user by email
        $user = \App\Models\User::where('email', $credentials['email'])->first();

        if (!$user) {
            return response()->json([
                'error' => 'Credenciales inválidas',
                'message' => 'El correo no está registrado'
            ], 401);
        }

        // Verify password
        if (!\Hash::check($credentials['password'], $user->password)) {
            return response()->json([
                'error' => 'Credenciales inválidas',
                'message' => 'La contraseña es incorrecta'
            ], 401);
        }

        // Generate JWT token
        $token = \JWTAuth::fromUser($user);

        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => config('jwt.ttl') * 60, // Convert minutes to seconds
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ]
        ]);
    }

    /**
     * Logout endpoint - invalida el token actual
     */
    public function logout()
    {
        JwtAuth::invalidate(JwtAuth::getToken());

        return response()->json([
            'message' => 'Sesión cerrada exitosamente'
        ], 200);
    }

    /**
     * Refresh endpoint - obtiene un nuevo token
     */
    public function refresh()
    {
        $token = JwtAuth::refresh(JwtAuth::getToken());

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => JwtAuth::factory()->getTTL() * 60,
        ], 200);
    }

    /**
     * Me endpoint - obtiene los datos del usuario autenticado
     */
    public function me()
    {
        $user = JwtAuth::parseToken()->authenticate();

        return response()->json([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ]
        ], 200);
    }
}
