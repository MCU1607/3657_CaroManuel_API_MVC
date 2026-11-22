<?php

namespace App\Controllers;

use App\Models\Plataforma;
use Core\Request;
use Core\Response;
use PDO;
use PDOException;

class PlataformaController
{
    private Plataforma $plataforma;

    public function __construct(PDO $db)
    {
        $this->plataforma = new Plataforma($db);
    }

    public function index(): void
    {
        Response::success(
            $this->plataforma->obtenerTodos(),
            'Plataformas obtenidas correctamente'
        );
    }

    public function show(int $id): void
    {
        $plataforma = $this->plataforma->obtenerPorId($id);

        if (!$plataforma) {
            Response::error('Plataforma no encontrada', 404);
        }

        Response::success($plataforma);
    }

    public function store(): void
    {
        $data = Request::body();

        if (empty($data['Nombre']) || empty($data['Fabricante'])) {
            Response::error('El nombre y el fabricante son obligatorios', 422);
        }

        try {
            $this->plataforma->crear($data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('Ya existe una plataforma con ese nombre', 409);
            }
            throw $e;
        }

        Response::success(null, 'Plataforma registrada correctamente', 201);
    }

    public function update(int $id): void
    {
        if (!$this->plataforma->obtenerPorId($id)) {
            Response::error('Plataforma no encontrada', 404);
        }

        $data = Request::body();

        if (empty($data['Nombre']) || empty($data['Fabricante'])) {
            Response::error('El nombre y el fabricante son obligatorios', 422);
        }

        try {
            $this->plataforma->actualizar($id, $data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('Ya existe una plataforma con ese nombre', 409);
            }
            throw $e;
        }

        Response::success(null, 'Plataforma actualizada correctamente');
    }

    public function destroy(int $id): void
    {
        if (!$this->plataforma->obtenerPorId($id)) {
            Response::error('Plataforma no encontrada', 404);
        }

        try {
            $this->plataforma->eliminar($id);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error(
                    'No se puede eliminar: la plataforma tiene productos asociados',
                    409
                );
            }
            throw $e;
        }

        Response::success(null, 'Plataforma eliminada correctamente');
    }
}