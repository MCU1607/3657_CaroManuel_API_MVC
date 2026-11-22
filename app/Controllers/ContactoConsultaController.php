<?php

namespace App\Controllers;

use App\Models\ContactoConsulta;
use Core\Request;
use Core\Response;
use PDO;
use PDOException;

class ContactoConsultaController
{
    private ContactoConsulta $consulta;

    public function __construct(PDO $db)
    {
        $this->consulta = new ContactoConsulta($db);
    }

    private function validar(array $data): void
    {
        if (empty($data['Nombre']) || empty($data['Asunto']) || empty($data['Mensaje'])) {
            Response::error('El nombre, asunto y mensaje son obligatorios', 422);
        }

        if (!filter_var($data['Correo'] ?? '', FILTER_VALIDATE_EMAIL)) {
            Response::error('El correo no es válido', 422);
        }

        if (!empty($data['Telefono']) && !preg_match('/^9[0-9]{8}$/', $data['Telefono'])) {
            Response::error('El teléfono debe tener 9 dígitos y empezar con 9', 422);
        }
    }

    public function index(): void
    {
        Response::success(
            $this->consulta->obtenerTodos(),
            'Consultas obtenidas correctamente'
        );
    }

    public function show(int $id): void
    {
        $consulta = $this->consulta->obtenerPorId($id);

        if (!$consulta) {
            Response::error('Consulta no encontrada', 404);
        }

        Response::success($consulta);
    }

    public function store(): void
    {
        $data = Request::body();

        $this->validar($data);

        try {
            $this->consulta->crear($data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('El cliente indicado no existe', 409);
            }
            throw $e;
        }

        Response::success(null, 'Consulta registrada correctamente', 201);
    }

    public function update(int $id): void
    {
        if (!$this->consulta->obtenerPorId($id)) {
            Response::error('Consulta no encontrada', 404);
        }

        $data = Request::body();

        $this->validar($data);

        try {
            $this->consulta->actualizar($id, $data);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::error('El cliente indicado no existe', 409);
            }
            throw $e;
        }

        Response::success(null, 'Consulta actualizada correctamente');
    }

    public function marcarAtendida(int $id): void
    {
        if (!$this->consulta->obtenerPorId($id)) {
            Response::error('Consulta no encontrada', 404);
        }

        $this->consulta->marcarAtendida($id);

        Response::success(null, 'Consulta marcada como atendida');
    }

    public function destroy(int $id): void
    {
        if (!$this->consulta->obtenerPorId($id)) {
            Response::error('Consulta no encontrada', 404);
        }

        $this->consulta->eliminar($id);

        Response::success(null, 'Consulta eliminada correctamente');
    }
}