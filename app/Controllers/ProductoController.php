<?php

namespace App\Controllers;

use App\Models\Producto;
use Core\Request;
use Core\Response;
use PDO;
use PDOException;

class ProductoController
{
    private Producto $producto;

    public function __construct(PDO $db)
    {
        $this->producto = new Producto($db);
    }

    private function validar(array $data): void
    {
        if (empty($data['IdCategoria']) || empty($data['IdPlataforma'])) {
            Response::error('La categoría y la plataforma son obligatorias', 422);
        }

        if (empty($data['Nombre'])) {
            Response::error('El nombre es obligatorio', 422);
        }

        if (!in_array($data['Tipo'] ?? '', ['Consola', 'Videojuego', 'Accesorio'], true)) {
            Response::error('El tipo debe ser Consola, Videojuego o Accesorio', 422);
        }

        if (!isset($data['Precio']) || !is_numeric($data['Precio']) || $data['Precio'] <= 0) {
            Response::error('El precio debe ser mayor que cero', 422);
        }

        if (isset($data['Stock']) && (!is_numeric($data['Stock']) || $data['Stock'] < 0)) {
            Response::error('El stock no puede ser negativo', 422);
        }
    }

    public function index(): void
    {
        Response::success(
            $this->producto->obtenerTodos(),
            'Productos obtenidos correctamente'
        );
    }

    public function show(int $id): void
    {
        $producto = $this->producto->obtenerPorId($id);

        if (!$producto) {
            Response::error('Producto no encontrado', 404);
        }

        Response::success($producto);
    }

    public function store(): void
    {
        $data = Request::body();

        $this->validar($data);

        try {
            $this->producto->crear($data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('La categoría o la plataforma no existen', 409);
            }
            throw $e;
        }

        Response::success(null, 'Producto registrado correctamente', 201);
    }

    public function update(int $id): void
    {
        if (!$this->producto->obtenerPorId($id)) {
            Response::error('Producto no encontrado', 404);
        }

        $data = Request::body();

        $this->validar($data);

        try {
            $this->producto->actualizar($id, $data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('La categoría o la plataforma no existen', 409);
            }
            throw $e;
        }

        Response::success(null, 'Producto actualizado correctamente');
    }

    public function destroy(int $id): void
    {
        if (!$this->producto->obtenerPorId($id)) {
            Response::error('Producto no encontrado', 404);
        }

        $this->producto->eliminar($id);

        Response::success(null, 'Producto eliminado correctamente');
    }
}