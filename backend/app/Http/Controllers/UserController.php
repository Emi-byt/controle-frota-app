<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    // Listar usuários
    public function index()
    {
        return response()->json(
            User::orderBy('name')->get()
        );
    }

    // Cadastrar usuário
    public function store(Request $request)
    {
        $dados = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'role' => ['required', Rule::in(['admin', 'driver'])],
        ]);

        $user = new User();
        $user->name = $dados['name'];
        $user->email = $dados['email'];
        $user->password = $dados['password'];
        $user->role = $dados['role'];
        $user->save();

        return response()->json($user, 201);
    }

    // Consultar usuário
    public function show(User $user)
    {
        return response()->json($user);
    }

    // Atualizar usuário
    public function update(Request $request, User $user)
    {
        $dados = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'email' => [
                'sometimes',
                'required',
                'email',
                Rule::unique('users', 'email')->ignore($user->id),
            ],
            'password' => ['sometimes', 'required', 'string', 'min:8'],
            'role' => [
                'sometimes',
                'required',
                Rule::in(['admin', 'driver']),
            ],
        ]);

        foreach ($dados as $campo => $valor) {
            $user->{$campo} = $valor;
        }

        $user->save();

        return response()->json($user);
    }

    // Excluir usuário
    public function destroy(Request $request, User $user)
    {
        if ($request->user()->id === $user->id) {
            return response()->json([
                'message' => 'Você não pode excluir sua própria conta.',
            ], 403);
        }

        $user->delete();

        return response()->json([
            'message' => 'Usuário excluído com sucesso.',
        ]);
    }
}
