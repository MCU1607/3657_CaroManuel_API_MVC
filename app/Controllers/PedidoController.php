<?php

namespace App\Controllers;

use App\Models\Pedido;
use Core\Request;
use Core\Response;
use PDO;
use PDOException;

class PedidoController
{
    private Pedido $pedido;

    public function __construct(PDO $db)
    {
        $this->pedido = new Pedido($db);
    }

    // Mensaje limpio de los SIGNAL de los procedimientos almacenados
    private function mensajeError(PDOException $e): string
    {
        return $e->errorInfo[2] ?? $e->getMessage();
    }

    public function index(): void
    {
        Response::success(
            $this->pedido->obtenerTodos(),
            'Pedidos obtenidos correctamente'
        );
    }

    public function show(int $id): void
    {
        $pedido = $this->pedido->obtenerPorId($id);

        if (!$pedido) {
            Response::error('Pedido no encontrado', 404);
        }

        $pedido['detalles'] = $this->pedido->obtenerDetalles($id);

        Response::success($pedido);
    }

    public function store(): void
    {
        $data = Request::body();

        if (empty($data['IdCliente'])) {
            Response::error('El cliente es obligatorio', 422);
        }

        if (!in_array(
            $data['MetodoPago'] ?? '',
            ['Efectivo', 'Tarjeta', 'Yape', 'Plin', 'Transferencia'],
            true
        )) {
            Response::error('El método de pago no es válido', 422);
        }

        if (!in_array($data['TipoEntrega'] ?? '', ['Recojo en tienda', 'Delivery'], true)) {
            Response::error('El tipo de entrega no es válido', 422);
        }

        if ($data['TipoEntrega'] === 'Delivery' && empty($data['DireccionEntrega'])) {
            Response::error('La dirección es obligatoria para delivery', 422);
        }

        if (empty($data['detalles']) || !is_array($data['detalles'])) {
            Response::error('El pedido debe tener al menos un producto', 422);
        }

        foreach ($data['detalles'] as $detalle) {
            if (empty($detalle['IdProducto']) || empty($detalle['Cantidad']) || $detalle['Cantidad'] <= 0) {
                Response::error('Cada detalle requiere IdProducto y una Cantidad mayor que cero', 422);
            }
        }

        try {
            $idPedido = $this->pedido->crear($data);

            Response::success(
                ['IdPedido' => $idPedido],
                'Pedido registrado correctamente',
                201
            );
        } catch (PDOException $e) {
            Response::error($this->mensajeError($e), 422);
        }
    }
    public function cambiarEstado(int $id): void
    {
        if (!$this->pedido->obtenerPorId($id)) {
            Response::error('Pedido no encontrado', 404);
        }

        $data = Request::body();

        if (!in_array(
            $data['Estado'] ?? '',
            ['Pendiente', 'Pagado', 'Enviado', 'Entregado', 'Cancelado'],
            true
        )) {
            Response::error('El estado no es válido', 422);
        }

        try {
            $this->pedido->cambiarEstado($id, $data['Estado']);
        } catch (PDOException $e) {
            Response::error($this->mensajeError($e), 422);
        }

        Response::success(null, 'Estado del pedido actualizado correctamente');
    }
}