<?php

namespace App\Models;

use PDO;

class Servicio
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function obtenerTodos(): array
    {
        $sql = "
            SELECT IdServicio, Nombre, Descripcion, PrecioReferencial, Activo
            FROM Servicio
            WHERE Activo = 1
            ORDER BY Nombre
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function obtenerPorId(int $id): array|false
    {
        $sql = "
            SELECT IdServicio, Nombre, Descripcion, PrecioReferencial, Activo
            FROM Servicio
            WHERE IdServicio = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);

        return $stmt->fetch();
    }

    public function crear(array $data): bool
    {
        $sql = "
            INSERT INTO Servicio (Nombre, Descripcion, PrecioReferencial, Activo)
            VALUES (:nombre, :descripcion, :precio, 1)
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':nombre' => $data['Nombre'],
            ':descripcion' => $data['Descripcion'] ?? null,
            ':precio' => $data['PrecioReferencial'] ?? null
        ]);
    }

    public function actualizar(int $id, array $data): bool
    {
        $sql = "
            UPDATE Servicio
            SET Nombre = :nombre,
                Descripcion = :descripcion,
                PrecioReferencial = :precio
            WHERE IdServicio = :id
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':nombre' => $data['Nombre'],
            ':descripcion' => $data['Descripcion'] ?? null,
            ':precio' => $data['PrecioReferencial'] ?? null,
            ':id' => $id
        ]);
    }

    public function eliminar(int $id): bool
    {
        $sql = "UPDATE Servicio SET Activo = 0 WHERE IdServicio = :id";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([':id' => $id]);
    }
}