<?php

namespace App\Controllers;

use App\Models\DetallePedido;
use App\Models\Pedido;
use Core\Request;
use Core\Response;
use PDO;
use PDOException;
use RuntimeException;

class DetallePedidoController
{
    private DetallePedido $detalle;
    private Pedido $pedido;

    public function __construct(PDO $db)
    {
        $this->detalle = new DetallePedido($db);
        $this->pedido = new Pedido($db);
    }

    // GET /api/pedidos/{id}/detalles
    public function index(int $id): void
    {
        if (!$this->pedido->obtenerPorId($id)) {
            Response::error('Pedido no encontrado', 404);
        }

        Response::success(
            $this->detalle->obtenerPorPedido($id),
            'Detalles del pedido obtenidos correctamente'
        );
    }

    // GET /api/detalles/{id}
    public function show(int $id): void
    {
        $detalle = $this->detalle->obtenerPorId($id);

        if (!$detalle) {
            Response::error('Detalle no encontrado', 404);
        }

        Response::success($detalle);
    }

    // POST /api/pedidos/{id}/detalles
    public function store(int $id): void
    {
        if (!$this->pedido->obtenerPorId($id)) {
            Response::error('Pedido no encontrado', 404);
        }

        $data = Request::body();

        if (empty($data['IdProducto'])) {
            Response::error('El producto es obligatorio', 422);
        }

        if (empty($data['Cantidad']) || !is_numeric($data['Cantidad']) || $data['Cantidad'] <= 0) {
            Response::error('La cantidad debe ser mayor que cero', 422);
        }

        try {
            $this->detalle->agregar($id, $data);
        } catch (PDOException $e) {
            Response::error($e->errorInfo[2] ?? $e->getMessage(), 422);
        }

        Response::success(null, 'Producto agregado al pedido correctamente', 201);
    }

    // DELETE /api/detalles/{id}
    public function destroy(int $id): void
    {
        if (!$this->detalle->obtenerPorId($id)) {
            Response::error('Detalle no encontrado', 404);
        }

        try {
            $this->detalle->eliminar($id);
        } catch (RuntimeException $e) {
            Response::error($e->getMessage(), 422);
        }

        Response::success(null, 'Producto quitado del pedido correctamente');
    }
}