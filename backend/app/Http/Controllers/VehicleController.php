<?php

namespace App\Http\Controllers;

use App\Models\Vehicle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class VehicleController extends Controller
{
    // LISTAR VEÍCULOS
    public function index(): JsonResponse
    {
        return response()->json(
            Vehicle::orderBy('id', 'desc')->get()
        );
    }

    // CADASTRAR VEÍCULO
    public function store(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'placa' => ['required', 'string', 'max:10', 'unique:vehicles,placa'],
            'marca' => ['required', 'string', 'max:100'],
            'modelo' => ['required', 'string', 'max:100'],
            'ano' => ['required', 'integer', 'between:1900,2100'],
        ]);

        $vehicle = Vehicle::create($dados);

        return response()->json($vehicle, 201);
    }

    // CONSULTAR UM VEÍCULO
    public function show(Vehicle $vehicle): JsonResponse
    {
        return response()->json($vehicle);
    }

    // EDITAR VEÍCULO
    public function update(Request $request, Vehicle $vehicle): JsonResponse
    {
        $dados = $request->validate([
            'placa' => [
                'sometimes',
                'required',
                'string',
                'max:10',
                Rule::unique('vehicles', 'placa')->ignore($vehicle->id),
            ],
            'marca' => ['sometimes', 'required', 'string', 'max:100'],
            'modelo' => ['sometimes', 'required', 'string', 'max:100'],
            'ano' => ['sometimes', 'required', 'integer', 'between:1900,2100'],
        ]);

        $vehicle->update($dados);

        return response()->json($vehicle);
    }

    // EXCLUIR VEÍCULO
    public function destroy(Vehicle $vehicle): JsonResponse
    {
        if ($vehicle->fuelings()->exists()) {
            return response()->json([
                'message' => 'Este veículo possui abastecimentos e não pode ser excluído.',
            ], 409);
        }

        $vehicle->delete();

        return response()->json([
            'message' => 'Veículo excluído com sucesso.',
        ]);
    }
}
