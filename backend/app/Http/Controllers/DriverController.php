<?php

namespace App\Http\Controllers;

use App\Models\Driver;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class DriverController extends Controller
{
    // LISTAR MOTORISTAS
    public function index(): JsonResponse
    {
        return response()->json(
            Driver::orderBy('id', 'desc')->get()
        );
    }

    // CADASTRAR MOTORISTA
    public function store(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'nome' => ['required', 'string', 'max:150'],
            'cpf' => ['required', 'string', 'max:14', 'unique:drivers,cpf'],
            'cnh' => ['required', 'string', 'max:20', 'unique:drivers,cnh'],
            'telefone' => ['nullable', 'string', 'max:20'],
        ]);

        $driver = Driver::create($dados);

        return response()->json($driver, 201);
    }

    // CONSULTAR MOTORISTA
    public function show(Driver $driver): JsonResponse
    {
        return response()->json($driver);
    }

    // EDITAR MOTORISTA
    public function update(Request $request, Driver $driver): JsonResponse
    {
        $dados = $request->validate([
            'nome' => ['sometimes', 'required', 'string', 'max:150'],
            'cpf' => [
                'sometimes',
                'required',
                'string',
                'max:14',
                Rule::unique('drivers', 'cpf')->ignore($driver->id),
            ],
            'cnh' => [
                'sometimes',
                'required',
                'string',
                'max:20',
                Rule::unique('drivers', 'cnh')->ignore($driver->id),
            ],
            'telefone' => ['nullable', 'string', 'max:20'],
        ]);

        $driver->update($dados);

        return response()->json($driver);
    }

    // EXCLUIR MOTORISTA
    public function destroy(Driver $driver): JsonResponse
    {
        if ($driver->fuelings()->exists()) {
            return response()->json([
                'message' => 'Este motorista possui abastecimentos e não pode ser excluído.',
            ], 409);
        }

        $driver->delete();

        return response()->json([
            'message' => 'Motorista excluído com sucesso.',
        ]);
    }
}
