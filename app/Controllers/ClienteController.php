<?php

namespace App\Controllers;

use App\Models\Cliente;
use Core\Request;
use Core\Response;
use PDO;
use PDOException;

class ClienteController
{
    private Cliente $cliente;

    public function __construct(PDO $db)
    {
        $this->cliente = new Cliente($db);
    }

    private function validar(array $data): void
    {
        if (empty($data['Nombres']) || empty($data['Apellidos'])) {
            Response::error('Los nombres y apellidos son obligatorios', 422);
        }

        if (!preg_match('/^[0-9]{8}$/', $data['Dni'] ?? '')) {
            Response::error('El DNI debe tener 8 dígitos', 422);
        }

        if (!filter_var($data['Correo'] ?? '', FILTER_VALIDATE_EMAIL)) {
            Response::error('El correo no es válido', 422);
        }

        if (!preg_match('/^9[0-9]{8}$/', $data['Telefono'] ?? '')) {
            Response::error('El teléfono debe tener 9 dígitos y empezar con 9', 422);
        }
    }

    public function index(): void
    {
        Response::success(
            $this->cliente->obtenerTodos(),
            'Clientes obtenidos correctamente'
        );
    }

    public function show(int $id): void
    {
        $cliente = $this->cliente->obtenerPorId($id);

        if (!$cliente) {
            Response::error('Cliente no encontrado', 404);
        }

        Response::success($cliente);
    }

    public function store(): void
    {
        $data = Request::body();

        $this->validar($data);

        try {
            $this->cliente->crear($data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('Ya existe un cliente con ese DNI o correo', 409);
            }
            throw $e;
        }

        Response::success(null, 'Cliente registrado correctamente', 201);
    }

    public function update(int $id): void
    {
        if (!$this->cliente->obtenerPorId($id)) {
            Response::error('Cliente no encontrado', 404);
        }

        $data = Request::body();

        $this->validar($data);

        try {
            $this->cliente->actualizar($id, $data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('Ya existe un cliente con ese DNI o correo', 409);
            }
            throw $e;
        }

        Response::success(null, 'Cliente actualizado correctamente');
    }

    public function destroy(int $id): void
    {
        if (!$this->cliente->obtenerPorId($id)) {
            Response::error('Cliente no encontrado', 404);
        }

        $this->cliente->eliminar($id);

        Response::success(null, 'Cliente eliminado correctamente');
    }
}