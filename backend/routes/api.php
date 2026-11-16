<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\AuthController;
use App\Http\Controllers\VehicleController;
use App\Http\Controllers\DriverController;
use App\Http\Controllers\FuelingController;
use App\Http\Controllers\UserController;

// Verificar se a API está funcionando
Route::get('/health', function () {
    return response()->json([
        'message' => 'API Controle de Frota online!',
    ]);
});

// Login público
Route::post('/login', [AuthController::class, 'login']);

// Rotas que exigem autenticação
Route::middleware('auth:sanctum')->group(function () {

    // Usuário autenticado
    Route::get('/me', [AuthController::class, 'me']);

    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);

    // Consultas permitidas para ambos os perfis
    Route::get('/vehicles', [VehicleController::class, 'index']);
    Route::get('/vehicles/{vehicle}', [VehicleController::class, 'show']);

    Route::get('/drivers', [DriverController::class, 'index']);
    Route::get('/drivers/{driver}', [DriverController::class, 'show']);

    Route::get('/fuelings', [FuelingController::class, 'index']);
    Route::get('/fuelings/{fueling}', [FuelingController::class, 'show']);

    // Administradores e motoristas podem registrar abastecimentos
    Route::post('/fuelings', [FuelingController::class, 'store']);

    // Operações exclusivas do administrador
    Route::middleware('admin')->group(function () {

        // CRUD de usuários
        Route::apiResource('users', UserController::class);

        // Gerenciamento de veículos
        Route::post('/vehicles', [VehicleController::class, 'store']);
        Route::put('/vehicles/{vehicle}', [VehicleController::class, 'update']);
        Route::patch('/vehicles/{vehicle}', [VehicleController::class, 'update']);
        Route::delete('/vehicles/{vehicle}', [VehicleController::class, 'destroy']);

        // Gerenciamento de motoristas
        Route::post('/drivers', [DriverController::class, 'store']);
        Route::put('/drivers/{driver}', [DriverController::class, 'update']);
        Route::patch('/drivers/{driver}', [DriverController::class, 'update']);
        Route::delete('/drivers/{driver}', [DriverController::class, 'destroy']);

        // Gerenciamento de abastecimentos
        Route::put('/fuelings/{fueling}', [FuelingController::class, 'update']);
        Route::patch('/fuelings/{fueling}', [FuelingController::class, 'update']);
        Route::delete('/fuelings/{fueling}', [FuelingController::class, 'destroy']);
    });
});
