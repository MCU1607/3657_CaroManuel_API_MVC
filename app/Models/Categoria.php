<?php

namespace App\Models;

use PDO;

class Categoria
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function obtenerTodos(): array
    {
        $sql = "
            SELECT IdCategoria, Nombre, Descripcion
            FROM Categoria
            ORDER BY Nombre
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function obtenerPorId(int $id): array|false
    {
        $sql = "
            SELECT IdCategoria, Nombre, Descripcion
            FROM Categoria
            WHERE IdCategoria = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);

        return $stmt->fetch();
    }

    public function crear(array $data): bool
    {
        $sql = "
            INSERT INTO Categoria (Nombre, Descripcion)
            VALUES (:nombre, :descripcion)
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':nombre' => $data['Nombre'],
            ':descripcion' => $data['Descripcion'] ?? null
        ]);
    }

    public function actualizar(int $id, array $data): bool
    {
        $sql = "
            UPDATE Categoria
            SET Nombre = :nombre,
                Descripcion = :descripcion
            WHERE IdCategoria = :id
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':nombre' => $data['Nombre'],
            ':descripcion' => $data['Descripcion'] ?? null,
            ':id' => $id
        ]);
    }

    public function eliminar(int $id): bool
    {
        $sql = "DELETE FROM Categoria WHERE IdCategoria = :id";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([':id' => $id]);
    }
}