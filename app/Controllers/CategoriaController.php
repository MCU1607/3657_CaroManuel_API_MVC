<?php

namespace App\Controllers;

use App\Models\Categoria;
use Core\Request;
use Core\Response;
use PDO;
use PDOException;

class CategoriaController
{
    private Categoria $categoria;

    public function __construct(PDO $db)
    {
        $this->categoria = new Categoria($db);
    }

    public function index(): void
    {
        Response::success(
            $this->categoria->obtenerTodos(),
            'Categorías obtenidas correctamente'
        );
    }

    public function show(int $id): void
    {
        $categoria = $this->categoria->obtenerPorId($id);

        if (!$categoria) {
            Response::error('Categoría no encontrada', 404);
        }

        Response::success($categoria);
    }

    public function store(): void
    {
        $data = Request::body();

        if (empty($data['Nombre'])) {
            Response::error('El nombre es obligatorio', 422);
        }

        try {
            $this->categoria->crear($data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('Ya existe una categoría con ese nombre', 409);
            }
            throw $e;
        }

        Response::success(null, 'Categoría registrada correctamente', 201);
    }

    public function update(int $id): void
    {
        if (!$this->categoria->obtenerPorId($id)) {
            Response::error('Categoría no encontrada', 404);
        }

        $data = Request::body();

        if (empty($data['Nombre'])) {
            Response::error('El nombre es obligatorio', 422);
        }

        try {
            $this->categoria->actualizar($id, $data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('Ya existe una categoría con ese nombre', 409);
            }
            throw $e;
        }

        Response::success(null, 'Categoría actualizada correctamente');
    }

    public function destroy(int $id): void
    {
        if (!$this->categoria->obtenerPorId($id)) {
            Response::error('Categoría no encontrada', 404);
        }

        try {
            $this->categoria->eliminar($id);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error(
                    'No se puede eliminar: la categoría tiene productos asociados',
                    409
                );
            }
            throw $e;
        }

        Response::success(null, 'Categoría eliminada correctamente');
    }
}