<?php

namespace App\Models;

use PDO;

class Plataforma
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function obtenerTodos(): array
    {
        $sql = "
            SELECT IdPlataforma, Nombre, Fabricante
            FROM Plataforma
            ORDER BY Nombre
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function obtenerPorId(int $id): array|false
    {
        $sql = "
            SELECT IdPlataforma, Nombre, Fabricante
            FROM Plataforma
            WHERE IdPlataforma = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);

        return $stmt->fetch();
    }

    public function crear(array $data): bool
    {
        $sql = "
            INSERT INTO Plataforma (Nombre, Fabricante)
            VALUES (:nombre, :fabricante)
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':nombre' => $data['Nombre'],
            ':fabricante' => $data['Fabricante']
        ]);
    }

    public function actualizar(int $id, array $data): bool
    {
        $sql = "
            UPDATE Plataforma
            SET Nombre = :nombre,
                Fabricante = :fabricante
            WHERE IdPlataforma = :id
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':nombre' => $data['Nombre'],
            ':fabricante' => $data['Fabricante'],
            ':id' => $id
        ]);
    }

    public function eliminar(int $id): bool
    {
        $sql = "DELETE FROM Plataforma WHERE IdPlataforma = :id";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([':id' => $id]);
    }
}