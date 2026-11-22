<?php

namespace App\Models;

use PDO;

class Cliente
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
                IdCliente, Dni, Nombres, Apellidos, Correo, Telefono,
                Direccion, Distrito, Departamento, FechaRegistro, Activo
            FROM Cliente
            WHERE Activo = 1
            ORDER BY Apellidos, Nombres
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    public function obtenerPorId(int $id): array|false
    {
        $sql = "
            SELECT
                IdCliente, Dni, Nombres, Apellidos, Correo, Telefono,
                Direccion, Distrito, Departamento, FechaRegistro, Activo
            FROM Cliente
            WHERE IdCliente = :id
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);

        return $stmt->fetch();
    }

    public function crear(array $data): bool
    {
        $sql = "
            INSERT INTO Cliente
            (
                Dni, Nombres, Apellidos, Correo, Telefono,
                Direccion, Distrito, Departamento, Activo
            )
            VALUES
            (
                :dni, :nombres, :apellidos, :correo, :telefono,
                :direccion, :distrito, :departamento, 1
            )
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':dni' => $data['Dni'],
            ':nombres' => $data['Nombres'],
            ':apellidos' => $data['Apellidos'],
            ':correo' => $data['Correo'],
            ':telefono' => $data['Telefono'],
            ':direccion' => $data['Direccion'] ?? null,
            ':distrito' => $data['Distrito'] ?? null,
            ':departamento' => $data['Departamento'] ?? 'Lima'
        ]);
    }

    public function actualizar(int $id, array $data): bool
    {
        $sql = "
            UPDATE Cliente
            SET Dni = :dni,
                Nombres = :nombres,
                Apellidos = :apellidos,
                Correo = :correo,
                Telefono = :telefono,
                Direccion = :direccion,
                Distrito = :distrito,
                Departamento = :departamento
            WHERE IdCliente = :id
        ";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([
            ':dni' => $data['Dni'],
            ':nombres' => $data['Nombres'],
            ':apellidos' => $data['Apellidos'],
            ':correo' => $data['Correo'],
            ':telefono' => $data['Telefono'],
            ':direccion' => $data['Direccion'] ?? null,
            ':distrito' => $data['Distrito'] ?? null,
            ':departamento' => $data['Departamento'] ?? 'Lima',
            ':id' => $id
        ]);
    }

    public function eliminar(int $id): bool
    {
        $sql = "UPDATE Cliente SET Activo = 0 WHERE IdCliente = :id";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute([':id' => $id]);
    }
}