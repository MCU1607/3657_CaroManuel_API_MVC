<?php

namespace App\Controllers;

use App\Models\SolicitudServicio;
use Core\Request;
use Core\Response;
use PDO;
use PDOException;

class SolicitudServicioController
{
    private SolicitudServicio $solicitud;

    public function __construct(PDO $db)
    {
        $this->solicitud = new SolicitudServicio($db);
    }

    private function validar(array $data): void
    {
        if (empty($data['IdCliente']) || empty($data['IdServicio'])) {
            Response::error('El cliente y el servicio son obligatorios', 422);
        }
    }

    public function index(): void
    {
        Response::success(
            $this->solicitud->obtenerTodos(),
            'Solicitudes obtenidas correctamente'
        );
    }

    public function show(int $id): void
    {
        $solicitud = $this->solicitud->obtenerPorId($id);

        if (!$solicitud) {
            Response::error('Solicitud no encontrada', 404);
        }

        Response::success($solicitud);
    }

    public function store(): void
    {
        $data = Request::body();

        $this->validar($data);

        try {
            $this->solicitud->crear($data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('El cliente, servicio o pedido indicado no existe', 409);
            }
            throw $e;
        }

        Response::success(null, 'Solicitud registrada correctamente', 201);
    }

    public function update(int $id): void
    {
        if (!$this->solicitud->obtenerPorId($id)) {
            Response::error('Solicitud no encontrada', 404);
        }

        $data = Request::body();

        $this->validar($data);

        try {
            $this->solicitud->actualizar($id, $data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('El cliente, servicio o pedido indicado no existe', 409);
            }
            throw $e;
        }

        Response::success(null, 'Solicitud actualizada correctamente');
    }

    public function cambiarEstado(int $id): void
    {
        if (!$this->solicitud->obtenerPorId($id)) {
            Response::error('Solicitud no encontrada', 404);
        }

        $data = Request::body();

        if (!in_array(
            $data['Estado'] ?? '',
            ['Recibida', 'En proceso', 'Atendida', 'Cerrada'],
            true
        )) {
            Response::error('El estado no es válido', 422);
        }

        $this->solicitud->cambiarEstado($id, $data['Estado']);

        Response::success(null, 'Estado de la solicitud actualizado correctamente');
    }

    public function destroy(int $id): void
    {
        if (!$this->solicitud->obtenerPorId($id)) {
            Response::error('Solicitud no encontrada', 404);
        }

        $this->solicitud->eliminar($id);

        Response::success(null, 'Solicitud eliminada correctamente');
    }
}