<?php

namespace App\Controllers;

use App\Models\UsuarioAdmin;
use Core\Request;
use Core\Response;
use PDO;
use PDOException;

class UsuarioAdminController
{
    private UsuarioAdmin $usuario;

    public function __construct(PDO $db)
    {
        $this->usuario = new UsuarioAdmin($db);
    }

    private function validar(array $data, bool $claveObligatoria): void
    {
        if (empty($data['Nombres'])) {
            Response::error('Los nombres son obligatorios', 422);
        }

        if (!filter_var($data['Correo'] ?? '', FILTER_VALIDATE_EMAIL)) {
            Response::error('El correo no es válido', 422);
        }

        if (!in_array($data['Rol'] ?? '', ['Administrador', 'Vendedor', 'Almacen'], true)) {
            Response::error('El rol debe ser Administrador, Vendedor o Almacen', 422);
        }

        if ($claveObligatoria && empty($data['Clave'])) {
            Response::error('La clave es obligatoria', 422);
        }
    }

    public function index(): void
    {
        Response::success(
            $this->usuario->obtenerTodos(),
            'Usuarios obtenidos correctamente'
        );
    }

    public function show(int $id): void
    {
        $usuario = $this->usuario->obtenerPorId($id);

        if (!$usuario) {
            Response::error('Usuario no encontrado', 404);
        }

        Response::success($usuario);
    }

    public function store(): void
    {
        $data = Request::body();

        $this->validar($data, true);

        try {
            $this->usuario->crear($data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('Ya existe un usuario con ese correo', 409);
            }
            throw $e;
        }

        Response::success(null, 'Usuario registrado correctamente', 201);
    }

    public function update(int $id): void
    {
        if (!$this->usuario->obtenerPorId($id)) {
            Response::error('Usuario no encontrado', 404);
        }

        $data = Request::body();

        $this->validar($data, false);

        try {
            $this->usuario->actualizar($id, $data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('Ya existe un usuario con ese correo', 409);
            }
            throw $e;
        }

        Response::success(null, 'Usuario actualizado correctamente');
    }

    public function destroy(int $id): void
    {
        if (!$this->usuario->obtenerPorId($id)) {
            Response::error('Usuario no encontrado', 404);
        }

        $this->usuario->eliminar($id);

        Response::success(null, 'Usuario eliminado correctamente');
    }
}