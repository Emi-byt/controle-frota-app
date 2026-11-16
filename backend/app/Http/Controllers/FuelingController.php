<?php

namespace App\Http\Controllers;

use App\Models\Fueling;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FuelingController extends Controller
{
    // LISTAR ABASTECIMENTOS
    public function index(): JsonResponse
    {
        return response()->json(
            Fueling::with(['vehicle', 'driver'])
                ->orderBy('data', 'desc')
                ->get()
        );
    }

    // CADASTRAR ABASTECIMENTO
    public function store(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'vehicle_id' => ['required', 'integer', 'exists:vehicles,id'],
            'driver_id' => ['required', 'integer', 'exists:drivers,id'],
            'data' => ['required', 'date'],
            'litros' => ['required', 'numeric', 'gt:0'],
            'valor_total' => ['required', 'numeric', 'gt:0'],
            'quilometragem' => ['required', 'integer', 'min:0'],
            'posto' => ['nullable', 'string', 'max:150'],
        ]);

        $fueling = Fueling::create($dados);

        return response()->json(
            $fueling->load(['vehicle', 'driver']),
            201
        );
    }

    // CONSULTAR ABASTECIMENTO
    public function show(Fueling $fueling): JsonResponse
    {
        return response()->json(
            $fueling->load(['vehicle', 'driver'])
        );
    }

    // EDITAR ABASTECIMENTO
    public function update(
        Request $request,
        Fueling $fueling
    ): JsonResponse {
        $dados = $request->validate([
            'vehicle_id' => [
                'sometimes', 'required', 'integer', 'exists:vehicles,id'
            ],
            'driver_id' => [
                'sometimes', 'required', 'integer', 'exists:drivers,id'
            ],
            'data' => ['sometimes', 'required', 'date'],
            'litros' => ['sometimes', 'required', 'numeric', 'gt:0'],
            'valor_total' => ['sometimes', 'required', 'numeric', 'gt:0'],
            'quilometragem' => [
                'sometimes', 'required', 'integer', 'min:0'
            ],
            'posto' => ['nullable', 'string', 'max:150'],
        ]);

        $fueling->update($dados);

        return response()->json(
            $fueling->load(['vehicle', 'driver'])
        );
    }

    // EXCLUIR ABASTECIMENTO
    public function destroy(Fueling $fueling): JsonResponse
    {
        $fueling->delete();

        return response()->json([
            'message' => 'Abastecimento excluído com sucesso.',
        ]);
    }
}
