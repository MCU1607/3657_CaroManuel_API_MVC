<?php

namespace App\Controllers;

use App\Models\Servicio;
use Core\Request;
use Core\Response;
use PDO;
use PDOException;

class ServicioController
{
    private Servicio $servicio;

    public function __construct(PDO $db)
    {
        $this->servicio = new Servicio($db);
    }

    private function validar(array $data): void
    {
        if (empty($data['Nombre'])) {
            Response::error('El nombre es obligatorio', 422);
        }

        if (
            isset($data['PrecioReferencial'])
            && (!is_numeric($data['PrecioReferencial']) || $data['PrecioReferencial'] < 0)
        ) {
            Response::error('El precio referencial no puede ser negativo', 422);
        }
    }

    public function index(): void
    {
        Response::success(
            $this->servicio->obtenerTodos(),
            'Servicios obtenidos correctamente'
        );
    }

    public function show(int $id): void
    {
        $servicio = $this->servicio->obtenerPorId($id);

        if (!$servicio) {
            Response::error('Servicio no encontrado', 404);
        }

        Response::success($servicio);
    }

    public function store(): void
    {
        $data = Request::body();

        $this->validar($data);

        try {
            $this->servicio->crear($data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('Ya existe un servicio con ese nombre', 409);
            }
            throw $e;
        }

        Response::success(null, 'Servicio registrado correctamente', 201);
    }

    public function update(int $id): void
    {
        if (!$this->servicio->obtenerPorId($id)) {
            Response::error('Servicio no encontrado', 404);
        }

        $data = Request::body();

        $this->validar($data);

        try {
            $this->servicio->actualizar($id, $data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('Ya existe un servicio con ese nombre', 409);
            }
            throw $e;
        }

        Response::success(null, 'Servicio actualizado correctamente');
    }

    public function destroy(int $id): void
    {
        if (!$this->servicio->obtenerPorId($id)) {
            Response::error('Servicio no encontrado', 404);
        }

        $this->servicio->eliminar($id);

        Response::success(null, 'Servicio eliminado correctamente');
    }
}