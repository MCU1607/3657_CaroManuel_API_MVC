<?php

namespace App\Models;

use PDO;

class ContactoConsulta
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function obtenerTodos(): array
    {
        $sql = "
            SELECT
                IdConsulta, IdCliente, Nombre, Correo, Telefono,
                Asunto, Mensaje, FechaEnvio, Atendida
            FROM ContactoConsulta
            ORDER BY FechaEnvio DESC
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function obtenerPorId(int $id): array|false
    {
        $sql = "
            SELECT
                IdConsulta, IdCliente, Nombre, Correo, Telefono,
                Asunto, Mensaje, FechaEnvio, Atendida
            FROM ContactoConsulta
            WHERE IdConsulta = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);

        return $stmt->fetch();
    }

    public function crear(array $data): bool
    {
        $sql = "
            INSERT INTO ContactoConsulta
                (IdCliente, Nombre, Correo, Telefono, Asunto, Mensaje, Atendida)
            VALUES
                (:cliente, :nombre, :correo, :telefono, :asunto, :mensaje, 0)
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':cliente' => $data['IdCliente'] ?? null,
            ':nombre' => $data['Nombre'],
            ':correo' => $data['Correo'],
            ':telefono' => $data['Telefono'] ?? null,
            ':asunto' => $data['Asunto'],
            ':mensaje' => $data['Mensaje']
        ]);
    }

    public function actualizar(int $id, array $data): bool
    {
        $sql = "
            UPDATE ContactoConsulta
            SET IdCliente = :cliente,
                Nombre = :nombre,
                Correo = :correo,
                Telefono = :telefono,
                Asunto = :asunto,
                Mensaje = :mensaje
            WHERE IdConsulta = :id
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':cliente' => $data['IdCliente'] ?? null,
            ':nombre' => $data['Nombre'],
            ':correo' => $data['Correo'],
            ':telefono' => $data['Telefono'] ?? null,
            ':asunto' => $data['Asunto'],
            ':mensaje' => $data['Mensaje'],
            ':id' => $id
        ]);
    }

    public function marcarAtendida(int $id): bool
    {
        $sql = "UPDATE ContactoConsulta SET Atendida = 1 WHERE IdConsulta = :id";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([':id' => $id]);
    }

    public function eliminar(int $id): bool
    {
        $sql = "DELETE FROM ContactoConsulta WHERE IdConsulta = :id";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([':id' => $id]);
    }
}